// 計測イベントの送信を1か所に集約する。
// 現状は接続先アナリティクスなし。GA4を導入したら gtag.js を layout に追加するだけで
// ここから自動的にイベントが流れる（dataLayer / gtag 両対応）。

export type AnalyticsEvent =
  | "fv_view" // ファーストビュー表示
  | "cta_click" // 「無料で診断する」クリック
  | "quiz_start" // 診断開始（出題画面表示）
  | "question_view" // 各設問への到達 { index }
  | "quiz_complete" // 診断完了（全問回答）
  | "result_view" // 結果画面表示
  | "app_cta_view" // アプリCTAの表示
  | "app_cta_click" // アプリCTAのクリック
  | "share_click" // シェアボタンのクリック { service }
  | "feedback_submit"; // 問題フィードバック送信

type Params = Record<string, string | number | boolean>;

const UTM_KEYS = ["utm_source", "utm_medium", "utm_campaign", "utm_content"] as const;
const UTM_STORAGE_KEY = "logicky_web_utm";

declare global {
  interface Window {
    dataLayer?: unknown[];
    gtag?: (...args: unknown[]) => void;
  }
}

// 初回ロード時にURLからUTMパラメータを取得し、セッション中保持する。
// （診断中のページ内遷移でURLからUTMが消えても流入元を判別できるように）
export function captureUtm(): void {
  if (typeof window === "undefined") return;
  try {
    const params = new URLSearchParams(window.location.search);
    const utm: Record<string, string> = {};
    for (const key of UTM_KEYS) {
      const v = params.get(key);
      if (v) utm[key] = v.slice(0, 100);
    }
    if (Object.keys(utm).length > 0) {
      sessionStorage.setItem(UTM_STORAGE_KEY, JSON.stringify(utm));
    }
  } catch {}
}

function getUtm(): Record<string, string> {
  try {
    const raw = sessionStorage.getItem(UTM_STORAGE_KEY);
    return raw ? JSON.parse(raw) : {};
  } catch {
    return {};
  }
}

let utmCaptured = false;

export function track(event: AnalyticsEvent, params: Params = {}): void {
  if (typeof window === "undefined") return;
  if (!utmCaptured) {
    captureUtm();
    utmCaptured = true;
  }
  const payload = { ...getUtm(), ...params };

  try {
    if (typeof window.gtag === "function") {
      window.gtag("event", event, payload);
    } else if (Array.isArray(window.dataLayer)) {
      window.dataLayer.push({ event, ...payload });
    } else if (process.env.NODE_ENV === "development") {
      console.debug("[analytics]", event, payload);
    }
  } catch {}
}
