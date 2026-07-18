"use client";

import { useCallback, useEffect, useState } from "react";

interface Redemption {
  deviceId: string;
  nickname: string;
  platform: string;
  redeemedAt: string;
}

interface LicenseRow {
  code: string;
  active: boolean;
  expiresAt: string | null;
  grantDays: number | null;
  maxUses: number | null;
  note: string;
  createdAt: string;
  redemptions: Redemption[];
  usedCount: number;
  remaining: number | null;
}

const TOKEN_KEY = "logicky_admin_token";

function fmtDate(iso: string | null): string {
  if (!iso) return "無期限";
  return new Date(iso).toLocaleString("ja-JP", {
    year: "numeric", month: "short", day: "numeric", hour: "2-digit", minute: "2-digit",
  });
}

function grantLabel(days: number | null): string {
  return days === null ? "無期限" : `${days}日`;
}

export default function AdminPage() {
  const [token, setToken] = useState("");
  const [authed, setAuthed] = useState(false);
  const [codes, setCodes] = useState<LicenseRow[]>([]);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [expanded, setExpanded] = useState<string | null>(null);

  // 発行フォーム
  const [newCode, setNewCode] = useState("");
  const [newGrant, setNewGrant] = useState<string>("30");
  const [newMaxUses, setNewMaxUses] = useState("");
  const [newExpires, setNewExpires] = useState("");
  const [newNote, setNewNote] = useState("");
  const [creating, setCreating] = useState(false);

  const load = useCallback(async (tk: string) => {
    setLoading(true);
    setError("");
    try {
      const res = await fetch("/api/admin/licenses", {
        headers: { Authorization: `Bearer ${tk}` },
      });
      if (res.status === 401) {
        setAuthed(false);
        setError("トークンが違います");
        return;
      }
      const data = await res.json();
      setCodes(data.codes ?? []);
      setAuthed(true);
      sessionStorage.setItem(TOKEN_KEY, tk);
    } catch {
      setError("読み込みに失敗しました");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    const saved = sessionStorage.getItem(TOKEN_KEY);
    if (saved) {
      setToken(saved);
      load(saved);
    }
  }, [load]);

  const create = async () => {
    setCreating(true);
    setError("");
    try {
      const res = await fetch("/api/admin/licenses", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          code: newCode,
          grantDays: newGrant === "" ? null : Number(newGrant),
          maxUses: newMaxUses === "" ? null : Number(newMaxUses),
          expiresAt: newExpires || null,
          note: newNote,
        }),
      });
      const data = await res.json();
      if (!res.ok) {
        setError(data.error ?? "発行に失敗しました");
      } else {
        setNewCode("");
        setNewNote("");
        setNewMaxUses("");
        setNewExpires("");
        await load(token);
      }
    } catch {
      setError("発行に失敗しました");
    } finally {
      setCreating(false);
    }
  };

  const toggle = async (code: string, active: boolean) => {
    await fetch("/api/admin/licenses", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({ code, active }),
    });
    await load(token);
  };

  if (!authed) {
    return (
      <div className="min-h-screen bg-app-bg flex items-center justify-center px-5">
        <div className="w-full max-w-sm bg-white rounded-2xl border border-card-border p-6 space-y-4">
          <h1 className="font-bold text-app-text">Logicky 管理画面</h1>
          <input
            type="password"
            value={token}
            onChange={(e) => setToken(e.target.value)}
            placeholder="管理トークン"
            className="w-full text-sm p-3 border border-card-border rounded-xl outline-none"
            onKeyDown={(e) => e.key === "Enter" && load(token)}
          />
          <button
            onClick={() => load(token)}
            disabled={!token || loading}
            className="w-full py-3 bg-tiffany text-white font-bold rounded-xl text-sm disabled:opacity-50"
          >
            {loading ? "確認中…" : "ログイン"}
          </button>
          {error && <p className="text-xs text-red-500">{error}</p>}
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-app-bg">
      <div className="max-w-3xl mx-auto px-5 py-8 space-y-6">
        <div className="flex items-center justify-between">
          <h1 className="text-xl font-bold text-app-text">ライセンスコード管理</h1>
          <button
            onClick={() => load(token)}
            className="text-xs text-tiffany underline"
          >
            再読み込み
          </button>
        </div>

        {/* 発行フォーム */}
        <div className="bg-white rounded-2xl border border-card-border p-5 space-y-3">
          <h2 className="font-bold text-app-text text-sm">新規コード発行</h2>
          <div className="grid grid-cols-2 gap-3">
            <input
              value={newCode}
              onChange={(e) => setNewCode(e.target.value.toUpperCase())}
              placeholder="コード名（例：LOGILOGI）"
              className="col-span-2 text-sm p-2.5 border border-card-border rounded-lg outline-none font-mono"
            />
            <label className="text-xs text-app-sub">
              プレミアム付与期間
              <select
                value={newGrant}
                onChange={(e) => setNewGrant(e.target.value)}
                className="w-full mt-1 text-sm p-2.5 border border-card-border rounded-lg bg-white"
              >
                <option value="30">30日</option>
                <option value="90">90日</option>
                <option value="365">365日</option>
                <option value="">無期限</option>
              </select>
            </label>
            <label className="text-xs text-app-sub">
              利用人数制限（空欄=無制限）
              <input
                type="number"
                min={1}
                value={newMaxUses}
                onChange={(e) => setNewMaxUses(e.target.value)}
                placeholder="無制限"
                className="w-full mt-1 text-sm p-2.5 border border-card-border rounded-lg outline-none"
              />
            </label>
            <label className="text-xs text-app-sub">
              コード有効期限（空欄=無期限）
              <input
                type="date"
                value={newExpires}
                onChange={(e) => setNewExpires(e.target.value)}
                className="w-full mt-1 text-sm p-2.5 border border-card-border rounded-lg outline-none"
              />
            </label>
            <label className="text-xs text-app-sub">
              メモ（営業先・学校名など）
              <input
                value={newNote}
                onChange={(e) => setNewNote(e.target.value)}
                placeholder="〇〇高校 βテスト"
                className="w-full mt-1 text-sm p-2.5 border border-card-border rounded-lg outline-none"
              />
            </label>
          </div>
          <button
            onClick={create}
            disabled={creating || newCode.trim().length < 3}
            className="px-5 py-2.5 bg-tiffany text-white font-bold rounded-xl text-sm disabled:opacity-50"
          >
            {creating ? "発行中…" : "発行する"}
          </button>
          {error && <p className="text-xs text-red-500">{error}</p>}
        </div>

        {/* コード一覧 */}
        <div className="space-y-3">
          {codes.length === 0 && (
            <p className="text-sm text-app-sub text-center py-8">コードはまだありません</p>
          )}
          {codes.map((c) => (
            <div key={c.code} className="bg-white rounded-2xl border border-card-border p-4">
              <div className="flex items-center gap-3 flex-wrap">
                <span className="font-mono font-bold text-app-text">{c.code}</span>
                <span
                  className={`text-[11px] font-semibold px-2 py-0.5 rounded-full ${
                    c.active ? "bg-tiffany-light text-tiffany" : "bg-gray-100 text-app-gray"
                  }`}
                >
                  {c.active ? "有効" : "無効"}
                </span>
                <span className="text-xs text-app-sub">
                  利用 {c.usedCount}
                  {c.maxUses !== null && ` / ${c.maxUses}（残り${c.remaining}）`}
                  {c.maxUses === null && "（無制限）"}
                </span>
                <span className="text-xs text-app-sub">付与 {grantLabel(c.grantDays)}</span>
                <span className="text-xs text-app-sub">期限 {fmtDate(c.expiresAt)}</span>
                <div className="ml-auto flex gap-2">
                  <button
                    onClick={() => setExpanded(expanded === c.code ? null : c.code)}
                    className="text-xs text-tiffany underline"
                  >
                    利用者{expanded === c.code ? "を隠す" : "一覧"}
                  </button>
                  <button
                    onClick={() => toggle(c.code, !c.active)}
                    className={`text-xs px-3 py-1 rounded-full border ${
                      c.active
                        ? "border-red-300 text-red-500"
                        : "border-tiffany text-tiffany"
                    }`}
                  >
                    {c.active ? "無効にする" : "有効にする"}
                  </button>
                </div>
              </div>
              {c.note && <p className="text-xs text-app-gray mt-1.5">📝 {c.note}</p>}

              {expanded === c.code && (
                <div className="mt-3 border-t border-card-border pt-3">
                  {c.redemptions.length === 0 ? (
                    <p className="text-xs text-app-gray">まだ利用者はいません</p>
                  ) : (
                    <div className="overflow-x-auto">
                      <table className="w-full text-xs">
                        <thead>
                          <tr className="text-app-gray text-left">
                            <th className="py-1 pr-3 font-normal">ニックネーム</th>
                            <th className="py-1 pr-3 font-normal">端末ID</th>
                            <th className="py-1 pr-3 font-normal">OS</th>
                            <th className="py-1 font-normal">利用日時</th>
                          </tr>
                        </thead>
                        <tbody>
                          {c.redemptions.map((r) => (
                            <tr key={r.deviceId} className="text-app-sub border-t border-card-border/60">
                              <td className="py-1.5 pr-3">{r.nickname || "—"}</td>
                              <td className="py-1.5 pr-3 font-mono">{r.deviceId.slice(0, 8)}…</td>
                              <td className="py-1.5 pr-3">{r.platform}</td>
                              <td className="py-1.5">{fmtDate(r.redeemedAt)}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  )}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
