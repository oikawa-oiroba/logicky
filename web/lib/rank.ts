export function rankLabel(score: number): string {
  if (score >= 90) return "S";
  if (score >= 80) return "A";
  if (score >= 70) return "B+";
  if (score >= 60) return "B";
  if (score >= 50) return "C";
  return "D";
}

export function rankDescription(score: number): string {
  if (score >= 90) return "論理思考のエキスパート";
  if (score >= 80) return "実践レベルの思考力";
  if (score >= 70) return "応用力が身についている";
  if (score >= 60) return "基礎は習得できている";
  if (score >= 50) return "もう少しで基礎レベル";
  return "基礎から鍛え直そう";
}

// スコア帯の色（低いほど赤 → 黄 → 青 → ターコイズ、満点はレインボー扱い）
export function scoreColor(score: number): string {
  if (score < 40) return "#E74C3C";
  if (score < 60) return "#F3B720";
  if (score < 80) return "#3B82F6";
  return "#0ABAB5";
}

export const RAINBOW_COLORS = [
  "#E74C3C", "#F39C12", "#F3B720", "#2ECC71", "#0ABAB5", "#3B82F6", "#9B59B6", "#E74C3C",
];

// 3軸のバランスから表示用のタイプ名を導く（採点ロジックには影響しない・表示のみ）
export function deriveTypeName(
  organize: number,
  reason: number,
  judge: number
): string {
  const max = Math.max(organize, reason, judge);
  const min = Math.min(organize, reason, judge);
  if (max - min <= 10) return "バランス型";
  if (max === reason) return "じっくり推論型";
  if (max === organize) return "コツコツ整理型";
  return "ズバッと判断型";
}

export interface SharedScores {
  total: number;
  organize: number;
  reason: number;
  judge: number;
  nickname: string;
}

const clamp = (v: string | undefined) =>
  Math.max(0, Math.min(100, Math.round(Number(v)) || 0));

// 共有URLのクエリパラメータを検証・正規化して取り出す
export function parseSharedScores(params: {
  [key: string]: string | string[] | undefined;
}): SharedScores {
  const get = (k: string) =>
    typeof params[k] === "string" ? (params[k] as string) : undefined;
  return {
    total: clamp(get("t")),
    organize: clamp(get("o")),
    reason: clamp(get("r")),
    judge: clamp(get("j")),
    nickname: (get("n") ?? "").slice(0, 20).trim(),
  };
}
