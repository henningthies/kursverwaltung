# Task 05 — Add MCP config with Playwright (.mcp.json)

> Read `_SHARED.md` first. Harness task #5. Part of t2-end. Blocked by: #3.

## Goal

Wire a Playwright MCP server via `.mcp.json` so Claude can drive the running app in a browser
during demos (open pages, click, screenshot).

## Steps

1. Add `.mcp.json` at the repo root configuring the Playwright MCP server
   (`@playwright/mcp` via `npx`, or the documented current package). Use a minimal, standard config.
2. Document in `CLAUDE.md` (or a short note) how to start the app (`bin/dev` / `bin/rails server`)
   so the browser tooling has a target, and the default URL (e.g. `http://localhost:3000`).
3. Verify the config is valid JSON and the server name is sensible (e.g. `playwright`).

## Acceptance criteria

- `.mcp.json` is valid and references a Playwright MCP server.
- A short note explains how to run the app for browser-driven demos.
- No app code changed; tests still green.

## Notes

- Do not commit secrets. MCP config here should need none.
- Verifying the MCP actually connects may require the human to approve/start it; describe the
  expected behavior if you cannot fully verify in an agent.

## Files

- `.mcp.json`
