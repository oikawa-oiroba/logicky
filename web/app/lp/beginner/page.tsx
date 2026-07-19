import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "「話がわかりにくい」と言われたことありませんか？ | ロジッキー診断",
  description:
    "論理的思考は才能ではなく、練習で身につくスキル。まずは5分の無料診断で、あなたのつまずきポイントを見つけましょう。",
  openGraph: {
    title: "「話がわかりにくい」と言われたことありませんか？",
    description: "原因は才能ではなく「思考のクセ」。5分の診断でつまずきポイントがわかります。",
    type: "website",
  },
};

// 論理的思考が苦手な人向けLP（共感・安心訴求）
export default function BeginnerLP() {
  return (
    <div className="min-h-screen bg-app-bg">
      <div className="max-w-md mx-auto px-5 py-10 space-y-8">
        <div className="space-y-4">
          <p className="text-xs font-bold text-tiffany tracking-widest">LOGICKY 診断</p>
          <h1 className="text-3xl font-bold text-app-text leading-snug">
            「話がわかりにくい」と<br />言われたこと、<br />ありませんか？
          </h1>
          <p className="text-app-sub text-[15px] leading-relaxed">
            会議で説明が伝わらない。報告書に赤字がびっしり。
            それは頭が悪いからではなく、<strong className="text-app-text">考えの整理のしかたをまだ習っていないだけ</strong>です。
            論理的思考は、練習すれば誰でも身につくスキルです。
          </p>
        </div>

        <div className="bg-white rounded-2xl border border-card-border p-5 space-y-4">
          <div className="flex items-start gap-3">
            <span className="text-xl">🔍</span>
            <div>
              <p className="text-sm font-bold text-app-text">まず「どこでつまずくか」を知る</p>
              <p className="text-xs text-app-sub">整理・推論・判断の3軸で、苦手ポイントをやさしく特定</p>
            </div>
          </div>
          <div className="flex items-start gap-3">
            <span className="text-xl">💡</span>
            <div>
              <p className="text-sm font-bold text-app-text">専門用語には「ことばのヒント」</p>
              <p className="text-xs text-app-sub">MECEや演繹法など、難しい言葉はその場でやさしく解説</p>
            </div>
          </div>
          <div className="flex items-start gap-3">
            <span className="text-xl">🌱</span>
            <div>
              <p className="text-sm font-bold text-app-text">結果は「伸びしろ」で表示</p>
              <p className="text-xs text-app-sub">できない探しではなく、次の一歩がわかる診断です</p>
            </div>
          </div>
        </div>

        <div className="space-y-3">
          <Link
            href="/"
            className="block w-full py-4 bg-tiffany text-white font-bold text-lg rounded-xl text-center shadow-sm active:opacity-90"
          >
            5分で自分の思考を知る（無料）
          </Link>
          <p className="text-center text-xs text-app-gray">登録不要・14問・やさしい解説つき</p>
          <Link
            href="/lite"
            className="block text-center text-sm text-tiffany underline underline-offset-2"
          >
            まずは30秒の「思考のクセ診断」から試す →
          </Link>
        </div>

        <p className="text-center text-xs text-app-gray">
          © 2026 Logicky · <Link href="/privacy" className="underline">プライバシーポリシー</Link>
        </p>
      </div>
    </div>
  );
}
