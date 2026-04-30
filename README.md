# Gortex — Claude Code Plugin

Gortex is a graph-based code intelligence engine. This plugin gives Claude
Code 52 MCP tools for navigation, refactoring, contracts, impact analysis,
and search across 92 languages — backed by a shared-graph daemon that
keeps multiple agents and editor sessions in sync.

## Install

This plugin assumes the `gortex` binary is on PATH. Install it via:

```sh
curl -fsSL https://get.gortex.dev | sh
```

The installer fetches a signed release tarball, verifies cosign + SHA256,
installs to `~/.local/bin` (or `/usr/local/bin`), and runs `gortex install`
+ `gortex init`. Homebrew users on macOS can also use:

```sh
brew install zzet/tap/gortex
```

## What this plugin adds

| Surface | What you get |
|---------|--------------|
| **MCP server** | 52 tools (`search_symbols`, `find_usages`, `get_call_chain`, `explain_change_impact`, `rename_symbol`, `scaffold`, `contracts`, …) over stdio via `gortex mcp --proxy` |
| **Slash commands** | `/gortex-guide`, `/gortex-explore`, `/gortex-debug`, `/gortex-impact`, `/gortex-refactor` |
| **Skills** | Five model-invoked skills that activate by task-shape (architecture exploration, debugging, blast-radius analysis, refactoring, tool reference) |
| **Hooks** | PreToolUse routing (Read → `get_symbol_source`, Grep → `search_symbols` / `find_usages`), PreCompact orientation snapshot, Stop post-task diagnostics, SessionStart cold briefing |

## First run

After install, point Claude Code at any code repository and ask a task that
involves understanding code structure ("how does authentication work?",
"what breaks if I rename `UserStore`?"). The hooks redirect Read/Grep/Glob
toward graph queries; the slash commands give you guided workflows.

If `gortex daemon` is running (`gortex daemon start --detach` to start it),
all your editor sessions share one in-memory graph. Otherwise this plugin
spawns a one-shot MCP server per session — same tools, slower cold start.

## Links

- Homepage: https://gortex.dev
- Source:   https://github.com/zzet/gortex
- License:  https://github.com/zzet/gortex/blob/main/LICENSE.md (source-available; free under defined thresholds)
