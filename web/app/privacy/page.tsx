import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "プライバシーポリシー | Logicky",
};

export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-white">
      <div className="max-w-2xl mx-auto px-5 py-10 prose prose-sm">
        <Link href="/" className="text-tiffany text-sm mb-6 inline-block">
          ← ロジッキー診断へ
        </Link>

        <h1 className="text-2xl font-bold text-app-text mb-1">プライバシーポリシー</h1>
        <p className="text-app-gray text-sm mb-8">最終更新日：2026年5月6日</p>

        {[
          {
            title: "1. はじめに",
            body: "Logicky（以下「本アプリ」）は、ユーザーの思考力トレーニングを支援するiOSアプリです。本プライバシーポリシーは、本アプリおよび関連Webサービスにおける情報の取り扱いについて説明します。",
          },
          {
            title: "2. 収集する情報",
            body: "本アプリ・Webサービスは、外部サーバーへ個人情報を送信・収集しません。デバイス上またはブラウザのLocalStorageに保存されるデータは、学習の進捗状況・診断結果・スコアのみです。これらは外部に送信されることはありません。例外として、Webサービスでユーザーが任意で送信する「問題へのフィードバック」（意見の種類とコメント）は、内容改善の目的でのみサーバーに保存されます。フィードバックに氏名・連絡先等の個人情報は入力しないでください。",
          },
          {
            title: "3. 第三者への情報提供",
            body: "いかなる第三者にもユーザーデータを提供・販売・共有しません。",
          },
          {
            title: "4. 外部サービスの利用",
            body: "本アプリ・Webサービスは、広告SDK・アナリティクスSDK・クラッシュレポートツール等の外部サービスを一切使用しません。",
          },
          {
            title: "5. SNSシェア機能",
            body: "診断結果のシェア機能を使用する場合、iOS標準の共有シートまたはブラウザのWeb Share APIを通じてデータがシェアされます。シェア先サービスのプライバシーポリシーはそれぞれのサービスに準拠します。シェアは任意です。",
          },
          {
            title: "6. 子どものプライバシー",
            body: "本アプリは13歳未満の児童から意図的に情報を収集しません。",
          },
          {
            title: "7. データの削除",
            body: "iOSアプリをアンインストールすることで端末内のすべてのデータが削除されます。Webサービスのデータはブラウザの設定からLocalStorageを消去することで削除できます。",
          },
          {
            title: "8. ポリシーの変更",
            body: "本ポリシーは予告なく変更される場合があります。重大な変更がある場合は、アプリのアップデートノートにてお知らせします。",
          },
          {
            title: "9. お問い合わせ",
            body: null,
            contact: "aioiroba1990@gmail.com",
          },
        ].map((s) => (
          <section key={s.title} className="mb-8">
            <h2 className="text-base font-bold text-app-text mb-2">{s.title}</h2>
            {s.body && <p className="text-app-sub text-sm leading-relaxed">{s.body}</p>}
            {s.contact && (
              <p className="text-app-sub text-sm">
                プライバシーに関するご質問は{" "}
                <a href={`mailto:${s.contact}`} className="text-tiffany">
                  {s.contact}
                </a>{" "}
                までお問い合わせください。
              </p>
            )}
          </section>
        ))}

        <hr className="border-card-border my-8" />

        <h1 className="text-2xl font-bold text-app-text mb-1">Privacy Policy</h1>
        <p className="text-app-gray text-sm mb-8">Last updated: May 6, 2026</p>

        <p className="text-app-sub text-sm leading-relaxed">
          Logicky does not collect or transmit any personal information to external servers.
          All data (learning progress, diagnostic scores) is stored exclusively on your device
          or browser localStorage and is never transmitted externally. The app does not use
          any advertising, analytics, or crash-reporting SDKs. For questions, contact{" "}
          <a href="mailto:aioiroba1990@gmail.com" className="text-tiffany">
            aioiroba1990@gmail.com
          </a>.
        </p>

        <p className="text-app-gray text-xs mt-10">© 2026 Logicky</p>
      </div>
    </div>
  );
}
