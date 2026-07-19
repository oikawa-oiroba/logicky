import type { Metadata } from "next";
import LiteQuiz from "../../components/LiteQuiz";

export const metadata: Metadata = {
  title: "思考のクセ診断（30秒） | Logicky",
  description:
    "9つの2択に答えるだけ。あなたの思考タイプが30秒でわかる、ゆるっと診断。無料・登録不要。",
  openGraph: {
    title: "あなたの「思考のクセ」は？ | 30秒診断",
    description: "9つの2択でわかる思考タイプ診断。コツコツ整理型？ズバッと判断型？",
    type: "website",
  },
  twitter: {
    card: "summary",
    title: "あなたの「思考のクセ」は？ | 30秒診断",
    description: "9つの2択でわかる思考タイプ診断。無料・登録不要。",
  },
};

export default function LitePage() {
  return <LiteQuiz />;
}
