import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "ロジッキー診断 | 論理的思考力テスト",
  description: "14問・3軸評価で論理的思考力を測定。無料で今すぐ診断できます。",
  openGraph: {
    title: "ロジッキー診断 | 論理的思考力テスト",
    description: "14問・3軸評価で論理的思考力を測定。無料で今すぐ診断できます。",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ja">
      <body>{children}</body>
    </html>
  );
}
