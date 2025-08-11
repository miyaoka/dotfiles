import { createHash } from "crypto";
import {
  existsSync,
  mkdirSync,
  readFileSync,
  writeFileSync,
  unlinkSync,
  statSync,
} from "fs";
import { join, dirname } from "path";
import { homedir } from "os";
import { debug } from "./utils/debug";
import { tryCatch } from "./utils/result";
import type { GitInfo } from "./git";
import type { PRInfo } from "./pr";

// キャッシュの有効期限（24時間）
const CACHE_TTL_MS = 24 * 60 * 60 * 1000;

// パス生成
function getCachePaths(gitInfo: GitInfo) {
  const repoHash = createHash("sha256")
    .update(gitInfo.repoRoot)
    .digest("hex")
    .slice(0, 16);

  const cacheDir = join(homedir(), ".cache/starship/github_pr", repoHash);
  const headFile = join(cacheDir, "HEAD");
  const cacheFile = join(cacheDir, "refs", `${gitInfo.currentBranch}.json`);

  return { cacheDir, headFile, cacheFile };
}

// ブランチ切替チェック
function isBranchSwitched(headFile: string, currentBranch: string): boolean {
  if (!existsSync(headFile)) {
    return true;
  }

  const storedBranch = readFileSync(headFile, "utf-8").trim();
  debug(`stored_branch: ${storedBranch}`);

  return currentBranch !== storedBranch;
}

// 有効なキャッシュが存在するかチェック
function hasValidCache(cacheFile: string): boolean {
  const result = tryCatch(() => statSync(cacheFile));
  if (result.error) {
    return false; // ファイルが存在しない
  }

  const ageMs = Date.now() - result.value.mtimeMs;
  if (ageMs > CACHE_TTL_MS) {
    unlinkSync(cacheFile); // 期限切れなので削除
    debug("Cache expired");
    return false;
  }

  return true; // 有効なキャッシュあり
}

/**
 * キャッシュ取得
 */
export function getCache(gitInfo: GitInfo): PRInfo | null {
  const { cacheDir, headFile, cacheFile } = getCachePaths(gitInfo);

  // ディレクトリ作成
  mkdirSync(dirname(cacheFile), { recursive: true });

  debug(`cache_dir: ${cacheDir}`);
  debug(`head_file: ${headFile}`);
  debug(`cache_file: ${cacheFile}`);

  // ブランチ切替チェック
  if (isBranchSwitched(headFile, gitInfo.currentBranch)) {
    debug(`Branch switch detected or first run`);
    writeFileSync(headFile, gitInfo.currentBranch);

    // 切替時は既存キャッシュを削除
    if (existsSync(cacheFile)) {
      unlinkSync(cacheFile);
      debug("Removed cache for forced refresh");
    }
    return null;
  }

  // 有効なキャッシュが存在するかチェック
  if (!hasValidCache(cacheFile)) {
    return null;
  }

  const content = readFileSync(cacheFile, "utf-8").trim();
  const parsed = tryCatch<PRInfo | null>(() => JSON.parse(content));

  if (parsed.error) {
    debug(`Failed to parse cache file: ${parsed.error}`);
    return null;
  }

  return parsed.value;
}

/**
 * キャッシュ書き込み
 */
export function writeCache(gitInfo: GitInfo, data: PRInfo | null): void {
  const { cacheFile } = getCachePaths(gitInfo);
  writeFileSync(cacheFile, JSON.stringify(data));
}
