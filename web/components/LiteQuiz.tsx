"use client";

import { useState } from "react";
import Link from "next/link";
import { track } from "../lib/analytics";
import { BrainIcon } from "./icons";

// MBTI風の超ライト診断。能力テストではなく「思考のクセ」診断。
// 各質問はどちらを選んだかで 整理/推論/判断 の傾向ポイントが入る。

type Axis = "organize" | "reason" | "judge";

interface LiteQuestion {
  text: string;
  a: { label: string; axis: Axis | null };
  b: { label: string; axis: Axis | null };
}

const QUESTIONS: LiteQuestion[] = [
  {
    text: "PCのデスクトップやフォルダは…",
    a: { label: "カテゴリ別にきちんと整理されている", axis: "organize" },
    b: { label: "雑多。必要なら検索すればいい", axis: null },
  },
  {
    text: "旅行の計画を立てるなら…",
    a: { label: "行程表をしっかり作ってから行く", axis: "organize" },
    b: { label: "現地の気分で決めるのが楽しい", axis: null },
  },
  {
    text: "人に何かを説明するとき…",
    a: { label: "「ポイントは3つ」と分けて話しがち", axis: "organize" },
    b: { label: "思いついた順に熱く語りがち", axis: null },
  },
  {
    text: "SNSでバズっている情報を見たら…",
    a: { label: "「本当に？」とソースを探してしまう", axis: "reason" },
    b: { label: "面白ければまずシェアする", axis: null },
  },
  {
    text: "トラブルが起きたとき…",
    a: { label: "原因を突き止めてから動きたい", axis: "reason" },
    b: { label: "まず動きながら考えたい", axis: null },
  },
  {
    text: "人の話を聞いていて気になるのは…",
    a: { label: "筋が通っているかどうか", axis: "reason" },
    b: { label: "気持ちがこもっているかどうか", axis: null },
  },
  {
    text: "ランチのお店選びは…",
    a: { label: "パッと決める。迷う時間がもったいない", axis: "judge" },
    b: { label: "レビューを見比べてじっくり選ぶ", axis: null },
  },
  {
    text: "仕事や課題が複数重なったら…",
    a: { label: "重要度で優先順位をつけてから着手", axis: "judge" },
    b: { label: "来た順・気分でこなしていく", axis: null },
  },
  {
    text: "買い物で迷ったら…",
    a: { label: "「必要か？」で判断して即決", axis: "judge" },
    b: { label: "一晩寝かせてから考える", axis: null },
  },
];

interface TypeProfile {
  name: string;
  emoji: string;
  catch: string;
  description: string;
  strength: string;
  weakness: string;
}

const TYPES: Record<string, TypeProfile> = {
  organize: {
    name: "コツコツ整理型",
    emoji: "📂",
    catch: "散らかった情報を、秒で構造化する人",
    description:
      "情報をグループ分けし、順序立てて考えるのが得意なタイプ。会議の議事録やマニュアル作りで頼られがち。",
    strength: "資料作成・段取り・情報整理",
    weakness: "完璧に整理してから動きたくなり、スピード勝負に弱いことも",
  },
  reason: {
    name: "じっくり推論型",
    emoji: "🔍",
    catch: "「なぜ？」を3回は繰り返す人",
    description:
      "根拠や因果関係を確かめないと気が済まないタイプ。うのみにしない批判的思考の持ち主。",
    strength: "分析・原因究明・議論の穴を見つけること",
    weakness: "考えすぎて最初の一歩が遅くなることも",
  },
  judge: {
    name: "ズバッと判断型",
    emoji: "⚡",
    catch: "迷いの時間を最小化する人",
    description:
      "優先順位をつけて素早く決断するタイプ。リーダーやまとめ役を任されがち。",
    strength: "意思決定・優先順位づけ・行動力",
    weakness: "たまに根拠が「勘」になりがち。検証はお忘れなく",
  },
  balance: {
    name: "バランス型",
    emoji: "🧠",
    catch: "状況に合わせて思考を切り替える人",
    description:
      "整理・推論・判断をバランスよく使い分けるタイプ。どんなチームでも安定して機能する万能選手。",
    strength: "臨機応変な対応・チームの調整役",
    weakness: "尖った強みを聞かれると答えに迷うかも",
  },
};

function deriveLiteType(scores: Record<Axis, number>): TypeProfile {
  const entries = Object.entries(scores) as [Axis, number][];
  const max = Math.max(...entries.map(([, v]) => v));
  const top = entries.filter(([, v]) => v === max);
  if (top.length !== 1 || max <= 1) return TYPES.balance;
  return TYPES[top[0][0]];
}

export default function LiteQuiz() {
  const [index, setIndex] = useState(-1); // -1 = start screen
  const [scores, setScores] = useState<Record<Axis, number>>({
    organize: 0,
    reason: 0,
    judge: 0,
  });
  const [copied, setCopied] = useState(false);

  const answer = (axis: Axis | null) => {
    if (axis) setScores((s) => ({ ...s, [axis]: s[axis] + 1 }));
    setIndex((i) => i + 1);
  };

  const done = index >= QUESTIONS.length;
  const type = done ? deriveLiteType(scores) : null;

  const share = () => {
    track("share_click", { service: "lite_copy" });
    const text = `私の思考のクセは「${type!.name}」${type!.emoji} でした！\n${type!.catch}\n#ロジッキー #思考のクセ診断\nhttps://logicky.app/lite`;
    if (navigator.share) {
      navigator.share({ text });
    } else {
      navigator.clipboard.writeText(text).then(() => {
        setCopied(true);
        setTimeout(() => setCopied(false), 2500);
      });
    }
  };

  // ── Start ──
  if (index === -1) {
    return (
      <div className="min-h-screen bg-app-bg flex flex-col">
        <div className="flex-1 flex flex-col max-w-md mx-auto w-full px-5 pt-6 pb-6">
          <div className="flex items-center gap-2 mb-8">
            <span className="flex items-center justify-center w-8 h-8 bg-tiffany rounded-lg text-white">
              <BrainIcon size={20} />
            </span>
            <span className="text-xl font-bold text-app-text">Logicky</span>
          </div>
          <h1 className="text-[26px] font-bold text-app-text mb-2.5 leading-snug">
            あなたの「思考のクセ」は？
          </h1>
          <p className="text-app-sub text-[15px] leading-relaxed mb-6">
            9つの2択に答えるだけ。30秒であなたの思考タイプがわかる、
            ゆるっと診断です。
          </p>
          <div className="p-5 bg-white rounded-2xl border border-card-border mb-6">
            <p className="text-xs font-semibold text-app-gray mb-3">診断でわかる4タイプ</p>
            <div className="grid grid-cols-2 gap-2">
              {Object.values(TYPES).map((t) => (
                <div key={t.name} className="flex items-center gap-2 text-sm text-app-text">
                  <span>{t.emoji}</span>
                  <span>{t.name}</span>
                </div>
              ))}
            </div>
          </div>
          <div className="flex-1" />
          <button
            onClick={() => {
              track("quiz_start", { variant: "lite" });
              setIndex(0);
            }}
            className="w-full py-4 bg-tiffany text-white font-bold text-lg rounded-xl shadow-sm active:opacity-90"
          >
            30秒で診断する
          </button>
          <p className="text-center text-xs text-app-gray mt-2.5">
            無料・登録不要・9問
          </p>
        </div>
      </div>
    );
  }

  // ── Quiz ──
  if (!done) {
    const q = QUESTIONS[index];
    return (
      <div className="min-h-screen bg-app-bg">
        <div className="max-w-md mx-auto px-5 py-8">
          <div className="flex justify-between items-center mb-2">
            <span className="text-sm font-semibold text-app-sub">
              Q{index + 1}
              <span className="text-app-gray font-normal"> / {QUESTIONS.length}</span>
            </span>
          </div>
          <div className="h-1.5 bg-card-border rounded-full overflow-hidden mb-8">
            <div
              className="h-full bg-tiffany rounded-full transition-all duration-300"
              style={{ width: `${((index + 1) / QUESTIONS.length) * 100}%` }}
            />
          </div>
          <p className="text-app-text text-lg font-bold leading-relaxed mb-6">{q.text}</p>
          <div className="space-y-3">
            <button
              onClick={() => answer(q.a.axis)}
              className="w-full text-left px-4 py-4 rounded-xl border bg-white border-card-border text-app-text text-sm leading-relaxed hover:border-tiffany hover:bg-tiffany-light active:scale-[0.99] transition-all"
            >
              A. {q.a.label}
            </button>
            <button
              onClick={() => answer(q.b.axis)}
              className="w-full text-left px-4 py-4 rounded-xl border bg-white border-card-border text-app-text text-sm leading-relaxed hover:border-tiffany hover:bg-tiffany-light active:scale-[0.99] transition-all"
            >
              B. {q.b.label}
            </button>
          </div>
        </div>
      </div>
    );
  }

  // ── Result ──
  return (
    <div className="min-h-screen bg-app-bg">
      <div className="max-w-md mx-auto px-5 py-8 space-y-5">
        <p className="text-center text-xs text-app-gray">あなたの思考のクセは…</p>
        <div className="bg-white rounded-2xl border border-card-border p-6 text-center space-y-3">
          <div className="text-5xl">{type!.emoji}</div>
          <h1 className="text-2xl font-black text-tiffany">{type!.name}</h1>
          <p className="text-sm font-semibold text-app-text">{type!.catch}</p>
          <p className="text-sm text-app-sub leading-relaxed">{type!.description}</p>
        </div>
        <div className="bg-white rounded-2xl border border-card-border p-5 space-y-3">
          <div>
            <p className="text-xs font-bold text-tiffany mb-1">💪 得意なこと</p>
            <p className="text-sm text-app-text">{type!.strength}</p>
          </div>
          <div>
            <p className="text-xs font-bold text-app-gray mb-1">🌱 伸びしろ</p>
            <p className="text-sm text-app-sub">{type!.weakness}</p>
          </div>
        </div>

        <button
          onClick={share}
          className="w-full py-3.5 bg-white border border-tiffany text-tiffany font-semibold rounded-xl text-sm"
        >
          結果をシェアする
        </button>
        {copied && (
          <p className="text-center text-xs text-tiffany">コピーしました！SNSに貼り付けてシェアできます</p>
        )}

        <div className="bg-tiffany rounded-2xl p-6 text-white text-center space-y-3">
          <h2 className="text-lg font-bold">実力も測ってみる？</h2>
          <p className="text-sm opacity-90">
            クセがわかったら、次は実力。14問の本格診断で
            整理力・推論力・判断力をスコア化できます。
          </p>
          <Link
            href="/"
            onClick={() => track("cta_click", { from: "lite_result" })}
            className="block w-full py-3.5 bg-white text-tiffany font-bold rounded-xl text-sm active:opacity-90"
          >
            本格診断を受ける（無料・5分）
          </Link>
        </div>

        <button
          onClick={() => {
            setScores({ organize: 0, reason: 0, judge: 0 });
            setIndex(-1);
          }}
          className="w-full py-3 text-app-gray text-sm"
        >
          もう一度診断する
        </button>
      </div>
    </div>
  );
}
