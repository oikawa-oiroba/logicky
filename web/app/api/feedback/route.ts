import { NextResponse } from "next/server";
import { put } from "@vercel/blob";

export const runtime = "nodejs";

const CATEGORIES = ["わかりづらい", "答えが違うと思う", "誤字・脱字", "その他"] as const;

interface FeedbackPayload {
  questionId: string;
  unit: string;
  category: string;
  comment: string;
  selectedChoiceId: string;
}

function sanitize(body: unknown): FeedbackPayload | null {
  if (typeof body !== "object" || body === null) return null;
  const b = body as Record<string, unknown>;
  const str = (v: unknown, max: number) =>
    typeof v === "string" ? v.slice(0, max).trim() : "";

  const questionId = str(b.questionId, 50);
  const category = str(b.category, 30);
  if (!questionId || !(CATEGORIES as readonly string[]).includes(category)) {
    return null;
  }
  return {
    questionId,
    unit: str(b.unit, 50),
    category,
    comment: str(b.comment, 500),
    selectedChoiceId: str(b.selectedChoiceId, 10),
  };
}

export async function POST(request: Request) {
  let payload: FeedbackPayload | null = null;
  try {
    payload = sanitize(await request.json());
  } catch {
    payload = null;
  }
  if (!payload) {
    return NextResponse.json({ error: "invalid payload" }, { status: 400 });
  }

  const now = new Date();
  const day = now.toISOString().slice(0, 10);
  const record = { ...payload, createdAt: now.toISOString() };

  try {
    await put(
      `feedback/${day}/${payload.questionId}.json`,
      JSON.stringify(record, null, 2),
      {
        access: "private",
        addRandomSuffix: true,
        contentType: "application/json",
      }
    );
  } catch (e) {
    console.error("feedback store failed", e);
    return NextResponse.json({ error: "store failed" }, { status: 500 });
  }

  return NextResponse.json({ ok: true });
}
