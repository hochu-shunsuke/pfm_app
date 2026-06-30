import { redirect } from "next/navigation";

// ルート("/")は口座一覧へ。未ログインなら/accounts側でloginへ誘導される。
export default function Home() {
  redirect("/accounts");
}
