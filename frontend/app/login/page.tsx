"use client"; // 状態・イベント・router を使うのでクライアントコンポーネント

import { useState } from "react";
import { useRouter } from "next/navigation";
import { apiFetch } from "@/lib/api";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("demo@example.com");
  const [password, setPassword] = useState("password123");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);

    const res = await apiFetch("/session", {
      method: "POST",
      body: JSON.stringify({ email_address: email, password }),
    });

    setLoading(false);
    if (res.ok) {
      router.push("/accounts"); // ログイン成功 → 口座一覧へ
    } else {
      const data = await res.json().catch(() => ({}));
      setError(data.error ?? "ログインに失敗しました");
    }
  }

  return (
    <main className="mx-auto max-w-sm p-8">
      <h1 className="mb-6 text-2xl font-bold">ログイン</h1>
      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        <label className="flex flex-col gap-1">
          <span className="text-sm">メールアドレス</span>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="rounded border px-3 py-2"
            required
          />
        </label>
        <label className="flex flex-col gap-1">
          <span className="text-sm">パスワード</span>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="rounded border px-3 py-2"
            required
          />
        </label>
        {error && <p className="text-sm text-red-600">{error}</p>}
        <button
          type="submit"
          disabled={loading}
          className="rounded bg-black px-4 py-2 text-white disabled:opacity-50"
        >
          {loading ? "送信中..." : "ログイン"}
        </button>
      </form>
    </main>
  );
}
