import { NextResponse } from "next/server";
import {
  normalizeCode,
  readCode,
  writeCode,
  validateForRedeem,
  premiumUntil,
  type Redemption,
} from "../../../../lib/licenseStore";

export const runtime = "nodejs";

const FAILURE_MESSAGES: Record<string, string> = {
  not_found: "コードが見つかりません",
  inactive: "このコードは現在無効です",
  expired: "このコードの有効期限が切れています",
  exhausted: "このコードは利用人数の上限に達しています",
};

export async function POST(request: Request) {
  let body: Record<string, unknown>;
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: "invalid payload" }, { status: 400 });
  }

  const code = normalizeCode(typeof body.code === "string" ? body.code : "");
  const deviceId =
    typeof body.deviceId === "string" ? body.deviceId.slice(0, 64).trim() : "";
  const nickname =
    typeof body.nickname === "string" ? body.nickname.slice(0, 20).trim() : "";
  const platform =
    typeof body.platform === "string" ? body.platform.slice(0, 10) : "unknown";

  if (!code || !deviceId) {
    return NextResponse.json({ error: "invalid payload" }, { status: 400 });
  }

  const license = await readCode(code);
  if (!license) {
    return NextResponse.json(
      { error: FAILURE_MESSAGES.not_found, reason: "not_found" },
      { status: 404 }
    );
  }

  const verdict = validateForRedeem(license, deviceId);
  if (!verdict.ok) {
    return NextResponse.json(
      { error: FAILURE_MESSAGES[verdict.reason], reason: verdict.reason },
      { status: 403 }
    );
  }

  let redemption: Redemption;
  if (verdict.already) {
    redemption = verdict.already;
  } else {
    redemption = {
      deviceId,
      nickname,
      platform,
      redeemedAt: new Date().toISOString(),
    };
    license.redemptions.push(redemption);
    await writeCode(license);
  }

  return NextResponse.json({
    ok: true,
    code: license.code,
    grantDays: license.grantDays,
    premiumUntil: premiumUntil(license, redemption.redeemedAt),
    alreadyRedeemed: !!verdict.already,
  });
}
