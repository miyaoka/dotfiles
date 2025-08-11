import { $ } from "bun";
import { tryCatchAsync } from "./utils/result";
import { debug } from "./utils/debug";

// Git情報の型
export type GitInfo = {
  repoRoot: string;
  currentBranch: string;
};

// エラーメッセージを取得
function getErrorMessage(error: unknown): string {
  // オブジェクトかどうか確認
  if (typeof error === "object" && error !== null) {
    // stderrプロパティがあるか確認
    if ("stderr" in error) {
      const stderr = (error as { stderr: unknown }).stderr;
      return String(stderr).trim();
    }
  }

  // Error インスタンスか確認
  if (error instanceof Error) {
    return error.message;
  }

  // その他の場合
  const stringified = String(error);
  return stringified;
}

// Gitリポジトリ情報の結果型
type GitInfoResult =
  | { value: GitInfo; error?: undefined }
  | { value?: undefined; error: string };

// Gitリポジトリ情報を取得
export async function getGitInfo(): Promise<GitInfoResult> {
  const result = await tryCatchAsync(() =>
    Promise.all([
      // リポジトリルートを取得
      $`git rev-parse --show-toplevel`.quiet(),
      // カレントブランチ名を取得
      $`git branch --show-current`.quiet(),
    ])
  );

  if (result.error) {
    const errorMsg = getErrorMessage(result.error);
    debug(`Failed to get git info: ${errorMsg}`);
    return { error: errorMsg };
  }

  const [repoRoot, currentBranch] = result.value.map((r) =>
    r.text().trim(),
  );

  debug(`repo_root: ${repoRoot}`);
  debug(`current_branch: ${currentBranch}`);

  return { value: { repoRoot, currentBranch } };
}
