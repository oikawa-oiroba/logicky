import { NextResponse } from "next/server";
import {
  normalizeCode,
  readCode,
  writeCode,
  listCodes,
  type LicenseCode,
} from "../../../../lib/licenseStore";

export const runtime = "nodejs";

function authorized(request: Request): boolean {
  const token = process.env.LICENSE_ADMIN_TOKEN;
  if (!token) return false;
  const header = request.headers.get("authorization") ?? "";
  return header === `Bearer ${token}`;
}

function unauthorized() {
  return NextResponse.json({ error: "unauthorized" }, { status: 401 });
}

// コード一覧（利用状況つき）
export async function GET(request: Request) {
  if (!authorized(request)) return unauthorized();
  const codes = await listCodes();
  return NextResponse.json({
    codes: codes.map((c) => ({
      ...c,
      usedCount: c.redemptions.length,
      remaining: c.maxUses === null ? null : Math.max(0, c.maxUses - c.redemptions.length),
    })),
  });
}

// コード発行
export async function POST(request: Request) {
  if (!authorized(request)) return unauthorized();

  let body: Record<string, unknown>;
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: "invalid payload" }, { status: 400 });
  }

  const code = normalizeCode(typeof body.code === "string" ? body.code : "");
  if (code.length < 3) {
    return NextResponse.json({ error: "コードは英数字3文字以上にしてください" }, { status: 400 });
  }
  if (await readCode(code)) {
    return NextResponse.json({ error: "同名のコードが既に存在します" }, { status: 409 });
  }

  const grantDaysRaw = body.grantDays;
  const grantDays =
    grantDaysRaw === null || grantDaysRaw === undefined || grantDaysRaw === ""
      ? null
      : Number(grantDaysRaw);
  if (grantDays !== null && ![30, 90, 365].includes(grantDays)) {
    return NextResponse.json({ error: "付与期間は30/90/365日または無期限です" }, { status: 400 });
  }

  const maxUsesRaw = body.maxUses;
  const maxUses =
    maxUsesRaw === null || maxUsesRaw === undefined || maxUsesRaw === ""
      ? null
      : Math.max(1, Math.floor(Number(maxUsesRaw)));
  if (maxUses !== null && !Number.isFinite(maxUses)) {
    return NextResponse.json({ error: "利用人数制限が不正です" }, { status: 400 });
  }

  let expiresAt: string | null = null;
  if (typeof body.expiresAt === "string" && body.expiresAt) {
    const d = new Date(body.expiresAt);
    if (Number.isNaN(d.getTime())) {
      return NextResponse.json({ error: "有効期限の形式が不正です" }, { status: 400 });
    }
    expiresAt = d.toISOString();
  }

  const license: LicenseCode = {
    code,
    active: true,
    expiresAt,
    grantDays,
    maxUses,
    note: typeof body.note === "string" ? body.note.slice(0, 200) : "",
    createdAt: new Date().toISOString(),
    redemptions: [],
  };
  await writeCode(license);
  return NextResponse.json({ ok: true, license });
}

// 有効/無効切り替え・メモ更新
export async function PATCH(request: Request) {
  if (!authorized(request)) return unauthorized();

  let body: Record<string, unknown>;
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: "invalid payload" }, { status: 400 });
  }

  const code = normalizeCode(typeof body.code === "string" ? body.code : "");
  const license = await readCode(code);
  if (!license) {
    return NextResponse.json({ error: "コードが見つかりません" }, { status: 404 });
  }

  if (typeof body.active === "boolean") license.active = body.active;
  if (typeof body.note === "string") license.note = body.note.slice(0, 200);

  await writeCode(license);
  return NextResponse.json({ ok: true, license });
}
