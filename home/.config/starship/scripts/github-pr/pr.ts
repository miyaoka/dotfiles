import { $ } from "bun";
import { tryCatchAsync, tryCatch } from "./utils/result";
import { debug } from "./utils/debug";
import { getCache, writeCache } from "./cache";
import type { GitInfo } from "./git";

// PR情報の型
export type PRInfo = {
  number: number;
  title: string;
  url: string;
  isDraft: boolean;
  state: "OPEN" | "CLOSED" | "MERGED";
};

/**
 * GitHub APIからPR情報を取得
 */
async function fetchPRFromAPI(branch: string): Promise<PRInfo | null> {
  debug(`Fetching new PR info for ${branch}`);

  const result = await tryCatchAsync(() =>
    $`gh pr view --json number,title,url,isDraft,state`.quiet().nothrow()
  );

  if (result.error) {
    debug(`gh command execution error: ${result.error}`);
    return null;
  }

  const { stdout, stderr, exitCode } = result.value;

  // 成功: PRが存在
  if (exitCode === 0) {
    const jsonStr = stdout.toString();
    const parsed = tryCatch<PRInfo>(() => JSON.parse(jsonStr));

    if (parsed.error) {
      debug(`JSON parse error: ${parsed.error}`);
      return null;
    }

    return parsed.value;
  }

  const errorMsg = stderr.toString().trim();

  // ghコマンドが存在しない
  if (errorMsg.includes("command not found")) {
    console.log("[gh not installed]");
    return null;
  }

  // PRが存在しない
  if (errorMsg.includes("no pull requests found")) {
    return null;
  }

  // その他のエラー
  debug(`Unhandled error: exitCode=${exitCode}, error=${errorMsg}`);
  return null;
}

/**
 * PR情報を取得（キャッシュ or fetch）
 */
export async function getPRInfo(gitInfo: GitInfo): Promise<PRInfo | null> {
  // キャッシュ取得
  const cached = getCache(gitInfo);
  if (cached) {
    debug(`Using cache for ${gitInfo.currentBranch}`);
    return cached;
  }

  // キャッシュがない場合は新規取得
  debug(`No cache found for ${gitInfo.currentBranch}, fetching`);
  const prInfo = await fetchPRFromAPI(gitInfo.currentBranch);

  // キャッシュに保存
  writeCache(gitInfo, prInfo);

  return prInfo;
}
