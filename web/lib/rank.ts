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
