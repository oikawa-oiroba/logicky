"use client";

import { useState, useEffect, useCallback, useRef } from "react";
import questionsRaw from "../data/questions.json";
import {
  BrainIcon,
  ClockIcon,
  ChartIcon,
  TrendingUpIcon,
  SmartphoneIcon,
  AwardIcon,
  TargetIcon,
  CheckIcon,
  XMarkIcon,
  CopyIcon,
  XBrandIcon,
  FacebookIcon,
  SlackIcon,
  DiscordIcon,
} from "./icons";

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

interface DiagnosticResult {
  totalScore: number;
  organizeScore: number;
  reasonScore: number;
  judgeScore: number;
  unitResults: UnitResult[];
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

// TODO: App Store公開後に実際のApp IDへ差し替える
const APP_STORE_URL = "https://apps.apple.com/jp/app/logicky/id0000000000";

const SITE_URL = "https://logicky.vercel.app";

// ─── Helpers ─────────────────────────────────────────────────────────────────

function pickOne<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

function rankLabel(score: number): string {
  if (score >= 90) return "S";
  if (score >= 80) return "A";
  if (score >= 70) return "B+";
  if (score >= 60) return "B";
  if (score >= 50) return "C";
  return "D";
}

function rankDescription(score: number): string {
  if (score >= 90) return "論理思考のエキスパート";
  if (score >= 80) return "実践レベルの思考力";
  if (score >= 70) return "応用力が身についている";
  if (score >= 60) return "基礎は習得できている";
  if (score >= 50) return "もう少しで基礎レベル";
  return "基礎から鍛え直そう";
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

function buildShareText(result: DiagnosticResult): string {
  return `ロジッキー診断の結果：${result.totalScore}点（${rankLabel(result.totalScore)}ランク）
整理力${result.organizeScore}% / 推論力${result.reasonScore}% / 判断力${result.judgeScore}%
#ロジッキー #論理的思考力
${SITE_URL}`;
}

// ─── Sub-components ──────────────────────────────────────────────────────────

function ScoreCircle({ score, animate }: { score: number; animate: boolean }) {
  const radius = 52;
  const circumference = 2 * Math.PI * radius;
  const offset = animate ? circumference * (1 - score / 100) : circumference;

  return (
    <div className="relative flex items-center justify-center w-40 h-40 mx-auto">
      <svg className="absolute" width="160" height="160" viewBox="0 0 160 160">
        <circle cx="80" cy="80" r={radius} fill="none" stroke="#E5E7EB" strokeWidth="10" />
        <circle
          cx="80" cy="80" r={radius}
          fill="none"
          stroke="#0ABAB5"
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

  return (
    <div className="space-y-1.5">
      <div className="flex justify-between text-sm">
        <span className="text-app-sub">{label}</span>
        <span className="font-semibold text-tiffany">{score}%</span>
      </div>
      <div className="h-2 bg-card-border rounded-full overflow-hidden">
        <div
          className="h-full bg-tiffany rounded-full transition-all duration-700 ease-out"
          style={{ width: filled ? `${score}%` : "0%" }}
        />
      </div>
    </div>
  );
}

// ─── Screens ─────────────────────────────────────────────────────────────────

function StartScreen({
  previous,
  onStart,
}: {
  previous: StoredResult | null;
  onStart: () => void;
}) {
  const chips = [
    { icon: <ClockIcon size={15} />, text: "14問・約5分" },
    { icon: <ChartIcon size={15} />, text: "3軸で評価" },
    { icon: <TrendingUpIcon size={15} />, text: "スキル可視化" },
  ];

  return (
    <div className="min-h-screen bg-app-bg flex flex-col">
      <div className="flex-1 flex flex-col max-w-md mx-auto w-full px-5 py-8">
        {/* Logo */}
        <div className="flex items-center gap-2 mb-8">
          <span className="flex items-center justify-center w-8 h-8 bg-tiffany rounded-lg text-white">
            <BrainIcon size={20} />
          </span>
          <span className="text-xl font-bold text-app-text">Logicky</span>
        </div>

        {/* Hero */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-app-text mb-3 leading-tight">
            ロジッキー<br />診断
          </h1>
          <p className="text-app-sub text-base leading-relaxed">
            論理的思考力を14問で測定。整理・推論・判断の3軸で、
            あなたの得意と苦手を見える化します。
          </p>
        </div>

        {/* Feature chips */}
        <div className="flex gap-2 flex-wrap mb-8">
          {chips.map((c) => (
            <div
              key={c.text}
              className="flex items-center gap-1.5 px-3 py-1.5 bg-white rounded-full border border-card-border text-sm text-app-sub"
            >
              <span className="text-tiffany">{c.icon}</span>
              <span>{c.text}</span>
            </div>
          ))}
        </div>

        {/* Previous result */}
        {previous && (
          <div className="mb-6 p-4 bg-white rounded-xl border border-card-border">
            <div className="flex items-center justify-between mb-2">
              <span className="text-xs text-app-sub">前回の結果</span>
              <span className="text-xs text-app-sub">
                {new Date(previous.date).toLocaleDateString("ja-JP", { month: "long", day: "numeric" })}
              </span>
            </div>
            <div className="flex items-center gap-4">
              <div>
                <span className="text-3xl font-bold text-tiffany">{previous.totalScore}</span>
                <span className="text-app-sub text-sm ml-1">点</span>
              </div>
              <div className="text-2xl font-bold text-app-sub">
                {rankLabel(previous.totalScore)}
              </div>
              <div className="flex-1 text-right">
                <div className="text-xs text-app-sub">整理 {previous.organizeScore}% / 推論 {previous.reasonScore}% / 判断 {previous.judgeScore}%</div>
              </div>
            </div>
          </div>
        )}

        <div className="flex-1" />

        {/* CTA */}
        <button
          onClick={onStart}
          className="w-full py-4 bg-tiffany text-white font-bold text-lg rounded-xl shadow-sm active:opacity-90 transition-opacity"
        >
          {previous ? "再診断する" : "診断を始める"}
        </button>

        <p className="text-center text-xs text-app-gray mt-3">
          無料 · 登録不要 · 約5分
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
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const q = questions[currentIndex];
  const progress = ((currentIndex + 1) / questions.length) * 100;

  useEffect(() => {
    setSelected(null);
    setShowFeedback(false);
  }, [currentIndex]);

  useEffect(() => {
    return () => {
      if (timerRef.current) clearTimeout(timerRef.current);
    };
  }, []);

  const handleSelect = (choiceId: string) => {
    if (selected !== null) return;
    setSelected(choiceId);
    setShowFeedback(true);
    timerRef.current = setTimeout(() => onAnswer(choiceId), 900);
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
          <p className="text-app-text text-base font-medium leading-relaxed mb-6">
            {q.body}
          </p>

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

          {/* Explanation */}
          {showFeedback && q.explanation && (
            <div className="mt-4 p-3.5 bg-tiffany-light border border-tiffany/30 rounded-xl animate-fade-up">
              <p className="text-sm text-tiffany leading-relaxed">{q.explanation}</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

function ShareSection({ result }: { result: DiagnosticResult }) {
  const [copiedFor, setCopiedFor] = useState<string | null>(null);
  const copyTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    return () => {
      if (copyTimerRef.current) clearTimeout(copyTimerRef.current);
    };
  }, []);

  const text = buildShareText(result);

  const copyFor = (service: string) => {
    navigator.clipboard.writeText(text).then(() => {
      setCopiedFor(service);
      if (copyTimerRef.current) clearTimeout(copyTimerRef.current);
      copyTimerRef.current = setTimeout(() => setCopiedFor(null), 2500);
    });
  };

  const openX = () => {
    const url = `https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}`;
    window.open(url, "_blank", "noopener,noreferrer");
  };

  const openFacebook = () => {
    const url = `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(SITE_URL)}&quote=${encodeURIComponent(text)}`;
    window.open(url, "_blank", "noopener,noreferrer");
  };

  const btnClass =
    "flex flex-col items-center gap-1.5 py-3 bg-white border border-card-border rounded-xl text-xs font-medium text-app-sub active:opacity-80 transition-opacity";

  return (
    <div className="space-y-2">
      <h2 className="font-bold text-app-text text-sm">結果をシェア</h2>
      <div className="grid grid-cols-4 gap-2">
        <button onClick={openX} className={btnClass} aria-label="Xでシェア">
          <XBrandIcon size={20} className="text-app-text" />
          <span>X</span>
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
      {copiedFor && (
        <div className="flex items-center gap-1.5 justify-center text-xs text-tiffany py-1 animate-fade-up">
          <CopyIcon size={13} />
          <span>結果をコピーしました。{copiedFor}に貼り付けてシェアできます</span>
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
            <div className="text-4xl font-black text-tiffany">{rank}</div>
            <div className="text-sm text-app-sub mt-1">{desc}</div>
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

        {/* App CTA */}
        <div className="bg-tiffany rounded-2xl p-6 text-white text-center space-y-4">
          <div className="flex justify-center">
            <SmartphoneIcon size={28} />
          </div>
          <div>
            <h2 className="text-lg font-bold mb-1">毎日5問で論理力を鍛えよう</h2>
            <p className="text-sm opacity-90">
              アプリでは単元別トレーニング・成長記録・思考法辞典など
              フル機能が使えます。
            </p>
          </div>
          <a
            href={APP_STORE_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="block w-full py-3.5 bg-white text-tiffany font-bold rounded-xl text-sm active:opacity-90"
          >
            App Store でダウンロード（無料）
          </a>
          <p className="text-xs opacity-70">iOS / iPadOS 対応</p>
        </div>

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
  const [result, setResult] = useState<DiagnosticResult | null>(null);
  const [previous, setPrevious] = useState<StoredResult | null>(null);

  useEffect(() => {
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
    setResult(null);
    setPhase("quiz");
  }, []);

  const handleAnswer = useCallback(
    (choiceId: string) => {
      const q = questions[currentIndex];
      const correct = choiceId === q.correctChoiceId;
      const newResults = [...unitResults, { unit: q.unit, correct }];
      setUnitResults(newResults);

      if (currentIndex + 1 < questions.length) {
        setCurrentIndex((i) => i + 1);
      } else {
        // Build final result
        const scores = calcScores(newResults);
        const finalResult: DiagnosticResult = {
          ...scores,
          unitResults: newResults,
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

        setPhase("result");
      }
    },
    [questions, currentIndex, unitResults]
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
