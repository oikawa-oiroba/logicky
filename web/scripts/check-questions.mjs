// 問題データの品質チェック（AI校閲）
// 全問題をClaude（Haiku）に流し、誤字・不自然な日本語・正解と解説の矛盾・
// 選択肢の曖昧さを検査してMarkdownレポートを出力する。
//
// 実行: ANTHROPIC_API_KEY を環境に入れて
//   node scripts/check-questions.mjs [出力先.md]
import Anthropic from "@anthropic-ai/sdk";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const QUESTIONS_PATH = path.join(here, "../../Logicky/Resources/questions.json");
const OUT_PATH = process.argv[2] ?? path.join(here, "../../docs/question_check_report.md");
const MODEL = "claude-haiku-4-5";
const CONCURRENCY = 8;

const raw = JSON.parse(fs.readFileSync(QUESTIONS_PATH, "utf8"));
const questions = Array.isArray(raw) ? raw : raw.questions;

const client = new Anthropic();

const SYSTEM = `あなたは日本語のビジネス教材（論理的思考トレーニングの問題集）の校閲者です。
与えられた1問を検査し、実際に問題がある点だけを報告してください。

検査観点:
1. typo: 誤字・脱字・日本語の中への不自然な英単語の混入（MECEや5W2H等の正当なフレームワーク用語は除く）
2. language: 不自然・意味が取りにくい日本語表現
3. answer_mismatch: correctChoiceIdと解説の内容が矛盾している、または解説が別の選択肢を正解として説明している
4. ambiguous: 正解以外の選択肢も正解と解釈できてしまう曖昧さ
5. other: その他の明確な問題（設問として成立していない等）

重要: 過剰報告しないこと。文体の好みや軽微な言い回しは報告しない。
確信のある問題点のみ、issuesに含める。問題がなければ issues は空配列。`;

const OUTPUT_SCHEMA = {
  type: "json_schema",
  schema: {
    type: "object",
    properties: {
      issues: {
        type: "array",
        items: {
          type: "object",
          properties: {
            type: {
              type: "string",
              enum: ["typo", "language", "answer_mismatch", "ambiguous", "other"],
            },
            severity: { type: "string", enum: ["high", "medium", "low"] },
            detail: { type: "string" },
            suggestion: { type: "string" },
          },
          required: ["type", "severity", "detail", "suggestion"],
          additionalProperties: false,
        },
      },
    },
    required: ["issues"],
    additionalProperties: false,
  },
};

function questionPayload(q) {
  const lines = [
    `ID: ${q.id}`,
    `単元: ${q.unit ?? "-"}`,
    `形式: ${q.type}`,
    `問題文: ${q.body}`,
  ];
  if (q.choices?.length) {
    lines.push("選択肢:");
    for (const c of q.choices) lines.push(`  ${c.id}. ${c.text}`);
    lines.push(`正解: ${q.correctChoiceId}`);
  }
  if (q.explanation) lines.push(`解説: ${q.explanation}`);
  return lines.join("\n");
}

async function checkOne(q) {
  try {
    const response = await client.messages.create({
      model: MODEL,
      max_tokens: 700,
      system: SYSTEM,
      output_config: { format: OUTPUT_SCHEMA },
      messages: [{ role: "user", content: questionPayload(q) }],
    });
    const text = response.content.find((b) => b.type === "text")?.text ?? "{}";
    const parsed = JSON.parse(text);
    return { id: q.id, unit: q.unit, issues: parsed.issues ?? [] };
  } catch (e) {
    return { id: q.id, unit: q.unit, issues: [], error: String(e.message ?? e) };
  }
}

async function run() {
  console.log(`checking ${questions.length} questions with ${MODEL} ...`);
  const results = [];
  let done = 0;
  const queue = [...questions];

  async function worker() {
    while (queue.length > 0) {
      const q = queue.shift();
      results.push(await checkOne(q));
      done += 1;
      if (done % 25 === 0) console.log(`  ${done}/${questions.length}`);
    }
  }
  await Promise.all(Array.from({ length: CONCURRENCY }, worker));

  const withIssues = results.filter((r) => r.issues.length > 0);
  const errors = results.filter((r) => r.error);
  const severityRank = { high: 0, medium: 1, low: 2 };
  withIssues.sort(
    (a, b) =>
      Math.min(...a.issues.map((i) => severityRank[i.severity])) -
      Math.min(...b.issues.map((i) => severityRank[i.severity]))
  );

  const lines = [
    `# 問題データ品質チェックレポート`,
    ``,
    `- 実行日: ${new Date().toISOString().slice(0, 10)}`,
    `- モデル: ${MODEL}`,
    `- 検査数: ${questions.length}問 / 指摘あり: ${withIssues.length}問 / エラー: ${errors.length}件`,
    ``,
  ];

  const typeLabel = {
    typo: "誤字・混入",
    language: "不自然な日本語",
    answer_mismatch: "正解と解説の矛盾",
    ambiguous: "選択肢の曖昧さ",
    other: "その他",
  };

  for (const r of withIssues) {
    lines.push(`## ${r.id}（${r.unit ?? "-"}）`);
    for (const issue of r.issues) {
      lines.push(
        `- **[${issue.severity}] ${typeLabel[issue.type]}**: ${issue.detail}`
      );
      if (issue.suggestion) lines.push(`  - 提案: ${issue.suggestion}`);
    }
    lines.push("");
  }

  if (errors.length > 0) {
    lines.push(`## チェック失敗（要再実行）`);
    for (const r of errors) lines.push(`- ${r.id}: ${r.error}`);
  }

  fs.writeFileSync(OUT_PATH, lines.join("\n"));
  console.log(`\nreport: ${OUT_PATH}`);
  console.log(`指摘あり: ${withIssues.length}問 / ${questions.length}問`);
}

run();
