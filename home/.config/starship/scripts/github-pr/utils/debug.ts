import { writeFileSync } from "fs";

// デバッグモード
const DEBUG = process.env.STARSHIP_PR_DEBUG === "1";
const DEBUG_LOG = "/tmp/starship_pr_debug.log";

export function debug(message: string) {
  if (!DEBUG) return;
  const timestamp = new Date().toISOString();
  const log = `[${timestamp}] ${message}\n`;
  writeFileSync(DEBUG_LOG, log, { flag: "a" });
}
