# Gortex Guide

Quick reference for all Gortex MCP tools and the knowledge graph schema.

## Always Start Here

1. **Call `graph_stats`** — confirm Gortex is running, get node/edge counts
2. **Match your task to a command below**
3. **Follow the command's workflow**

> If `total_nodes` is 0, call `index_repository` with `path: "."` first.

## Commands

| Task                                         | Command                  |
| -------------------------------------------- | ------------------------ |
| Understand architecture / "How does X work?" | /gortex-explore          |
| Blast radius / "What breaks if I change X?"  | /gortex-impact           |
| Trace bugs / "Why is X failing?"             | /gortex-debug            |
| Rename / extract / split / refactor          | /gortex-refactor         |
| Tools, schema reference                      | /gortex-guide (this)     |

## Tools Reference

### Core Navigation
| Tool | What it gives you |
|------|-------------------|
| graph_stats | Node/edge counts by kind and language — session start orientation |
| search_symbols | Find symbols by keyword (BM25 + camelCase-aware). Use instead of Grep |
| winnow_symbols | Structured constraint chain: kind, language, community, path_prefix, min_fan_in, min_churn — returns ranked rows with per-axis score contributions. Use when free-text search is too coarse |
| get_symbol | Single symbol: location, signature, edges. Use instead of Read |
| get_file_summary | All symbols + imports in a file. Use instead of Read |
| get_editing_context | **Primary pre-edit tool.** Symbols, signatures, callers, callees for a file |

### Graph Traversal
| Tool | What it gives you |
|------|-------------------|
| get_dependencies | What a symbol depends on (forward: imports, calls, refs) |
| get_dependents | What depends on a symbol (backward: blast radius) |
| get_call_chain | Forward call graph from a function |
| get_callers | Reverse call graph to a function |
| find_usages | Every reference to a symbol. Use instead of Grep |
| find_implementations | All types implementing an interface |
| get_cluster | Bidirectional neighborhood around a node |

### Coding Workflow
| Tool | What it gives you |
|------|-------------------|
| get_symbol_source | Source code of a single symbol — use instead of Read. Requires a symbol ID like `path/to/file.go::SymbolName` (call `get_file_summary` first if you only have a file path). Pass `if_none_match` with previous `etag` to get `not_modified` (skip re-reading unchanged source) |
| batch_symbols | Multiple symbols with source/callers/callees in one call |
| find_import_path | Correct import path for a symbol in a target file |
| explain_change_impact | Risk-tiered blast radius with affected processes/communities |
| edit_symbol | Edit symbol source by ID — no Read needed, resolves file + lines |
| edit_file | String-replace any file (markdown / config / spec / source) by absolute or repo-relative path. No pre-Read required. Atomic write (temp+rename), auto-reindex. `replace_all` for many occurrences; `dry_run` to preview. |
| write_file | Create or overwrite any file by absolute or repo-relative path. No pre-Read required. Atomic write, creates parent dirs, auto-reindex. `dry_run` to preview. |
| rename_symbol | Coordinated rename: generates edits for definition + all references |
| get_recent_changes | Files/symbols changed since timestamp (watch mode) |

### Agent-Optimized (token efficiency)
| Tool | What it gives you |
|------|-------------------|
| smart_context | Task-aware minimal context bundle — replaces 5-10 exploration calls |
| plan_turn | Suggested next tool calls for the current task — orchestrator for one turn |
| prefetch_context | Predicts needed symbols from task description + recent activity |
| get_edit_plan | Dependency-ordered edit sequence for multi-file refactors |
| get_test_targets | Maps changed symbols to test files and run commands |
| get_untested_symbols | Lists symbols with no covering test — candidates for new tests |
| suggest_pattern | Extracts code pattern from an example — source, registration, tests |
| export_context | Portable markdown/JSON briefing — share context outside MCP (Slack, PRs, docs) |

### Analysis
| Tool | What it gives you |
|------|-------------------|
| get_communities | Functional clusters via Louvain community detection (with id: returns single community details) |
| get_processes | Discovered execution flows (with id: returns single process step-by-step trace) |
| detect_changes | Git diff -> affected symbols -> blast radius |

### Proactive Safety
| Tool | What it gives you |
|------|-------------------|
| verify_change | Checks proposed signature changes against all callers and interface implementors |
| check_guards | Evaluates project guard rules (.gortex.yaml) against changed symbols |

### Dataflow (CPG-lite)
| Tool | What it gives you |
|------|-------------------|
| flow_between | Ranked dataflow paths between two symbol IDs. Walks `value_flow` (intra-procedural) ∪ `arg_of` (caller arg → callee param) ∪ `returns_to` (callee → assignment). Pass `max_depth` (default 8) and `max_paths` (default 10). |
| taint_paths | Pattern-driven dataflow sweep — every flow from a matching source to a matching sink. Patterns: bare token = name substring; `exact:Foo`; `path:dir/`; `kind:method` (clauses combine with AND). Sinks expand functions to their params automatically. |

### Structural Code Search
| Tool | What it gives you |
|------|-------------------|
| search_ast (detector mode) | Bundled cross-language anti-pattern rules. Pass `detector: "<name>"` for one of: `error-not-wrapped` (Go), `sql-string-concat` (Go/Python/JS/TS/Ruby), `weak-crypto` (Go/Python), `panic-in-library` (Go), `goroutine-without-recover` (Go), `http-client-no-timeout` (Go), `hardcoded-secret` (Go/Python/JS/TS/Ruby), `empty-catch` (Java/JS/TS/Python), `java-string-equality` (Java), `python-mutable-default-arg` (Python). Each match returns the enclosing `symbol_id` so you can chain into `find_usages` / `apply_code_action`. Test files excluded by default. |
| search_ast (raw pattern) | Tree-sitter S-expression queries. Pass `pattern: "..."` + `language: "..."`. Capture nodes with `@name`, anchor with `@match`, predicates `(#eq? @x "literal")` / `(#match? @x "regex")`. Example: `((call_expression function: (identifier) @fn) @match (#eq? @fn "panic"))` finds every direct `panic()` call. |
| search_ast (graph filters) | Combine the structural match with graph predicates ast-grep can't express: `path_prefix` / `repo` / `project` / `ref` / `min_fan_in_of_enclosing_func`. The last narrows results to load-bearing code by dropping matches in functions with few callers. |

### Diagnostics & Code Actions
| Tool | What it gives you |
|------|-------------------|
| subscribe_diagnostics | Opt the session into push `notifications/diagnostics` from every running language server. Initial state replays as `initial_replay: true`; thereafter only delta-changed files are pushed (sha256-suppressed). `min_severity` (1=error, 2=warning, 3=info, 4=hint) and `path_prefix` filters scope what reaches the session. Eliminates the poll-after-edit loop. |
| unsubscribe_diagnostics | Opt out of push notifications. Idempotent; fires automatically on session disconnect, so explicit calls are only needed when narrowing scope. |
| get_diagnostics | Latest stored `publishDiagnostics` for a file (the polling form). Pass `wait: true` + `timeout_ms` to block on the first publish — useful right after `didOpen` when no event has fired yet. |
| get_code_actions | LSP code actions for a file (and optional range). Returns the menu of fixes / refactors / source actions the language server offers. |
| apply_code_action | Apply a single CodeAction → WorkspaceEdit on disk. Atomic temp+rename; supports both legacy `changes` and modern `documentChanges` shapes; UTF-16 column math correctly maps LSP positions onto the byte offset in the source. |
| fix_all_in_file | One-shot `source.fixAll` over an entire file. Bundles every server-suggested fix in a single round-trip. |

### Code Quality
| Tool | What it gives you |
|------|-------------------|
| analyze | Unified graph analysis. Supported kinds: dead_code, hotspots, cycles, would_create_cycle, todos, blame, coverage, stale_code, ownership, coverage_gaps, coverage_summary, stale_flags, releases, cgo_users, wasm_users, orphan_tables, unreferenced_tables, channel_ops, goroutine_spawns, field_writers, annotation_users, config_readers, event_emitters, error_surface, external_calls, routes, models, components, k8s_resources, images, kustomize |
| analyze kind=dead_code | Symbols with zero incoming edges (excludes entry points, tests, exports) |
| analyze kind=hotspots | Over-coupled symbols ranked by fan-in, fan-out, and community crossings |
| analyze kind=cycles | Tarjan's SCC with severity classification |
| analyze kind=would_create_cycle | Pre-flight check before adding a new dependency |
| analyze kind=todos | KindTodo nodes; filter by tag/assignee/ticket |
| analyze kind=blame | Stamps meta.last_authored on every blame-eligible node |
| analyze kind=coverage | Stamps meta.coverage_pct on executable symbols from cover.out |
| analyze kind=stale_code | Symbols whose last-author timestamp is older than `older_than` days |
| analyze kind=ownership | Per-author rollup with symbol/file counts and oldest/newest TS |
| analyze kind=coverage_gaps | Symbols inside [min_pct, max_pct) — undertested code |
| analyze kind=coverage_summary | Per-directory coverage rollup (avg, covered, partial, uncovered) |
| analyze kind=stale_flags | Feature flags whose every toggling caller is older than `older_than` days |
| analyze kind=releases | Stamps meta.added_in on file nodes from git tags |
| analyze kind=cgo_users / wasm_users | Files that import C / use #[wasm_bindgen] |
| analyze kind=orphan_tables | Tables queried (EdgeQueries) but missing a migration (EdgeProvides) |
| analyze kind=unreferenced_tables | Tables provided by a migration but with zero EdgeQueries |
| analyze kind=channel_ops | Channels grouped by EdgeSends / EdgeRecvs — producer/consumer mismatches |
| analyze kind=goroutine_spawns | EdgeSpawns grouped by spawned target + mode (goroutine/async/promise) |
| analyze kind=field_writers | Mutability hotspots — fields ranked by EdgeWrites; pass `id` for one field |
| analyze kind=annotation_users | EdgeAnnotated rollup; pass `id` or `name` to scope (e.g. @Deprecated) |
| analyze kind=config_readers | config_key nodes grouped by EdgeReadsConfig; `name` filter |
| analyze kind=event_emitters | Event/log/metric emit sites grouped by EdgeEmits; `level`, `name` filters |
| analyze kind=error_surface | Function/method nodes with their EdgeThrows targets — refactor blast radius |
| analyze kind=external_calls | Stdlib / module-cache attribution — KindModule rollup of call/symbol counts; pass `id` for per-symbol detail, `module_kind` to filter stdlib vs module_cache |
| analyze kind=routes | Handler↔route pairs from the EdgeHandlesRoute layer (HTTP/gRPC/WS/GraphQL/topic); `method` / `path` / `type` filters |
| analyze kind=models | Model→table edges from EdgeModelsTable across gorm / SQLAlchemy / Django / ActiveRecord / JPA / TypeORM / Ecto; `orm` / `table` / `model` filters |
| analyze kind=components | Parent↔child fan-in/out from EdgeRendersChild (JSX/TSX + Phoenix HEEx); pass `id` for per-component child list |
| analyze kind=k8s_resources | KindResource fan-out (depends_on / configures / mounts / exposes / uses_env); `k8s_kind` / `namespace` / `name` filters |
| analyze kind=images | Container images (Dockerfile FROM target or K8s `container.image`) with consumer count; `role` (base/stage) / `ref` / `tag` filters |
| analyze kind=kustomize | KindKustomization overlay tree with base / resource fan-out; `dir` filter |
| index_health | Health score, parse failures, stale files, language coverage |
| get_symbol_history | Symbols modified this session with counts; flags churning (3+ edits) |
| gortex enrich blame\|coverage\|releases\|all (CLI) | Bulk-stamp the graph with the metadata that stale_*/coverage_*/ownership/releases analyzers need |

### Code Generation
| Tool | What it gives you |
|------|-------------------|
| scaffold | Generates code, registration wiring, and test stubs from an example symbol |
| batch_edit | Applies multiple edits in dependency order, re-indexes between steps |
| diff_context | Git diff enriched with callers, callees, community, processes, per-file risk |

### API Contracts
| Tool | What it gives you |
|------|-------------------|
| contracts | API contracts: action=list (default) lists detected contracts; action=check matches providers/consumers and reports orphans across repos. Scope either action with `repo`, `project`, or `ref` |

### Config Hygiene
| Tool | What it gives you |
|------|-------------------|
| audit_agent_config | Graph-validates backticked symbols in CLAUDE.md / AGENTS.md / `.cursor/rules` / Copilot / Windsurf / Antigravity configs — flags stale refs, dead paths, bloat |

### Agent Learning
| Tool | What it gives you |
|------|-------------------|
| feedback (action=record) | Report which symbols from `smart_context` were useful / not_needed / missing after a task — improves future bundles |
| feedback (action=query) | Aggregated stats: most useful, most missed, context accuracy over time |

### Multi-Repo
| Tool | What it gives you |
|------|-------------------|
| index_repository | Index a repository path into the graph |
| track_repository | Add a repo to the workspace, index immediately, persist to config |
| untrack_repository | Remove a repo, evict its nodes/edges, persist to config |
| get_active_project | Current project name and member repository list |
| set_active_project | Switch project scope — re-scopes all subsequent queries |

## Graph Schema

**Node kinds:**
- Code structure: file, package, function, method, type, interface, field, variable, constant, import, contract, param, closure, enum_member, generic_param
- Coverage extensions: module (ecosystem deps), table / column (db schema), config_key (env/viper/cli), flag (feature flags), event (logs/metrics/spans), migration, fixture (test data), todo (TODO/FIXME comments), team (CODEOWNERS), license, release (tag boundaries)

**Edge kinds:**
- Calls / structure: calls, imports, defines, implements, extends, references, member_of, instantiates, provides, consumes, composes, aliases, typed_as, returns, captures, param_of
- Concurrency: spawns (goroutine/async/promise), sends / recvs (channels)
- Mutation: reads / writes (fields), reads_config / writes_config
- Dataflow (CPG-lite, `flow_between` / `taint_paths`): value_flow (intra-procedural assignment / return / range), arg_of (caller arg → callee param), returns_to (callee → assignment LHS)
- Metadata: annotated (decorators), emits (events), throws (errors), queries (SQL), reads_col / writes_col, toggles_flag, depends_on_module, matches (fixtures), generated_by, tests (test → tested symbol), covered_by, owns (CODEOWNERS), authored, licensed_as
