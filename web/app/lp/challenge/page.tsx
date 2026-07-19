import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "あなたの論理力、証明できますか？ | ロジッキー診断",
  description:
    "「自分は論理的だ」と思っているあなたへ。14問の診断で整理力・推論力・判断力をスコア化。Sランクを取れるか挑戦。",
  openGraph: {
    title: "あなたの論理力、証明できますか？",
    description: "整理力・推論力・判断力を容赦なくスコア化。Sランクに挑戦しよう。",
    type: "website",
  },
};

// 論理的思考が得意な人向けLP（挑戦・競争訴求）
export default function ChallengeLP() {
  return (
    <div className="min-h-screen bg-app-bg">
      <div className="max-w-md mx-auto px-5 py-10 space-y-8">
        <div className="space-y-4">
          <p className="text-xs font-bold text-tiffany tracking-widest">LOGICKY 診断</p>
          <h1 className="text-3xl font-bold text-app-text leading-snug">
            あなたの論理力、<br />証明できますか？
          </h1>
          <p className="text-app-sub text-[15px] leading-relaxed">
            「自分は論理的なほうだ」——そう思っている人ほど、
            意外と足をすくわれるのがこの診断。
            整理力・推論力・判断力の3軸で、あなたの思考力を容赦なくスコア化します。
          </p>
        </div>

        <div className="bg-white rounded-2xl border border-card-border p-5 space-y-4">
          <div className="flex items-start gap-3">
            <span className="text-xl">🏆</span>
            <div>
              <p className="text-sm font-bold text-app-text">Sランクは90点以上</p>
              <p className="text-xs text-app-sub">生半可な「なんとなく論理的」では到達できません</p>
            </div>
          </div>
          <div className="flex items-start gap-3">
            <span className="text-xl">📊</span>
            <div>
              <p className="text-sm font-bold text-app-text">3軸で弱点が丸見え</p>
              <p className="text-xs text-app-sub">推論は強いのに判断が弱い——そんな凸凹まで見えます</p>
            </div>
          </div>
          <div className="flex items-start gap-3">
            <span className="text-xl">⚔️</span>
            <div>
              <p className="text-sm font-bold text-app-text">結果はシェアで殴り込み</p>
              <p className="text-xs text-app-sub">スコアカードをチームのSlackに貼って、部下や同僚と勝負</p>
            </div>
          </div>
        </div>

        <div className="space-y-3">
          <Link
            href="/"
            className="block w-full py-4 bg-tiffany text-white font-bold text-lg rounded-xl text-center shadow-sm active:opacity-90"
          >
            腕試しする（無料・5分）
          </Link>
          <p className="text-center text-xs text-app-gray">登録不要・14問・結果はすぐに表示</p>
        </div>

        <p className="text-center text-xs text-app-gray">
          © 2026 Logicky · <Link href="/privacy" className="underline">プライバシーポリシー</Link>
        </p>
      </div>
    </div>
  );
}
