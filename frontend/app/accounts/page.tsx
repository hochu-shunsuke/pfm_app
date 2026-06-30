"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { apiFetch } from "@/lib/api";

type Account = {
  id: number;
  name: string;
  category: string;
  organization_id: number;
};

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
          <li key={a.id} className="flex justify-between px-4 py-3">
            <span>{a.name}</span>
            <span className="text-sm text-zinc-500">{a.category}</span>
          </li>
        ))}
        {accounts.length === 0 && (
          <li className="px-4 py-3 text-sm text-zinc-500">口座がありません</li>
        )}
      </ul>
    </main>
  );
}
