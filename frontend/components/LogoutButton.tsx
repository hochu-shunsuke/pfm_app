"use client";

import { useRouter } from "next/navigation";
import { apiFetch } from "@/lib/api";

export default function LogoutButton() {
  const router = useRouter();

  async function handleLogout() {
    await apiFetch("/session", { method: "DELETE" }); // サーバ側でセッション破棄＋cookie削除
    router.push("/login");
  }

  return (
    <button
      onClick={handleLogout}
      className="text-sm text-zinc-500 hover:text-red-600"
    >
      ログアウト
    </button>
  );
}
