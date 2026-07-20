"use client";

import { useState, useEffect, useCallback, useRef } from "react";
import questionsRaw from "../data/questions.json";
import {
  BrainIcon,
  ClockIcon,
  ZapIcon,
  SmartphoneIcon,
  AwardIcon,
  TargetIcon,
  CheckIcon,
  XMarkIcon,
  CopyIcon,
  DownloadIcon,
  UserIcon,
  XBrandIcon,
  FacebookIcon,
  LineIcon,
  SlackIcon,
  DiscordIcon,
  LightbulbIcon,
  ChevronDownIcon,
  MessageSquareIcon,
} from "./icons";
import {
  rankLabel,
  rankDescription,
  deriveTypeName,
  scoreColor,
  RAINBOW_COLORS,
} from "../lib/rank";
import { findGlossaryEntries } from "../lib/glossary";
import { track, captureUtm } from "../lib/analytics";

// ─── Types ───────────────────────────────────────────────────────────────────

interface Choice {
  id: string;
  text: string;
}

interface Question {
  id: string;
  unit: string;
  title: string;
  body: string;
  choices: Choice[];
  correctChoiceId: string;
  explanation: string;
}

interface UnitResult {
  unit: string;
  correct: boolean;
}

interface AnswerRecord {
  question: Question;
  selectedChoiceId: string;
  correct: boolean;
}

interface DiagnosticResult {
  totalScore: number;
  organizeScore: number;
  reasonScore: number;
  judgeScore: number;
  unitResults: UnitResult[];
  answers: AnswerRecord[];
  date: Date;
}

interface StoredResult {
  totalScore: number;
  organizeScore: number;
  reasonScore: number;
  judgeScore: number;
  date: string;
}

type Phase = "start" | "quiz" | "result";

// ─── Constants ───────────────────────────────────────────────────────────────

const BASIC_UNITS = [
  "grouping", "why_deep", "syllogism", "induction", "analogy",
  "comparison", "abstraction", "hypothesis", "whole_part",
  "sequencing", "fact_opinion", "pyramid", "so_what", "5w2h",
];

const UNIT_DISPLAY: Record<string, string> = {
  grouping:     "仲間分けする力",
  why_deep:     "原因を深掘りする力",
  syllogism:    "筋道を組み立てる力",
  induction:    "共通点から法則を見つける力",
  analogy:      "似ている例から考える力",
  comparison:   "違いを見つける力",
  abstraction:  "抽象と具体を行き来する力",
  hypothesis:   "まず予想してみる力",
  whole_part:   "全体と部分を切り替える力",
  sequencing:   "ステップで考える力",
  fact_opinion: "事実を見抜く力",
  pyramid:      "結論から伝える力",
  so_what:      "だから何？を導く力",
  "5w2h":       "具体的に伝える力",
};

const UNIT_NAME: Record<string, string> = {
  grouping:     "分類・グルーピング",
  why_deep:     "なぜなぜ分析",
  syllogism:    "三段論法",
  induction:    "帰納法",
  analogy:      "アナロジー思考",
  comparison:   "対比・比較",
  abstraction:  "抽象化と具体化",
  hypothesis:   "仮説思考",
  whole_part:   "ズームイン・ズームアウト",
  sequencing:   "順序立て・プロセス思考",
  fact_opinion: "事実と意見",
  pyramid:      "ピラミッド原則",
  so_what:      "So What?",
  "5w2h":       "5W2H",
};

const ORGANIZE_UNITS = ["grouping", "comparison", "abstraction", "whole_part", "sequencing"];
const REASON_UNITS = ["syllogism", "induction", "why_deep", "hypothesis", "analogy"];
const JUDGE_UNITS = ["fact_opinion", "pyramid", "so_what", "5w2h"];

const STORAGE_KEY = "logicky_web_diagnostic_last";

// App Store公開後にVercelの環境変数 NEXT_PUBLIC_APP_STORE_URL を設定して再デプロイする。
// 未設定の間はCTA押下時に「準備中」の案内を表示する。
const APP_STORE_URL = process.env.NEXT_PUBLIC_APP_STORE_URL ?? "";

const SITE_URL = "https://logicky.app";

// ─── Helpers ─────────────────────────────────────────────────────────────────

function pickOne<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

function calcScores(unitResults: UnitResult[]) {
  const correct = (units: string[]) => {
    const relevant = unitResults.filter((r) => units.includes(r.unit));
    const cnt = relevant.filter((r) => r.correct).length;
    return relevant.length > 0 ? Math.round((cnt / relevant.length) * 100) : 0;
  };
  const total = unitResults.length > 0
    ? Math.round((unitResults.filter((r) => r.correct).length / unitResults.length) * 100)
    : 0;
  return {
    totalScore: total,
    organizeScore: correct(ORGANIZE_UNITS),
    reasonScore: correct(REASON_UNITS),
    judgeScore: correct(JUDGE_UNITS),
  };
}

function buildShareQuery(result: DiagnosticResult, nickname: string): string {
  const q = new URLSearchParams({
    t: String(result.totalScore),
    o: String(result.organizeScore),
    r: String(result.reasonScore),
    j: String(result.judgeScore),
  });
  if (nickname) q.set("n", nickname);
  return q.toString();
}

function buildShareUrl(result: DiagnosticResult, nickname: string): string {
  return `${SITE_URL}/r?${buildShareQuery(result, nickname)}`;
}

function buildShareText(result: DiagnosticResult, nickname: string): string {
  const who = nickname ? `${nickname}さんの` : "";
  return `${who}ロジッキー診断結果：${result.totalScore}点（${rankLabel(result.totalScore)}ランク）
整理力${result.organizeScore}% / 推論力${result.reasonScore}% / 判断力${result.judgeScore}%
#ロジッキー #論理的思考力
${buildShareUrl(result, nickname)}`;
}

// ─── Sub-components ──────────────────────────────────────────────────────────

function ScoreCircle({ score, animate }: { score: number; animate: boolean }) {
  const radius = 52;
  const circumference = 2 * Math.PI * radius;
  const offset = animate ? circumference * (1 - score / 100) : circumference;
  const isPerfect = score >= 100;
  const strokeValue = isPerfect ? "url(#rainbowRing)" : scoreColor(score);

  return (
    <div className="relative flex items-center justify-center w-40 h-40 mx-auto">
      <svg className="absolute" width="160" height="160" viewBox="0 0 160 160">
        {isPerfect && (
          <defs>
            <linearGradient id="rainbowRing" x1="0%" y1="0%" x2="100%" y2="100%">
              {RAINBOW_COLORS.map((c, i) => (
                <stop
                  key={i}
                  offset={`${(i / (RAINBOW_COLORS.length - 1)) * 100}%`}
                  stopColor={c}
                />
              ))}
            </linearGradient>
          </defs>
        )}
        <circle cx="80" cy="80" r={radius} fill="none" stroke="#E5E7EB" strokeWidth="10" />
        <circle
          cx="80" cy="80" r={radius}
          fill="none"
          stroke={strokeValue}
          strokeWidth="10"
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={offset}
          transform="rotate(-90 80 80)"
          style={{ transition: animate ? "stroke-dashoffset 1.2s ease-out" : "none" }}
        />
      </svg>
      <div className="flex flex-col items-center">
        <span className="text-4xl font-bold text-app-text">{score}</span>
        <span className="text-xs text-app-sub">/ 100点</span>
      </div>
    </div>
  );
}

function AxisBar({ label, score, delay }: { label: string; score: number; delay: number }) {
  const [filled, setFilled] = useState(false);
  useEffect(() => {
    const t = setTimeout(() => setFilled(true), delay);
    return () => clearTimeout(t);
  }, [delay]);

  const barStyle =
    score >= 100
      ? { backgroundImage: `linear-gradient(90deg, ${RAINBOW_COLORS.join(", ")})` }
      : { backgroundColor: scoreColor(score) };

  return (
    <div className="space-y-1.5">
      <div className="flex justify-between text-sm">
        <span className="text-app-sub">{label}</span>
        <span className="font-semibold" style={{ color: scoreColor(score) }}>{score}%</span>
      </div>
      <div className="h-2 bg-card-border rounded-full overflow-hidden">
        <div
          className="h-full rounded-full transition-all duration-700 ease-out"
          style={{ width: filled ? `${score}%` : "0%", ...barStyle }}
        />
      </div>
    </div>
  );
}

// ─── Screens ─────────────────────────────────────────────────────────────────

function PreviewAxisBar({ label, score }: { label: string; score: number }) {
  const barStyle =
    score >= 100
      ? { backgroundImage: `linear-gradient(90deg, ${RAINBOW_COLORS.join(", ")})` }
      : { backgroundColor: scoreColor(score) };
  return (
    <div className="flex items-center gap-2.5">
      <span className="w-12 shrink-0 text-xs text-app-sub">{label}</span>
      <div className="flex-1 h-2 bg-card-border rounded-full overflow-hidden">
        <div className="h-full rounded-full" style={{ width: `${score}%`, ...barStyle }} />
      </div>
      <span
        className="w-7 shrink-0 text-right text-xs font-semibold"
        style={{ color: scoreColor(score) }}
      >
        {score}
      </span>
    </div>
  );
}

// ファーストビューの結果プレビュー。再訪ユーザーには前回の実結果を表示する
function ResultPreviewCard({ previous }: { previous: StoredResult | null }) {
  const sample = { total: 74, organize: 72, reason: 88, judge: 61 };
  const s = previous
    ? {
        total: previous.totalScore,
        organize: previous.organizeScore,
        reason: previous.reasonScore,
        judge: previous.judgeScore,
      }
    : sample;
  const typeName = deriveTypeName(s.organize, s.reason, s.judge);

  return (
    <div className="p-5 bg-white rounded-2xl border border-card-border">
      <div className="flex items-center justify-between mb-3.5">
        <span className="text-xs font-semibold text-app-gray tracking-wide">
          {previous ? "前回のあなたの結果" : "診断結果イメージ（サンプル）"}
        </span>
        <span className="px-2.5 py-1 bg-tiffany-light text-tiffany text-xs font-semibold rounded-full">
          {typeName}
        </span>
      </div>
      <div className="flex items-center gap-5">
        <div
          className="shrink-0 flex items-center justify-center w-[88px] h-[88px] rounded-full p-1"
          style={
            s.total >= 100
              ? { background: `conic-gradient(${RAINBOW_COLORS.join(", ")})` }
              : { background: scoreColor(s.total) }
          }
        >
          <div className="flex flex-col items-center justify-center w-full h-full rounded-full bg-white">
            <span className="text-2xl font-bold text-app-text leading-none">{s.total}</span>
            <span className="text-xs font-bold mt-1" style={{ color: scoreColor(s.total) }}>
              {rankLabel(s.total)}
            </span>
          </div>
        </div>
        <div className="flex-1 space-y-2.5">
          <PreviewAxisBar label="整理力" score={s.organize} />
          <PreviewAxisBar label="推論力" score={s.reason} />
          <PreviewAxisBar label="判断力" score={s.judge} />
        </div>
      </div>
    </div>
  );
}

function StartScreen({
  previous,
  onStart,
}: {
  previous: StoredResult | null;
  onStart: () => void;
}) {
  useEffect(() => {
    track("fv_view");
  }, []);

  const chips = [
    { icon: <ClockIcon size={14} />, text: "14問・約5分" },
    { icon: <UserIcon size={14} />, text: "登録不要" },
    { icon: <ZapIcon size={14} />, text: "結果はすぐに表示" },
  ];

  return (
    <div className="min-h-screen bg-app-bg flex flex-col">
      <div className="flex-1 flex flex-col max-w-md mx-auto w-full px-5 pt-6 pb-6">
        {/* 1. Logo */}
        <div className="flex items-center gap-2 mb-6">
          <span className="flex items-center justify-center w-8 h-8 bg-tiffany rounded-lg text-white">
            <BrainIcon size={20} />
          </span>
          <span className="text-xl font-bold text-app-text">Logicky</span>
        </div>

        {/* 2. Headline */}
        <h1 className="text-[26px] font-bold text-app-text mb-2.5 leading-snug">
          あなたの思考力は、いま何点？
        </h1>

        {/* 3. Description */}
        <p className="text-app-sub text-[15px] leading-relaxed mb-5">
          14問で、考える力を「整理・推論・判断」の3軸で測定。
          あなたの強みと、つまずきやすい思考パターンが分かります。
        </p>

        {/* 4. Result preview */}
        <ResultPreviewCard previous={previous} />

        {/* 5. Supplementary chips */}
        <div className="flex gap-1.5 flex-wrap mt-4">
          {chips.map((c) => (
            <div
              key={c.text}
              className="flex items-center gap-1 px-2.5 py-1 bg-white rounded-full border border-card-border text-xs text-app-sub"
            >
              <span className="text-tiffany">{c.icon}</span>
              <span>{c.text}</span>
            </div>
          ))}
        </div>

        <div className="h-6" />

        {/* 6. CTA */}
        <button
          onClick={() => {
            track("cta_click");
            onStart();
          }}
          className="w-full py-4 bg-tiffany text-white font-bold text-lg rounded-xl shadow-sm active:opacity-90 transition-opacity"
        >
          {previous ? "もう一度、無料で診断する" : "無料で診断する"}
        </button>

        <p className="text-center text-xs text-app-gray mt-2.5">
          登録不要・約5分・結果はすぐに表示
        </p>
      </div>
    </div>
  );
}

function QuizScreen({
  questions,
  currentIndex,
  onAnswer,
}: {
  questions: Question[];
  currentIndex: number;
  onAnswer: (choiceId: string) => void;
}) {
  const [selected, setSelected] = useState<string | null>(null);
  const [showFeedback, setShowFeedback] = useState(false);

  const q = questions[currentIndex];
  const progress = ((currentIndex + 1) / questions.length) * 100;
  const glossary = findGlossaryEntries([q.body, ...q.choices.map((c) => c.text)]);
  const isLast = currentIndex + 1 >= questions.length;

  useEffect(() => {
    setSelected(null);
    setShowFeedback(false);
    track("question_view", { index: currentIndex + 1 });
  }, [currentIndex]);

  const handleSelect = (choiceId: string) => {
    if (selected !== null) return;
    setSelected(choiceId);
    setShowFeedback(true);
  };

  // 「次へ」で明示的に進む。ローカル状態を先にリセットしてから親に通知することで、
  // 次の問題に前の選択状態が一瞬残る問題を防ぐ
  const handleNext = () => {
    if (selected === null) return;
    const choiceId = selected;
    setSelected(null);
    setShowFeedback(false);
    onAnswer(choiceId);
  };

  const choiceClass = (choiceId: string): string => {
    if (!showFeedback) return "choice-btn choice-default";
    if (choiceId === q.correctChoiceId) {
      return selected === choiceId
        ? "choice-btn choice-correct"
        : "choice-btn choice-correct-reveal";
    }
    if (choiceId === selected) return "choice-btn choice-wrong";
    return "choice-btn bg-white border-card-border text-app-sub opacity-50";
  };

  return (
    <div className="min-h-screen bg-app-bg flex flex-col">
      <div className="max-w-md mx-auto w-full px-5 py-6 flex flex-col min-h-screen">
        {/* Header */}
        <div className="mb-6">
          <div className="flex justify-between items-center mb-2">
            <span className="text-sm font-semibold text-app-sub">
              Q{currentIndex + 1}
              <span className="text-app-gray font-normal"> / {questions.length}</span>
            </span>
            <span className="text-xs text-app-sub">{UNIT_NAME[q.unit]}</span>
          </div>
          <div className="h-1.5 bg-card-border rounded-full overflow-hidden">
            <div
              className="h-full bg-tiffany rounded-full transition-all duration-500"
              style={{ width: `${progress}%` }}
            />
          </div>
        </div>

        {/* Question */}
        <div key={q.id} className="animate-fade-up">
          <div className="text-xs font-semibold text-tiffany mb-2 uppercase tracking-wide">
            {UNIT_DISPLAY[q.unit]}
          </div>
          <p className="text-app-text text-base font-medium leading-relaxed mb-4">
            {q.body}
          </p>

          {/* ことばのヒント */}
          {glossary.length > 0 && (
            <div className="mb-5 p-3.5 bg-amber-50 border border-amber-200 rounded-xl space-y-1.5">
              <div className="flex items-center gap-1.5 text-amber-600 text-xs font-bold">
                <LightbulbIcon size={14} />
                <span>ことばのヒント</span>
              </div>
              {glossary.map((g) => (
                <p key={g.label} className="text-xs text-amber-800 leading-relaxed">
                  <span className="font-semibold">{g.label}</span>
                  <span className="mx-1">…</span>
                  {g.description}
                </p>
              ))}
            </div>
          )}

          {/* Choices */}
          <div className="space-y-3">
            {q.choices.map((c) => (
              <button
                key={c.id}
                className={choiceClass(c.id)}
                onClick={() => handleSelect(c.id)}
                disabled={showFeedback}
              >
                <span className="inline-flex items-start gap-2">
                  <span className="shrink-0 w-5 h-5 rounded-full border border-current flex items-center justify-center text-xs font-bold mt-0.5">
                    {c.id.toUpperCase()}
                  </span>
                  <span>{c.text}</span>
                </span>
              </button>
            ))}
          </div>

          {/* Explanation & next */}
          {showFeedback && (
            <div className="animate-fade-up">
              {q.explanation && (
                <div className="mt-4 p-3.5 bg-tiffany-light border border-tiffany/30 rounded-xl">
                  <p className="text-sm text-tiffany leading-relaxed">{q.explanation}</p>
                </div>
              )}
              <button
                onClick={handleNext}
                className="w-full mt-4 py-3.5 bg-tiffany text-white font-bold rounded-xl text-base active:opacity-90 transition-opacity"
              >
                {isLast ? "結果を見る" : "次の問題へ"}
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

const FEEDBACK_CATEGORIES = ["わかりづらい", "答えが違うと思う", "誤字・脱字", "その他"];

function FeedbackForm({ answer }: { answer: AnswerRecord }) {
  const [open, setOpen] = useState(false);
  const [category, setCategory] = useState<string | null>(null);
  const [comment, setComment] = useState("");
  const [status, setStatus] = useState<"idle" | "sending" | "done" | "error">("idle");

  const submit = async () => {
    if (!category || status === "sending") return;
    setStatus("sending");
    try {
      const res = await fetch("/api/feedback", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          questionId: answer.question.id,
          unit: answer.question.unit,
          category,
          comment,
          selectedChoiceId: answer.selectedChoiceId,
        }),
      });
      setStatus(res.ok ? "done" : "error");
      if (res.ok) {
        track("feedback_submit", { question_id: answer.question.id, category });
      }
    } catch {
      setStatus("error");
    }
  };

  if (status === "done") {
    return (
      <p className="text-xs text-tiffany py-1.5">
        フィードバックを送信しました。改善に活用します。ありがとうございます！
      </p>
    );
  }

  if (!open) {
    return (
      <button
        onClick={() => setOpen(true)}
        className="flex items-center gap-1.5 text-xs text-app-gray underline underline-offset-2 py-1"
      >
        <MessageSquareIcon size={13} />
        この問題について意見を送る（わかりづらい・答えが違う 等）
      </button>
    );
  }

  return (
    <div className="space-y-2 p-3 bg-gray-50 rounded-lg">
      <div className="flex flex-wrap gap-1.5">
        {FEEDBACK_CATEGORIES.map((c) => (
          <button
            key={c}
            onClick={() => setCategory(c)}
            className={`px-2.5 py-1 rounded-full text-xs border transition-colors ${
              category === c
                ? "bg-tiffany text-white border-tiffany"
                : "bg-white text-app-sub border-card-border"
            }`}
          >
            {c}
          </button>
        ))}
      </div>
      <textarea
        value={comment}
        onChange={(e) => setComment(e.target.value)}
        maxLength={500}
        rows={2}
        placeholder="詳しく教えてもらえると助かります（任意）"
        className="w-full text-xs text-app-text placeholder:text-app-gray p-2.5 bg-white border border-card-border rounded-lg outline-none resize-none"
      />
      <div className="flex items-center gap-2">
        <button
          onClick={submit}
          disabled={!category || status === "sending"}
          className="px-4 py-1.5 bg-tiffany text-white text-xs font-semibold rounded-lg disabled:opacity-40"
        >
          {status === "sending" ? "送信中…" : "送信する"}
        </button>
        <button
          onClick={() => setOpen(false)}
          className="px-3 py-1.5 text-xs text-app-gray"
        >
          閉じる
        </button>
        {status === "error" && (
          <span className="text-xs text-red-500">送信に失敗しました。もう一度お試しください</span>
        )}
      </div>
    </div>
  );
}

function ReviewItem({ answer, index }: { answer: AnswerRecord; index: number }) {
  const [open, setOpen] = useState(false);
  const q = answer.question;
  const selectedText = q.choices.find((c) => c.id === answer.selectedChoiceId)?.text ?? "";
  const correctText = q.choices.find((c) => c.id === q.correctChoiceId)?.text ?? "";

  return (
    <div className="border border-card-border rounded-xl overflow-hidden">
      <button
        onClick={() => setOpen((o) => !o)}
        className="w-full flex items-center gap-2.5 p-3 bg-white text-left"
      >
        <span
          className={`shrink-0 flex items-center justify-center w-6 h-6 rounded-full ${
            answer.correct ? "bg-tiffany-light text-tiffany" : "bg-red-50 text-red-400"
          }`}
        >
          {answer.correct ? <CheckIcon size={13} /> : <XMarkIcon size={13} />}
        </span>
        <span className="flex-1 min-w-0">
          <span className="block text-xs text-app-gray">Q{index + 1} · {UNIT_DISPLAY[q.unit]}</span>
          <span className="block text-sm text-app-text truncate">{q.body}</span>
        </span>
        <ChevronDownIcon
          size={16}
          className={`shrink-0 text-app-gray transition-transform ${open ? "rotate-180" : ""}`}
        />
      </button>

      {open && (
        <div className="px-3 pb-3 pt-1 bg-white space-y-2.5">
          <p className="text-sm text-app-text leading-relaxed">{q.body}</p>
          {!answer.correct && (
            <div className="text-xs p-2.5 bg-red-50 rounded-lg text-red-500 leading-relaxed">
              あなたの回答：{selectedText}
            </div>
          )}
          <div className="text-xs p-2.5 bg-tiffany-light rounded-lg text-tiffany leading-relaxed">
            正解：{correctText}
          </div>
          {q.explanation && (
            <p className="text-xs text-app-sub leading-relaxed">{q.explanation}</p>
          )}
          <FeedbackForm answer={answer} />
        </div>
      )}
    </div>
  );
}

function ReviewSection({ answers }: { answers: AnswerRecord[] }) {
  return (
    <div className="bg-white rounded-2xl border border-card-border p-5">
      <h2 className="font-bold text-app-text mb-1">回答のふりかえり</h2>
      <p className="text-xs text-app-gray mb-4">
        タップすると解説が見られます。「わかりづらい」等の意見も送れます。
      </p>
      <div className="space-y-2">
        {answers.map((a, i) => (
          <ReviewItem key={a.question.id} answer={a} index={i} />
        ))}
      </div>
    </div>
  );
}

// 診断結果に基づき、最も伸びしろのある軸に合わせてアプリへ誘導する
function AppFunnelSection({ result }: { result: DiagnosticResult }) {
  const [showPreparing, setShowPreparing] = useState(false);

  useEffect(() => {
    track("app_cta_view");
  }, []);

  const axes = [
    { name: "整理力", score: result.organizeScore },
    { name: "推論力", score: result.reasonScore },
    { name: "判断力", score: result.judgeScore },
  ];
  const strongest = axes.reduce((a, b) => (b.score > a.score ? b : a));
  const weakest = axes.reduce((a, b) => (b.score < a.score ? b : a));
  const balanced = strongest.score - weakest.score <= 10;

  const message = balanced
    ? "3つの力がバランスよく育っています。次は全体の底上げに挑戦しましょう。"
    : `あなたは「${strongest.name}」が強い一方で、「${weakest.name}」には伸びしろがあります。`;
  const subMessage = balanced
    ? "ロジッキーアプリでは、毎日3分の問題で3つの力をまんべんなくトレーニングできます。"
    : `ロジッキーアプリでは、毎日3分の問題で「${weakest.name}」を重点的にトレーニングできます。`;
  const ctaLabel = balanced ? "アプリでトレーニングを始める" : "苦手分野をアプリで鍛える";

  const onCtaClick = () => {
    track("app_cta_click", { weakest_axis: weakest.name, has_store_url: !!APP_STORE_URL });
    if (APP_STORE_URL) {
      window.open(APP_STORE_URL, "_blank", "noopener,noreferrer");
    } else {
      setShowPreparing(true);
    }
  };

  return (
    <div className="bg-white rounded-2xl border border-card-border p-5 space-y-3.5">
      <div className="flex items-center gap-1.5 text-xs font-semibold text-app-gray tracking-wide">
        <SmartphoneIcon size={14} className="text-tiffany" />
        <span>次のステップ</span>
      </div>
      <p className="text-app-text text-base font-bold leading-relaxed">{message}</p>
      <p className="text-app-sub text-sm leading-relaxed">{subMessage}</p>
      <button
        onClick={onCtaClick}
        className="w-full py-3.5 bg-tiffany text-white font-bold rounded-xl text-sm active:opacity-90 transition-opacity"
      >
        {ctaLabel}
      </button>
      {showPreparing ? (
        <p className="text-center text-xs text-app-sub animate-fade-up">
          アプリは現在準備中です。公開までもう少しお待ちください。
          それまではWeb診断の「回答のふりかえり」で復習できます。
        </p>
      ) : (
        <p className="text-center text-xs text-app-gray">
          毎日のトレーニング・成長の記録・再診断はアプリで
        </p>
      )}
    </div>
  );
}

const NICKNAME_KEY = "logicky_web_nickname";

function ShareSection({ result }: { result: DiagnosticResult }) {
  const [nickname, setNickname] = useState("");
  const [previewNickname, setPreviewNickname] = useState("");
  const [copiedFor, setCopiedFor] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const copyTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    try {
      const saved = localStorage.getItem(NICKNAME_KEY);
      if (saved) {
        setNickname(saved);
        setPreviewNickname(saved);
      }
    } catch {}
  }, []);

  // 入力が落ち着いてからプレビュー画像を更新（600msデバウンス）
  useEffect(() => {
    const t = setTimeout(() => {
      setPreviewNickname(nickname);
      try {
        localStorage.setItem(NICKNAME_KEY, nickname);
      } catch {}
    }, 600);
    return () => clearTimeout(t);
  }, [nickname]);

  useEffect(() => {
    return () => {
      if (copyTimerRef.current) clearTimeout(copyTimerRef.current);
    };
  }, []);

  const trimmed = previewNickname.trim().slice(0, 20);
  const text = buildShareText(result, trimmed);
  const shareUrl = buildShareUrl(result, trimmed);
  const cardUrl = `/api/og?${buildShareQuery(result, trimmed)}`;

  const copyFor = (service: string) => {
    track("share_click", { service: service.toLowerCase() });
    navigator.clipboard.writeText(text).then(() => {
      setCopiedFor(service);
      if (copyTimerRef.current) clearTimeout(copyTimerRef.current);
      copyTimerRef.current = setTimeout(() => setCopiedFor(null), 2500);
    });
  };

  const openWindow = (url: string) =>
    window.open(url, "_blank", "noopener,noreferrer");

  const openX = () => {
    track("share_click", { service: "x" });
    openWindow(`https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}`);
  };

  const openLine = () => {
    track("share_click", { service: "line" });
    openWindow(`https://line.me/R/share?text=${encodeURIComponent(text)}`);
  };

  const openFacebook = () => {
    track("share_click", { service: "facebook" });
    openWindow(`https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(shareUrl)}`);
  };

  const saveImage = async () => {
    track("share_click", { service: "image_save" });
    setSaving(true);
    try {
      const blob = await (await fetch(cardUrl)).blob();
      const file = new File([blob], "logicky_result.png", { type: "image/png" });
      if (navigator.canShare?.({ files: [file] })) {
        await navigator.share({ files: [file], text });
      } else {
        const a = document.createElement("a");
        a.href = URL.createObjectURL(blob);
        a.download = "logicky_result.png";
        a.click();
        URL.revokeObjectURL(a.href);
      }
    } catch {
    } finally {
      setSaving(false);
    }
  };

  const btnClass =
    "flex flex-col items-center gap-1.5 py-3 bg-white border border-card-border rounded-xl text-[11px] font-medium text-app-sub active:opacity-80 transition-opacity";

  return (
    <div className="space-y-3">
      <h2 className="font-bold text-app-text text-sm">結果をシェア</h2>

      {/* Nickname */}
      <div className="flex items-center gap-2 px-3.5 py-2.5 bg-white border border-card-border rounded-xl">
        <UserIcon size={16} className="text-app-gray shrink-0" />
        <input
          type="text"
          value={nickname}
          onChange={(e) => setNickname(e.target.value)}
          maxLength={20}
          placeholder="ニックネーム・Xの名前（任意）"
          className="flex-1 text-sm text-app-text placeholder:text-app-gray outline-none bg-transparent"
        />
      </div>

      {/* Card preview */}
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img
        key={cardUrl}
        src={cardUrl}
        alt="シェアされる結果カードのプレビュー"
        className="w-full rounded-xl border border-card-border"
      />

      <div className="grid grid-cols-5 gap-2">
        <button onClick={openX} className={btnClass} aria-label="Xでシェア">
          <XBrandIcon size={20} className="text-app-text" />
          <span>X</span>
        </button>
        <button onClick={openLine} className={btnClass} aria-label="LINEでシェア">
          <LineIcon size={20} className="text-[#06C755]" />
          <span>LINE</span>
        </button>
        <button onClick={openFacebook} className={btnClass} aria-label="Facebookでシェア">
          <FacebookIcon size={20} className="text-[#0866FF]" />
          <span>Facebook</span>
        </button>
        <button onClick={() => copyFor("Slack")} className={btnClass} aria-label="Slack用にコピー">
          <SlackIcon size={20} className="text-[#4A154B]" />
          <span>Slack</span>
        </button>
        <button onClick={() => copyFor("Discord")} className={btnClass} aria-label="Discord用にコピー">
          <DiscordIcon size={20} className="text-[#5865F2]" />
          <span>Discord</span>
        </button>
      </div>

      <button
        onClick={saveImage}
        disabled={saving}
        className="w-full flex items-center justify-center gap-2 py-3 bg-white border border-tiffany text-tiffany font-semibold rounded-xl text-sm active:opacity-80 disabled:opacity-50"
      >
        <DownloadIcon size={16} />
        {saving ? "画像を生成中…" : "結果カードを画像で保存"}
      </button>

      {copiedFor && (
        <div className="flex items-center gap-1.5 justify-center text-xs text-tiffany py-1 animate-fade-up">
          <CopyIcon size={13} />
          <span>結果をコピーしました。{copiedFor}に貼り付けると結果カードが表示されます</span>
        </div>
      )}
    </div>
  );
}

function ResultScreen({
  result,
  onRetry,
}: {
  result: DiagnosticResult;
  onRetry: () => void;
}) {
  const [displayScore, setDisplayScore] = useState(0);
  const [circleReady, setCircleReady] = useState(false);
  const rank = rankLabel(result.totalScore);
  const desc = rankDescription(result.totalScore);
  const typeName = deriveTypeName(
    result.organizeScore,
    result.reasonScore,
    result.judgeScore
  );

  useEffect(() => {
    track("result_view");
  }, []);

  // Animate score counter
  useEffect(() => {
    let current = 0;
    const target = result.totalScore;
    const increment = Math.ceil(target / 40);
    const t = setInterval(() => {
      current = Math.min(current + increment, target);
      setDisplayScore(current);
      if (current >= target) {
        clearInterval(t);
        setCircleReady(true);
      }
    }, 25);
    return () => clearInterval(t);
  }, [result.totalScore]);

  const strengths = result.unitResults.filter((r) => r.correct).slice(0, 3);
  const weaknesses = result.unitResults.filter((r) => !r.correct).slice(0, 3);

  return (
    <div className="min-h-screen bg-app-bg">
      <div className="max-w-md mx-auto px-5 py-8 space-y-6">
        {/* Logo */}
        <div className="flex items-center gap-2">
          <span className="flex items-center justify-center w-7 h-7 bg-tiffany rounded-lg text-white">
            <BrainIcon size={17} />
          </span>
          <span className="text-base font-bold text-app-text">Logicky</span>
        </div>

        {/* Score card */}
        <div className="bg-white rounded-2xl border border-card-border p-6 text-center space-y-3">
          <ScoreCircle score={displayScore} animate={circleReady} />
          <div>
            <div
              className="text-4xl font-black"
              style={
                result.totalScore >= 100
                  ? {
                      backgroundImage: `linear-gradient(90deg, ${RAINBOW_COLORS.join(", ")})`,
                      WebkitBackgroundClip: "text",
                      WebkitTextFillColor: "transparent",
                    }
                  : { color: scoreColor(result.totalScore) }
              }
            >
              {rank}
            </div>
            <div className="text-sm text-app-sub mt-1">{desc}</div>
            <span className="inline-block mt-2 px-3 py-1 bg-tiffany-light text-tiffany text-xs font-semibold rounded-full">
              {typeName}
            </span>
          </div>
        </div>

        {/* 3-Axis */}
        <div className="bg-white rounded-2xl border border-card-border p-5 space-y-4">
          <h2 className="font-bold text-app-text">3軸評価</h2>
          <AxisBar label="整理力（構造化・分類）" score={result.organizeScore} delay={400} />
          <AxisBar label="推論力（演繹・帰納・仮説）" score={result.reasonScore} delay={600} />
          <AxisBar label="判断力（事実・伝え方・優先度）" score={result.judgeScore} delay={800} />
        </div>

        {/* Unit results grid */}
        <div className="bg-white rounded-2xl border border-card-border p-5">
          <h2 className="font-bold text-app-text mb-4">単元別結果</h2>
          <div className="grid grid-cols-2 gap-2">
            {result.unitResults.map((r) => (
              <div
                key={r.unit}
                className={`flex items-center gap-2 p-2.5 rounded-lg text-xs ${
                  r.correct
                    ? "bg-tiffany-light text-tiffany"
                    : "bg-gray-50 text-app-gray"
                }`}
              >
                <span className="shrink-0">
                  {r.correct ? <CheckIcon size={14} /> : <XMarkIcon size={14} />}
                </span>
                <span className="truncate">{UNIT_DISPLAY[r.unit]}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Review & feedback */}
        <ReviewSection answers={result.answers} />

        {/* Strengths */}
        {strengths.length > 0 && (
          <div className="bg-white rounded-2xl border border-card-border p-5">
            <h2 className="font-bold text-app-text mb-3">得意なスキル</h2>
            <div className="space-y-2">
              {strengths.map((r) => (
                <div key={r.unit} className="flex items-center gap-2 text-sm text-tiffany">
                  <AwardIcon size={16} className="shrink-0" />
                  <span>{UNIT_DISPLAY[r.unit]}</span>
                  <span className="text-xs text-app-gray ml-auto">{UNIT_NAME[r.unit]}</span>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Weaknesses */}
        {weaknesses.length > 0 && (
          <div className="bg-white rounded-2xl border border-card-border p-5">
            <h2 className="font-bold text-app-text mb-3">強化すべきスキル</h2>
            <div className="space-y-2">
              {weaknesses.map((r) => (
                <div key={r.unit} className="flex items-center gap-2 text-sm text-app-sub">
                  <TargetIcon size={16} className="shrink-0 text-tiffany" />
                  <span>{UNIT_DISPLAY[r.unit]}</span>
                  <span className="text-xs text-app-gray ml-auto">{UNIT_NAME[r.unit]}</span>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* App funnel */}
        <AppFunnelSection result={result} />

        {/* Share */}
        <ShareSection result={result} />

        {/* Retry */}
        <button
          onClick={onRetry}
          className="w-full py-3.5 bg-white border border-card-border text-app-sub font-semibold rounded-xl text-sm"
        >
          もう一度診断する
        </button>

        <p className="text-center text-xs text-app-gray pb-4">
          © 2026 Logicky ·{" "}
          <a href="/privacy" className="underline">プライバシーポリシー</a>
        </p>
      </div>
    </div>
  );
}

// ─── Main Component ───────────────────────────────────────────────────────────

export default function DiagnosticApp() {
  const [phase, setPhase] = useState<Phase>("start");
  const [questions, setQuestions] = useState<Question[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [unitResults, setUnitResults] = useState<UnitResult[]>([]);
  const [answers, setAnswers] = useState<AnswerRecord[]>([]);
  const [result, setResult] = useState<DiagnosticResult | null>(null);
  const [previous, setPrevious] = useState<StoredResult | null>(null);

  useEffect(() => {
    captureUtm();
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (raw) setPrevious(JSON.parse(raw));
    } catch {}
  }, []);

  const startDiagnostic = useCallback(() => {
    const all = questionsRaw as Question[];
    const selected = BASIC_UNITS.map((unit) => {
      const pool = all.filter((q) => q.unit === unit);
      return pickOne(pool);
    }).filter(Boolean) as Question[];

    setQuestions(selected);
    setCurrentIndex(0);
    setUnitResults([]);
    setAnswers([]);
    setResult(null);
    setPhase("quiz");
    track("quiz_start");
  }, []);

  const handleAnswer = useCallback(
    (choiceId: string) => {
      const q = questions[currentIndex];
      const correct = choiceId === q.correctChoiceId;
      const newResults = [...unitResults, { unit: q.unit, correct }];
      const newAnswers = [...answers, { question: q, selectedChoiceId: choiceId, correct }];
      setUnitResults(newResults);
      setAnswers(newAnswers);

      if (currentIndex + 1 < questions.length) {
        setCurrentIndex((i) => i + 1);
      } else {
        // Build final result
        const scores = calcScores(newResults);
        const finalResult: DiagnosticResult = {
          ...scores,
          unitResults: newResults,
          answers: newAnswers,
          date: new Date(),
        };
        setResult(finalResult);

        // Persist to localStorage
        const toStore: StoredResult = {
          totalScore: scores.totalScore,
          organizeScore: scores.organizeScore,
          reasonScore: scores.reasonScore,
          judgeScore: scores.judgeScore,
          date: new Date().toISOString(),
        };
        try {
          localStorage.setItem(STORAGE_KEY, JSON.stringify(toStore));
          setPrevious(toStore);
        } catch {}

        track("quiz_complete", { total_score: scores.totalScore });
        setPhase("result");
      }
    },
    [questions, currentIndex, unitResults, answers]
  );

  const handleRetry = useCallback(() => {
    setPhase("start");
  }, []);

  if (phase === "start") {
    return <StartScreen previous={previous} onStart={startDiagnostic} />;
  }

  if (phase === "quiz" && questions.length > 0) {
    return (
      <QuizScreen
        questions={questions}
        currentIndex={currentIndex}
        onAnswer={handleAnswer}
      />
    );
  }

  if (phase === "result" && result) {
    return <ResultScreen result={result} onRetry={handleRetry} />;
  }

  return null;
}
