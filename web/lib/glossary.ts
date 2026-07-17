// 診断問題に出てくる専門用語の、高校生向けやさしい解説。
// パターンは長いものから先にマッチさせ、同じ用語の重複表示を防ぐ。

export interface GlossaryEntry {
  label: string;
  description: string;
}

const GLOSSARY: { patterns: string[]; label: string; description: string }[] = [
  {
    patterns: ["三段論法"],
    label: "三段論法（さんだんろんぽう）",
    description: "「ルール」＋「目の前の事実」→「結論」の3ステップで筋道を立てる方法。",
  },
  {
    patterns: ["演繹法", "演繹的", "演繹"],
    label: "演繹（えんえき）",
    description: "すでに分かっているルールに目の前のケースを当てはめて、結論を出す考え方。",
  },
  {
    patterns: ["帰納法", "帰納的", "帰納"],
    label: "帰納（きのう）",
    description: "いくつかの実例に共通する点を見つけて「こういう傾向がある」とまとめる考え方。",
  },
  {
    patterns: ["MECE", "ミーシー"],
    label: "MECE（ミーシー）",
    description: "「モレなく、ダブりなく」分けること。",
  },
  {
    patterns: ["アナロジー"],
    label: "アナロジー",
    description: "似ているものにたとえて考えること。「これは〇〇と同じ仕組みだ」と気づく力。",
  },
  {
    patterns: ["抽象化"],
    label: "抽象化（ちゅうしょうか）",
    description: "細かい違いをいったん省いて、共通する本質だけを取り出すこと。",
  },
  {
    patterns: ["具体化"],
    label: "具体化（ぐたいか）",
    description: "ぼんやりした話を、数字や行動のレベルまではっきりさせること。",
  },
  {
    patterns: ["仮説思考", "仮説を立て", "仮説"],
    label: "仮説（かせつ）",
    description: "「たぶんこうでは？」という仮の答え。先に予想を立ててから確かめにいくと速い。",
  },
  {
    patterns: ["大前提"],
    label: "大前提（だいぜんてい）",
    description: "もとになるルールや決まりのこと。",
  },
  {
    patterns: ["小前提"],
    label: "小前提（しょうぜんてい）",
    description: "目の前の具体的な事実のこと。",
  },
  {
    patterns: ["論理的帰結"],
    label: "論理的帰結（ろんりてききけつ）",
    description: "筋道どおりに考えたとき、必ずそうなる結論のこと。",
  },
  {
    patterns: ["網羅的", "網羅"],
    label: "網羅（もうら）",
    description: "モレなく全部カバーしていること。",
  },
  {
    patterns: ["切り口"],
    label: "切り口（きりくち）",
    description: "分けたり比べたりするときの「基準・軸」のこと。",
  },
  {
    patterns: ["So What?", "So What"],
    label: "So What?（ソーワット）",
    description: "「つまり、何が言えるの？」と一歩先まで考えること。",
  },
  {
    patterns: ["5W2H"],
    label: "5W2H",
    description: "いつ・どこで・誰が・何を・なぜ・どうやって・いくらで、の7つで整理する型。",
  },
  {
    patterns: ["ピラミッドストラクチャー", "ピラミッド原則", "ピラミッド構造"],
    label: "ピラミッド原則",
    description: "結論を先に言い、その下に理由を積み上げる伝え方。",
  },
  {
    patterns: ["ロジックツリー"],
    label: "ロジックツリー",
    description: "大きな問題を、木の枝のように小さく分解して整理する図。",
  },
  {
    patterns: ["構造化"],
    label: "構造化（こうぞうか）",
    description: "バラバラの情報を、分かりやすい形に整理すること。",
  },
  {
    patterns: ["批判的思考", "クリティカルシンキング"],
    label: "批判的思考",
    description: "うのみにせず「本当にそう？」と確かめながら考えること。",
  },
  {
    patterns: ["フレームワーク"],
    label: "フレームワーク",
    description: "考えるときに使える「型」や「テンプレート」のこと。",
  },
];

// body・選択肢のテキストから登場する用語を検出して返す
export function findGlossaryEntries(texts: string[]): GlossaryEntry[] {
  const joined = texts.join(" ");
  const found: GlossaryEntry[] = [];
  for (const entry of GLOSSARY) {
    if (entry.patterns.some((p) => joined.includes(p))) {
      found.push({ label: entry.label, description: entry.description });
    }
  }
  return found;
}
