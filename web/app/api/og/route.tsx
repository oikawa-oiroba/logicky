import { ImageResponse } from "next/og";
import {
  rankLabel,
  rankDescription,
  parseSharedScores,
  scoreColor,
  RAINBOW_COLORS,
} from "../../../lib/rank";

export const runtime = "edge";

const TIFFANY = "#0ABAB5";

// Google Fontsから描画に使う文字だけをサブセットしたフォントを取得する
// （ブラウザ以外のUAにはttf/otfが返るためsatoriでそのまま使える）
async function loadGoogleFont(text: string, weight: number): Promise<ArrayBuffer> {
  const url = `https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@${weight}&text=${encodeURIComponent(text)}`;
  const css = await (await fetch(url)).text();
  const resource = css.match(/src: url\((.+?)\) format\('(opentype|truetype)'\)/);
  if (!resource) throw new Error("Failed to load font");
  return (await fetch(resource[1])).arrayBuffer();
}

function AxisRow({ label, score }: { label: string; score: number }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 20 }}>
      <div style={{ display: "flex", width: 110, fontSize: 26, color: "#5A6472" }}>
        {label}
      </div>
      <div
        style={{
          display: "flex",
          flex: 1,
          height: 22,
          backgroundColor: "#E8ECEF",
          borderRadius: 11,
        }}
      >
        <div
          style={{
            display: "flex",
            width: `${Math.max(score, 4)}%`,
            height: 22,
            backgroundColor: TIFFANY,
            borderRadius: 11,
          }}
        />
      </div>
      <div
        style={{
          display: "flex",
          width: 90,
          fontSize: 28,
          color: TIFFANY,
          justifyContent: "flex-end",
        }}
      >
        {score}%
      </div>
    </div>
  );
}

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const scores = parseSharedScores(Object.fromEntries(searchParams.entries()));
  const rank = rankLabel(scores.total);
  const desc = rankDescription(scores.total);
  const title = scores.nickname
    ? `${scores.nickname}さんの診断結果`
    : "ロジッキー診断結果";

  const allText =
    `${title}${rank}${desc}点数整理力推論力判断力ロジッキー診断あなたも無料で診断するlogicky.appLogicky0123456789%SABCD+` +
    "エキスパート実践レベルの思考力応用が身についている基礎は習得できているもう少しで基礎レベルから鍛え直そう論理";

  const [bold, regular] = await Promise.all([
    loadGoogleFont(allText, 700),
    loadGoogleFont(allText, 400),
  ]);

  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          backgroundColor: "#F5F7F8",
          padding: 48,
          fontFamily: "NotoSansJP",
        }}
      >
        {/* Header */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            marginBottom: 28,
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
            <div
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                width: 52,
                height: 52,
                borderRadius: 12,
                backgroundColor: TIFFANY,
              }}
            >
              <svg
                width="32"
                height="32"
                viewBox="0 0 24 24"
                fill="none"
                stroke="#FFFFFF"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
              >
                <path d="M12 18V5" />
                <path d="M15 13a4.17 4.17 0 0 1-3-4 4.17 4.17 0 0 1-3 4" />
                <path d="M17.598 6.5A3 3 0 1 0 12 5a3 3 0 1 0-5.598 1.5" />
                <path d="M17.997 5.125a4 4 0 0 1 2.526 5.77" />
                <path d="M18 18a4 4 0 0 0 2-7.464" />
                <path d="M19.967 17.483A4 4 0 1 1 12 18a4 4 0 1 1-7.967-.517" />
                <path d="M6 18a4 4 0 0 1-2-7.464" />
                <path d="M6.003 5.125a4 4 0 0 0-2.526 5.77" />
              </svg>
            </div>
            <div style={{ display: "flex", fontSize: 34, fontWeight: 700, color: "#1A2330" }}>
              Logicky
            </div>
          </div>
          <div style={{ display: "flex", fontSize: 26, color: "#8A94A3" }}>
            ロジッキー診断
          </div>
        </div>

        {/* Body card */}
        <div
          style={{
            display: "flex",
            flex: 1,
            backgroundColor: "#FFFFFF",
            borderRadius: 28,
            border: "1px solid #E8ECEF",
            padding: "40px 56px",
            alignItems: "center",
            gap: 64,
          }}
        >
          {/* Score（スコア帯で色が変わる。満点はレインボーリング） */}
          <div
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              width: 250,
              height: 250,
              borderRadius: 125,
              padding: 14,
              background:
                scores.total >= 100
                  ? `linear-gradient(135deg, ${RAINBOW_COLORS.join(", ")})`
                  : scoreColor(scores.total),
            }}
          >
            <div
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                width: "100%",
                height: "100%",
                borderRadius: 125,
                backgroundColor: "#FFFFFF",
                flexDirection: "column",
              }}
            >
              <div style={{ display: "flex", alignItems: "flex-end" }}>
                <div style={{ display: "flex", fontSize: 96, fontWeight: 700, color: "#1A2330", lineHeight: 1 }}>
                  {scores.total}
                </div>
                <div style={{ display: "flex", fontSize: 30, color: "#8A94A3", marginBottom: 8 }}>
                  点
                </div>
              </div>
              <div style={{ display: "flex", fontSize: 44, fontWeight: 700, color: scoreColor(scores.total), lineHeight: 1.2 }}>
                {rank}
              </div>
            </div>
          </div>

          {/* Right column */}
          <div
            style={{
              display: "flex",
              flexDirection: "column",
              flex: 1,
              gap: 22,
            }}
          >
            <div style={{ display: "flex", fontSize: 40, fontWeight: 700, color: "#1A2330" }}>
              {title}
            </div>
            <div style={{ display: "flex", fontSize: 28, color: "#5A6472", marginTop: -10 }}>
              {desc}
            </div>
            <AxisRow label="整理力" score={scores.organize} />
            <AxisRow label="推論力" score={scores.reason} />
            <AxisRow label="判断力" score={scores.judge} />
          </div>
        </div>

        {/* Footer */}
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            marginTop: 24,
          }}
        >
          <div style={{ display: "flex", fontSize: 26, color: "#5A6472" }}>
            あなたも無料で診断する
          </div>
          <div style={{ display: "flex", fontSize: 26, fontWeight: 700, color: TIFFANY }}>
            logicky.app
          </div>
        </div>
      </div>
    ),
    {
      width: 1200,
      height: 630,
      fonts: [
        { name: "NotoSansJP", data: bold, weight: 700 },
        { name: "NotoSansJP", data: regular, weight: 400 },
      ],
    }
  );
}
