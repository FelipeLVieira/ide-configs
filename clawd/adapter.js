import { spawn } from "node:child_process";
import { readFileSync } from "node:fs";
import path from "node:path";
import os from "node:os";

/**
 * Multi-Account Claude Code Adapter
 *
 * Wraps the default Claude Code CLI adapter with automatic account switching
 * when rate limits are detected. Uses CLAUDE_CODE_OAUTH_TOKEN env var to
 * authenticate secondary accounts via long-lived OAuth tokens.
 *
 * Primary account: uses default Claude Code auth (browser session)
 * Secondary accounts: use OAuth tokens stored at <configDir>/oauth-token
 *
 * Setup per account:
 *   CLAUDE_CONFIG_DIR=~/.claude-<name> claude setup-token
 *   # Save the displayed token to ~/.claude-<name>/oauth-token
 */

const ACCOUNTS = [
	{
		name: "felipe",
		email: "felipe.lv.90@gmail.com",
		tokenFile: null, // null = use default auth (no token override)
	},
	{
		name: "wisedigital",
		email: "wisedigitalinc@gmail.com",
		tokenFile: path.join(os.homedir(), ".claude-wisedigital", "oauth-token"),
	},
];

const RATE_LIMIT_PATTERNS = [
	/session limit reached/i,
	/rate limit/i,
	/too many requests/i,
	/429/,
	/quota exceeded/i,
	/usage limit/i,
	/capacity/i,
	/exceed.*account.*rate/i,
	/overloaded/i,
];

// Track which account is currently rate-limited and when it resets
const rateLimitState = new Map();

// Cache loaded tokens
const tokenCache = new Map();

/**
 * Load OAuth token from file (cached)
 */
function loadToken(tokenFile) {
	if (!tokenFile) return null;

	if (tokenCache.has(tokenFile)) {
		return tokenCache.get(tokenFile);
	}

	try {
		const token = readFileSync(tokenFile, "utf-8").trim();
		tokenCache.set(tokenFile, token);
		return token;
	} catch (err) {
		log(`WARNING: Could not read token from ${tokenFile}: ${err.message}`);
		return null;
	}
}

/**
 * Detect if output indicates a rate limit
 */
function isRateLimited(output) {
	if (!output) return false;
	return RATE_LIMIT_PATTERNS.some((pattern) => pattern.test(output));
}

/**
 * Parse reset time from rate limit message
 */
function parseResetTime(output) {
	const match = output.match(
		/resets?\s+(?:at\s+)?(\d{1,2}(?::\d{2})?\s*[ap]m)/i,
	);
	if (!match) return null;

	const timeStr = match[1];
	const timeMatch = timeStr.match(/(\d{1,2})(?::(\d{2}))?\s*([ap]m)/i);
	if (!timeMatch) return null;

	let hours = parseInt(timeMatch[1], 10);
	const minutes = timeMatch[2] ? parseInt(timeMatch[2], 10) : 0;
	const meridiem = timeMatch[3].toLowerCase();

	if (meridiem === "pm" && hours !== 12) hours += 12;
	else if (meridiem === "am" && hours === 12) hours = 0;

	const resetDate = new Date();
	resetDate.setHours(hours, minutes, 0, 0);
	if (resetDate <= new Date()) {
		resetDate.setDate(resetDate.getDate() + 1);
	}

	return resetDate;
}

/**
 * Get the best available account (not rate-limited)
 */
function getAvailableAccount() {
	const now = new Date();

	for (const account of ACCOUNTS) {
		const limitInfo = rateLimitState.get(account.name);
		if (!limitInfo || limitInfo.resetTime <= now) {
			if (limitInfo) {
				rateLimitState.delete(account.name);
				log(`Account "${account.name}" (${account.email}) rate limit expired, now available`);
			}

			// Skip accounts with missing tokens
			if (account.tokenFile && !loadToken(account.tokenFile)) {
				log(`Skipping "${account.name}" - token file not found`);
				continue;
			}

			return account;
		}
	}

	// All accounts rate-limited, return the one that resets soonest
	let soonest = null;
	let soonestTime = Infinity;
	for (const account of ACCOUNTS) {
		const limitInfo = rateLimitState.get(account.name);
		if (limitInfo && limitInfo.resetTime.getTime() < soonestTime) {
			soonest = account;
			soonestTime = limitInfo.resetTime.getTime();
		}
	}

	return soonest || ACCOUNTS[0];
}

/**
 * Mark an account as rate-limited
 */
function markRateLimited(account, output) {
	const resetTime = parseResetTime(output) || new Date(Date.now() + 15 * 60 * 1000);
	rateLimitState.set(account.name, {
		resetTime,
		detectedAt: new Date(),
	});
	log(`Account "${account.name}" (${account.email}) rate-limited until ${resetTime.toLocaleTimeString()}`);
}

function log(msg) {
	const timestamp = new Date().toISOString();
	console.log(`[clawd-adapter ${timestamp}] ${msg}`);
}

/**
 * Spawn Claude CLI with the given account's auth
 */
function spawnClaude(account, args, stdioConfig) {
	const env = { ...process.env };

	if (account.tokenFile) {
		const token = loadToken(account.tokenFile);
		if (token) {
			env.CLAUDE_CODE_OAUTH_TOKEN = token;
		}
	} else {
		// Primary account - remove any token override to use default auth
		delete env.CLAUDE_CODE_OAUTH_TOKEN;
	}

	log(`Using account: "${account.name}" (${account.email})${account.tokenFile ? " [oauth-token]" : " [default auth]"}`);

	return spawn("claude", args, {
		stdio: stdioConfig,
		env,
	});
}

class MultiAccountAdapter {
	constructor() {
		this.command = "claude";
		this.args = ["--dangerously-skip-permissions"];
	}

	async execute(prompt, _captureOutput = true) {
		const maxAccountSwitches = ACCOUNTS.length;
		let lastError = null;

		for (let attempt = 0; attempt < maxAccountSwitches; attempt++) {
			const account = getAvailableAccount();

			try {
				const result = await this._executeWithAccount(account, prompt);

				if (isRateLimited(result)) {
					markRateLimited(account, result);
					log(`Rate limit detected in output, trying next account...`);
					continue;
				}

				return result;
			} catch (error) {
				const errorMsg = error.message || "";
				if (isRateLimited(errorMsg)) {
					markRateLimited(account, errorMsg);
					log(`Rate limit detected in error, trying next account...`);
					lastError = error;
					continue;
				}
				throw error;
			}
		}

		throw lastError || new Error("All accounts rate-limited");
	}

	_executeWithAccount(account, prompt) {
		return new Promise((resolve, reject) => {
			const claude = spawnClaude(account, [...this.args, "-p", prompt], [
				"pipe",
				"pipe",
				"pipe",
			]);

			claude.stdin.end();

			let output = "";
			let errorOutput = "";

			claude.stdout.on("data", (data) => {
				output += data.toString();
			});

			claude.stderr.on("data", (data) => {
				errorOutput += data.toString();
			});

			claude.on("error", (err) => {
				reject(new Error(`Failed to spawn Claude: ${err.message}`));
			});

			claude.on("close", (code) => {
				const combinedOutput = `${output}\n${errorOutput}`.trim();

				if (code !== 0) {
					if (isRateLimited(combinedOutput)) {
						reject(
							new Error(
								`Claude failed (exit code ${code}): ${combinedOutput}`,
							),
						);
						return;
					}

					reject(
						new Error(
							`Claude failed (exit code ${code}): ${combinedOutput || "No output"}`,
						),
					);
					return;
				}

				resolve(output);
			});
		});
	}

	async executeWithTUI(prompt, tui) {
		const maxAccountSwitches = ACCOUNTS.length;

		for (let attempt = 0; attempt < maxAccountSwitches; attempt++) {
			const account = getAvailableAccount();

			const result = await this._executeWithTUIAccount(
				account,
				prompt,
				tui,
			);

			const combinedOutput = result.output || "";
			if (result.exitCode !== 0 && isRateLimited(combinedOutput)) {
				markRateLimited(account, combinedOutput);

				const switchMsg = `Switching from "${account.name}" to next available account...`;
				log(switchMsg);
				if (tui) tui.log(switchMsg, "warn");

				continue;
			}

			return result;
		}

		const allLimitedMsg = "All accounts rate-limited. Clawd will wait and retry.";
		log(allLimitedMsg);
		if (tui) tui.log(allLimitedMsg, "warn");

		return {
			exitCode: 1,
			output: "Session limit reached - all accounts rate-limited",
		};
	}

	_executeWithTUIAccount(account, prompt, tui) {
		return new Promise((resolve) => {
			const stdioConfig = tui ? ["pipe", "pipe", "pipe"] : "inherit";

			const claude = spawnClaude(account, [...this.args, "-p", prompt], stdioConfig);

			if (tui) {
				claude.stdin.end();
			}

			let output = "";

			if (tui) {
				claude.stdout.on("data", (data) => {
					output += data.toString();
					tui.writeOutput(data);
				});

				claude.stderr.on("data", (data) => {
					output += data.toString();
					tui.writeOutput(data);
				});
			}

			claude.on("close", (exitCode) => {
				resolve({ exitCode: exitCode || 0, output });
			});

			claude.on("error", (err) => {
				resolve({ exitCode: 1, output: err.message });
			});
		});
	}

	validate() {
		return true;
	}

	getName() {
		return "Multi-Account Claude Code";
	}
}

export default function createAdapter() {
	return new MultiAccountAdapter();
}

export { createAdapter };
