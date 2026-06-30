"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { apiFetch } from "@/lib/api";

type Account = { id: number; name: string; category: string };
type Line = { account_id: number | ""; side: "debit" | "credit"; amount: string };

const emptyLine = (side: Line["side"]): Line => ({ account_id: "", side, amount: "" });

export default function NewJournalEntryPage() {
  const router = useRouter();
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [date, setDate] = useState(() => new Date().toISOString().slice(0, 10));
  const [description, setDescription] = useState("");
  // 初期は借方1行・貸方1行
  const [lines, setLines] = useState<Line[]>([emptyLine("debit"), emptyLine("credit")]);
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    apiFetch("/accounts").then(async (res) => {
      if (res.status === 401) {
        router.push("/login");
        return;
      }
      if (res.ok) setAccounts(await res.json());
    });
  }, [router]);

  function updateLine(index: number, patch: Partial<Line>) {
    setLines((prev) => prev.map((l, i) => (i === index ? { ...l, ...patch } : l)));
  }
  function addLine() {
    setLines((prev) => [...prev, emptyLine("debit")]);
  }
  function removeLine(index: number) {
    setLines((prev) => prev.filter((_, i) => i !== index));
  }

  // クライアント側の貸借チェック（円単位で集計）
  const debitTotal = lines
    .filter((l) => l.side === "debit")
    .reduce((sum, l) => sum + (Number(l.amount) || 0), 0);
  const creditTotal = lines
    .filter((l) => l.side === "credit")
    .reduce((sum, l) => sum + (Number(l.amount) || 0), 0);
  const allFilled = lines.every((l) => l.account_id !== "" && Number(l.amount) > 0);
  const balanced = debitTotal === creditTotal && debitTotal > 0;
  const canSubmit = balanced && allFilled && !submitting;

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setSubmitting(true);

    const res = await apiFetch("/journal_entries", {
      method: "POST",
      body: JSON.stringify({
        journal_entry: {
          date,
          description,
          lines: lines.map((l) => ({
            account_id: l.account_id,
            side: l.side,
            amount: Math.round(Number(l.amount) * 100), // 円 → 1/100円単位
          })),
        },
      }),
    });

    setSubmitting(false);
    if (res.ok) {
      router.push("/accounts"); // 成功 → 残高が更新された一覧へ
    } else {
      const data = await res.json().catch(() => ({}));
      setError(data.errors?.join(" / ") ?? data.error ?? "作成に失敗しました");
    }
  }

  return (
    <main className="mx-auto max-w-2xl p-8">
      <Link href="/accounts" className="text-sm text-blue-600 hover:underline">
        ← 口座一覧へ戻る
      </Link>
      <h1 className="mt-2 mb-6 text-2xl font-bold">仕訳の入力</h1>

      <form onSubmit={handleSubmit} className="flex flex-col gap-5">
        <div className="flex gap-4">
          <label className="flex flex-1 flex-col gap-1">
            <span className="text-sm">日付</span>
            <input
              type="date"
              value={date}
              onChange={(e) => setDate(e.target.value)}
              className="rounded border px-3 py-2"
              required
            />
          </label>
          <label className="flex flex-[2] flex-col gap-1">
            <span className="text-sm">摘要</span>
            <input
              type="text"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="例: コンビニ"
              className="rounded border px-3 py-2"
            />
          </label>
        </div>

        <div className="flex flex-col gap-2">
          {lines.map((line, i) => (
            <div key={i} className="flex items-center gap-2">
              <select
                value={line.account_id}
                onChange={(e) =>
                  updateLine(i, {
                    account_id: e.target.value === "" ? "" : Number(e.target.value),
                  })
                }
                className="flex-[2] rounded border px-2 py-2"
                required
              >
                <option value="">勘定を選択</option>
                {accounts.map((a) => (
                  <option key={a.id} value={a.id}>
                    {a.name}
                  </option>
                ))}
              </select>

              <select
                value={line.side}
                onChange={(e) => updateLine(i, { side: e.target.value as Line["side"] })}
                className="rounded border px-2 py-2"
              >
                <option value="debit">借方</option>
                <option value="credit">貸方</option>
              </select>

              <input
                type="number"
                min="0"
                value={line.amount}
                onChange={(e) => updateLine(i, { amount: e.target.value })}
                placeholder="金額(円)"
                className="w-32 rounded border px-2 py-2 text-right"
                required
              />

              <button
                type="button"
                onClick={() => removeLine(i)}
                disabled={lines.length <= 2}
                className="rounded px-2 py-2 text-zinc-400 hover:text-red-600 disabled:opacity-30"
                aria-label="行を削除"
              >
                ×
              </button>
            </div>
          ))}

          <button
            type="button"
            onClick={addLine}
            className="self-start text-sm text-blue-600 hover:underline"
          >
            ＋ 行を追加
          </button>
        </div>

        {/* 貸借の集計（リアルタイム） */}
        <div className="flex justify-between rounded bg-zinc-50 px-4 py-3 text-sm dark:bg-zinc-900">
          <span>借方合計: ¥{debitTotal.toLocaleString("ja-JP")}</span>
          <span>貸方合計: ¥{creditTotal.toLocaleString("ja-JP")}</span>
          <span className={balanced ? "text-green-600" : "text-red-600"}>
            {balanced ? "✓ 貸借一致" : `差額 ¥${(debitTotal - creditTotal).toLocaleString("ja-JP")}`}
          </span>
        </div>

        {error && <p className="text-sm text-red-600">{error}</p>}

        <button
          type="submit"
          disabled={!canSubmit}
          className="rounded bg-black px-4 py-2 text-white disabled:cursor-not-allowed disabled:opacity-40"
        >
          {submitting ? "保存中..." : "仕訳を保存"}
        </button>
      </form>
    </main>
  );
}
