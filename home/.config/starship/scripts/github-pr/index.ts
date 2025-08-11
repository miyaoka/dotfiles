#!/usr/bin/env bun
import { debug } from "./utils/debug";
import { getGitInfo } from "./git";
import { getPRInfo, type PRInfo } from "./pr";

// PR情報を表示
function displayPRInfo(prInfo: PRInfo | null): void {
  if (prInfo === null) {
    console.log("[no PR]");
    return;
  }
  // ターミナルハイパーリンク形式で表示
  // OSC 8エスケープシーケンス: \x1b]8;;URL\x1b\\表示テキスト\x1b]8;;\x1b\\
  const link = `\x1b]8;;${prInfo.url}\x1b\\#${prInfo.number}\x1b]8;;\x1b\\`;
  const formatted = `${link} ${prInfo.title}`;
  console.log(formatted);
}

// メイン関数
async function main() {
  debug("=== Starting github-pr.ts ===");

  // Git情報を取得
  const { value: gitInfo, error } = await getGitInfo();
  if (error) {
    debug(`Git error: ${error}`);
    console.log(error);
    return;
  }

  // PR情報を取得
  const prInfo = await getPRInfo(gitInfo);

  // 表示
  displayPRInfo(prInfo);
}

// 実行
main();
