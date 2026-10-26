#!/usr/bin/env node
// Risk tier of a change from the paths it touches and its size. The change sets the tier, not
// the author. Used three ways: by the Router to pick the human slots before work starts, by the
// risk-tier workflow as a required check, and by hand: `node scripts/risk-tier.mjs origin/main`.
//
//   high   – any always-human path, or more than 400 changed lines: two human approvals
//   medium – ordinary application change: one human approval
//   low    – docs, tests, styles, fixtures only: automated checks are enough
//
// Edit ALWAYS_HUMAN for your project; keep CI, infrastructure, auth, payments, migrations and
// agent instruction files on it.
import { execSync } from "node:child_process";

export const ALWAYS_HUMAN = [
  /^\.github\//, /^\.claude\//, /^CLAUDE\.md$/, /^AGENTS\.md$/,
  /^(infra|terraform|ansible|deploy|docker)\//, /docker-compose.*\.ya?ml$/, /^Dockerfile/,
  /database\/migrations\//, /^config\/(auth|database|services|queue|session)\.php$/,
  /app\/(Http\/Middleware|Policies|Providers\/AuthServiceProvider)/, /(payment|billing|invoice|webhook)/i,
  /^\.env\.example$/, /composer\.(json|lock)$/,
];
export const LOW_ONLY = [/\.md$/, /^docs\//, /^tests\//, /\.(test|spec)\.(php|ts|js)$/, /\.(css|scss)$/, /^resources\/lang\//, /fixtures?\//i, /\.(png|svg|jpg)$/];
export const SIZE_LIMIT = 400;

export function tierFor(files, changedLines) {
  if (files.some((f) => ALWAYS_HUMAN.some((r) => r.test(f)))) return { tier: "high", why: "always-human path" };
  if (changedLines > SIZE_LIMIT) return { tier: "high", why: `size ${changedLines} > ${SIZE_LIMIT}` };
  if (files.length && files.every((f) => LOW_ONLY.some((r) => r.test(f)))) return { tier: "low", why: "docs, tests, styles or fixtures only" };
  return { tier: "medium", why: "ordinary application change" };
}
export const SLOTS = { high: 2, medium: 1, low: 0 };

if (process.argv[1] && process.argv[1].endsWith("risk-tier.mjs")) {
  const base = process.argv[2] || "origin/main";
  const files = execSync(`git diff --name-only ${base}...HEAD`, { encoding: "utf8" }).split("\n").filter(Boolean);
  const stat = execSync(`git diff --shortstat ${base}...HEAD`, { encoding: "utf8" });
  const lines = [...stat.matchAll(/(\d+) (insertion|deletion)/g)].reduce((s, m) => s + Number(m[1]), 0);
  const r = tierFor(files, lines);
  console.log(JSON.stringify({ ...r, files: files.length, changedLines: lines, humanApprovalsRequired: SLOTS[r.tier] }));
}
