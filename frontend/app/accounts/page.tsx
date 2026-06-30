"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { apiFetch } from "@/lib/api";

type Account = {
  id: number;
  name: string;
  category: string;
  balance: number; // 1/100円単位の整数（API側の保存形式）
};

// 1/100円単位の整数を「¥1,234」表示に整形
function formatYen(amountInHundredths: number): string {
  return `¥${(amountInHundredths / 100).toLocaleString("ja-JP")}`;
}

export default function AccountsPage() {
  const router = useRouter();
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    apiFetch("/accounts")
      .then(async (res) => {
        if (res.status === 401) {
          router.push("/login"); // 未ログインならログイン画面へ
          return;
        }
        if (!res.ok) throw new Error("口座の取得に失敗しました");
        setAccounts(await res.json());
      })
      .catch((e) => setError(e.message))
      .finally(() => setLoading(false));
  }, [router]);

  if (loading) return <main className="p-8">読み込み中...</main>;
  if (error) return <main className="p-8 text-red-600">{error}</main>;

  return (
    <main className="mx-auto max-w-2xl p-8">
      <h1 className="mb-6 text-2xl font-bold">勘定科目</h1>
      <ul className="divide-y rounded border">
        {accounts.map((a) => (
          <li key={a.id} className="flex items-center justify-between px-4 py-3">
            <div className="flex flex-col">
              <span>{a.name}</span>
              <span className="text-xs text-zinc-500">{a.category}</span>
            </div>
            <span className="font-mono tabular-nums">{formatYen(a.balance)}</span>
          </li>
        ))}
        {accounts.length === 0 && (
          <li className="px-4 py-3 text-sm text-zinc-500">口座がありません</li>
        )}
      </ul>
    </main>
  );
}
