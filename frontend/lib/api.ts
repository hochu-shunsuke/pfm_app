// Rails API への共通fetchラッパー。
// - ベースURLは .env.local の NEXT_PUBLIC_API_URL（既定 http://localhost:3000）
// - credentials: "include" でcookie（セッション）を送受信する＝認証の要
// - JSONでやり取りするので Accept / Content-Type を付与
const API_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:3000";

export async function apiFetch(
  path: string,
  options: RequestInit = {},
): Promise<Response> {
  return fetch(`${API_URL}${path}`, {
    ...options,
    credentials: "include",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      ...(options.headers ?? {}),
    },
  });
}
