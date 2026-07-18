import { get, put, list } from "@vercel/blob";

// ライセンスコードの保存構造。学校・企業・インフルエンサー・βテスター向けの
// 一括配布を想定し、コード1つに複数ユーザーの利用記録がぶら下がる。
export interface Redemption {
  deviceId: string;
  nickname: string;
  platform: string; // "ios" | "android" | "web"
  redeemedAt: string; // ISO8601
}

export interface LicenseCode {
  code: string; // 大文字英数字に正規化
  active: boolean;
  expiresAt: string | null; // コード自体の入力有効期限（null=無期限）
  grantDays: number | null; // プレミアム付与日数 30/90/365（null=無期限）
  maxUses: number | null; // 利用人数上限（null=無制限）
  note: string; // 営業先・学校名など
  createdAt: string;
  redemptions: Redemption[];
}

const PREFIX = "licenses/";

export function normalizeCode(raw: string): string {
  return raw.trim().toUpperCase().replace(/[^A-Z0-9_-]/g, "").slice(0, 32);
}

function pathFor(code: string): string {
  return `${PREFIX}${code}.json`;
}

export async function readCode(code: string): Promise<LicenseCode | null> {
  // useCache:false — 利用人数のカウントに古いキャッシュを使わない
  const result = await get(pathFor(code), { access: "private", useCache: false });
  if (!result || result.statusCode !== 200 || !result.stream) return null;
  const text = await new Response(result.stream).text();
  try {
    return JSON.parse(text) as LicenseCode;
  } catch {
    return null;
  }
}

export async function writeCode(license: LicenseCode): Promise<void> {
  await put(pathFor(license.code), JSON.stringify(license, null, 2), {
    access: "private",
    addRandomSuffix: false,
    allowOverwrite: true,
    contentType: "application/json",
  });
}

export async function listCodes(): Promise<LicenseCode[]> {
  const { blobs } = await list({ prefix: PREFIX, limit: 1000 });
  const codes: LicenseCode[] = [];
  for (const blob of blobs) {
    const code = blob.pathname.slice(PREFIX.length).replace(/\.json$/, "");
    const data = await readCode(code);
    if (data) codes.push(data);
  }
  return codes.sort((a, b) => (a.createdAt < b.createdAt ? 1 : -1));
}

// ─── 判定ロジック ────────────────────────────────────────────────────────────

export type RedeemFailure =
  | "not_found"
  | "inactive"
  | "expired"
  | "exhausted";

export function validateForRedeem(
  license: LicenseCode,
  deviceId: string
): { ok: true; already: Redemption | null } | { ok: false; reason: RedeemFailure } {
  const already = license.redemptions.find((r) => r.deviceId === deviceId) ?? null;
  // 同一端末の再入力は常に成功扱い（再インストール時の復元を兼ねる）
  if (already) return { ok: true, already };

  if (!license.active) return { ok: false, reason: "inactive" };
  if (license.expiresAt && new Date(license.expiresAt).getTime() < Date.now()) {
    return { ok: false, reason: "expired" };
  }
  if (license.maxUses !== null && license.redemptions.length >= license.maxUses) {
    return { ok: false, reason: "exhausted" };
  }
  return { ok: true, already: null };
}

// 付与終了日時（null=無期限）
export function premiumUntil(license: LicenseCode, redeemedAt: string): string | null {
  if (license.grantDays === null) return null;
  const until = new Date(redeemedAt);
  until.setDate(until.getDate() + license.grantDays);
  return until.toISOString();
}
