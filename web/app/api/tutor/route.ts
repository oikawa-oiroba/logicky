import { NextResponse } from "next/server";
import Anthropic from "@anthropic-ai/sdk";
import { get, put } from "@vercel/blob";

export const runtime = "nodejs";

// AI家庭教師「ロジ先生」プロキシ。
// APIキーはサーバー側（ANTHROPIC_API_KEY）にのみ保持し、端末単位で回数制限をかける。

const DAILY_LIMIT = 10; // 1端末あたりの1日の質問数上限
const MAX_TURNS = 12; // 会話履歴の最大メッセージ数
const MODEL = "claude-haiku-4-5"; // コスト重視（ユーザー指定）

interface TutorContext {
  unitName?: string;
  methodName?: string;
  questionBody?: string;
  choices?: { id: string; text: string }[];
  correctChoiceId?: string;
  selectedChoiceId?: string;
  explanation?: string;
}

function buildSystemPrompt(ctx: TutorContext): string {
  let prompt = `あなたは「ロジ先生」。論理的思考トレーニングアプリLogickyのAI家庭教師です。

## 人格・話し方
- フレンドリーで励ますのが上手な家庭教師。堅苦しくない敬語
- 説明は簡潔に（原則3〜5文以内）。長い講義はしない
- 難しい用語には身近なたとえを添える
- 生徒が自分で気づけるよう、答えを丸写しにせずヒントから導く
- 正しく理解できていたら素直に褒める

## 制約
- Logickyの問題・論理的思考の学習に関する質問にだけ答える。それ以外の話題は「その質問はロジ先生の専門外です」とやんわり断る
- 個人情報を尋ねない・扱わない
- わからないことは正直に「わからない」と言う`;

  if (ctx.questionBody) {
    prompt += `\n\n## いま生徒が取り組んでいる問題\n`;
    if (ctx.unitName) prompt += `単元: ${ctx.unitName}`;
    if (ctx.methodName) prompt += `（${ctx.methodName}）`;
    prompt += `\n問題文: ${ctx.questionBody}\n`;
    if (ctx.choices?.length) {
      prompt += `選択肢:\n${ctx.choices
        .map((c) => `${c.id.toUpperCase()}. ${c.text}`)
        .join("\n")}\n`;
    }
    if (ctx.correctChoiceId) prompt += `正解: ${ctx.correctChoiceId.toUpperCase()}\n`;
    if (ctx.selectedChoiceId)
      prompt += `生徒の回答: ${ctx.selectedChoiceId.toUpperCase()}\n`;
    if (ctx.explanation) prompt += `公式解説: ${ctx.explanation}\n`;
  }

  return prompt;
}

// 1端末×1日の利用回数をBlobで管理（厳密なアトミック性は不要な規模のため read-modify-write）
async function checkAndIncrementUsage(deviceId: string): Promise<boolean> {
  const day = new Date().toISOString().slice(0, 10);
  const path = `tutor/usage/${day}/${deviceId}.json`;
  let count = 0;
  try {
    const result = await get(path, { access: "private", useCache: false });
    if (result?.statusCode === 200 && result.stream) {
      const data = JSON.parse(await new Response(result.stream).text());
      count = data.count ?? 0;
    }
  } catch {}
  if (count >= DAILY_LIMIT) return false;
  await put(path, JSON.stringify({ count: count + 1 }), {
    access: "private",
    addRandomSuffix: false,
    allowOverwrite: true,
    contentType: "application/json",
  });
  return true;
}

export async function POST(request: Request) {
  if (!process.env.ANTHROPIC_API_KEY) {
    return NextResponse.json(
      { error: "ロジ先生は準備中です。もうしばらくお待ちください" },
      { status: 503 }
    );
  }

  let body: {
    deviceId?: string;
    messages?: { role: string; content: string }[];
    context?: TutorContext;
  };
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: "invalid payload" }, { status: 400 });
  }

  const deviceId = typeof body.deviceId === "string" ? body.deviceId.slice(0, 64) : "";
  const rawMessages = Array.isArray(body.messages) ? body.messages : [];
  if (!deviceId || rawMessages.length === 0) {
    return NextResponse.json({ error: "invalid payload" }, { status: 400 });
  }

  const messages = rawMessages
    .slice(-MAX_TURNS)
    .filter(
      (m) =>
        (m.role === "user" || m.role === "assistant") &&
        typeof m.content === "string" &&
        m.content.trim().length > 0
    )
    .map((m) => ({
      role: m.role as "user" | "assistant",
      content: m.content.slice(0, 1000),
    }));
  if (messages.length === 0 || messages[messages.length - 1].role !== "user") {
    return NextResponse.json({ error: "invalid payload" }, { status: 400 });
  }

  const allowed = await checkAndIncrementUsage(deviceId);
  if (!allowed) {
    return NextResponse.json(
      { error: `今日の質問回数の上限（${DAILY_LIMIT}回）に達しました。また明日どうぞ！` },
      { status: 429 }
    );
  }

  try {
    const client = new Anthropic();
    const response = await client.messages.create({
      model: MODEL,
      max_tokens: 512,
      system: buildSystemPrompt(body.context ?? {}),
      messages,
    });

    const reply = response.content
      .filter((b): b is Anthropic.TextBlock => b.type === "text")
      .map((b) => b.text)
      .join("");

    return NextResponse.json({ reply });
  } catch (e) {
    console.error("tutor request failed", e);
    return NextResponse.json(
      { error: "ロジ先生がうまく応答できませんでした。少し待ってからもう一度お試しください" },
      { status: 502 }
    );
  }
}
