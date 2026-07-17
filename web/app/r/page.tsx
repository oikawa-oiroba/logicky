import type { Metadata } from "next";
import Link from "next/link";
import { rankLabel, rankDescription, parseSharedScores } from "../../lib/rank";

type Props = {
  searchParams: { [key: string]: string | string[] | undefined };
};

function ogImageUrl(searchParams: Props["searchParams"]): string {
  const s = parseSharedScores(searchParams);
  const q = new URLSearchParams({
    t: String(s.total),
    o: String(s.organize),
    r: String(s.reason),
    j: String(s.judge),
  });
  if (s.nickname) q.set("n", s.nickname);
  return `/api/og?${q.toString()}`;
}

export function generateMetadata({ searchParams }: Props): Metadata {
  const s = parseSharedScores(searchParams);
  const title = s.nickname
    ? `${s.nickname}さんのロジッキー診断結果：${s.total}点（${rankLabel(s.total)}ランク）`
    : `ロジッキー診断結果：${s.total}点（${rankLabel(s.total)}ランク）`;
  const description = `整理力${s.organize}% / 推論力${s.reason}% / 判断力${s.judge}%。あなたも14問で論理的思考力を無料診断。`;
  const image = ogImageUrl(searchParams);
  return {
    title,
    description,
    openGraph: {
      title,
      description,
      type: "website",
      images: [{ url: image, width: 1200, height: 630 }],
    },
    twitter: {
      card: "summary_large_image",
      title,
      description,
      images: [image],
    },
  };
}

export default function SharedResultPage({ searchParams }: Props) {
  const s = parseSharedScores(searchParams);
  const rank = rankLabel(s.total);
  const desc = rankDescription(s.total);

  const axes = [
    { label: "整理力（構造化・分類）", score: s.organize },
    { label: "推論力（演繹・帰納・仮説）", score: s.reason },
    { label: "判断力（事実・伝え方・優先度）", score: s.judge },
  ];

  return (
    <div className="min-h-screen bg-app-bg">
      <div className="max-w-md mx-auto px-5 py-8 space-y-6">
        <div className="text-center text-sm text-app-sub">
          {s.nickname ? `${s.nickname}さんの診断結果` : "シェアされた診断結果"}
        </div>

        {/* Score card */}
        <div className="bg-white rounded-2xl border border-card-border p-6 text-center space-y-3">
          <div className="flex items-center justify-center w-40 h-40 mx-auto rounded-full border-8 border-tiffany flex-col">
            <div>
              <span className="text-4xl font-bold text-app-text">{s.total}</span>
              <span className="text-sm text-app-sub ml-1">点</span>
            </div>
            <div className="text-2xl font-black text-tiffany">{rank}</div>
          </div>
          <div className="text-sm text-app-sub">{desc}</div>
        </div>

        {/* Axes */}
        <div className="bg-white rounded-2xl border border-card-border p-5 space-y-4">
          {axes.map((a) => (
            <div key={a.label} className="space-y-1.5">
              <div className="flex justify-between text-sm">
                <span className="text-app-sub">{a.label}</span>
                <span className="font-semibold text-tiffany">{a.score}%</span>
              </div>
              <div className="h-2 bg-card-border rounded-full overflow-hidden">
                <div
                  className="h-full bg-tiffany rounded-full"
                  style={{ width: `${a.score}%` }}
                />
              </div>
            </div>
          ))}
        </div>

        {/* CTA */}
        <div className="bg-tiffany rounded-2xl p-6 text-white text-center space-y-4">
          <h1 className="text-lg font-bold">あなたの論理的思考力は何点？</h1>
          <p className="text-sm opacity-90">
            14問・約5分で整理力・推論力・判断力をスコア化。無料・登録不要。
          </p>
          <Link
            href="/"
            className="block w-full py-3.5 bg-white text-tiffany font-bold rounded-xl text-sm active:opacity-90"
          >
            無料で診断する
          </Link>
        </div>

        <p className="text-center text-xs text-app-gray pb-4">
          © 2026 Logicky ·{" "}
          <a href="/privacy" className="underline">プライバシーポリシー</a>
        </p>
      </div>
    </div>
  );
}
