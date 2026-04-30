---
name: gortex-impact
description: "Use when the user wants to know what will break if they change something, or needs safety analysis before editing code. Examples: \"Is it safe to change X?\", \"What depends on this?\", \"What will break?\""
---
# Impact Analysis with Gortex

## Workflow

```
1. search_symbols({query: "X"})                                     -> Find the symbol ID
2. explain_change_impact({ids: "<id1>, <id2>"})                     -> Risk-tiered blast radius
3. get_dependents({id: "<symbol-id>", depth: 3})                    -> Detailed dependent tree
4. verify_change({id: "<id>", new_signature: "..."})                -> Check callers + interface implementors for signature-level breaks
5. contracts({action: "check"})                                     -> Cross-repo API breakage (HTTP/gRPC/GraphQL/topics)
6. analyze({kind: "would_create_cycle", from: "<a>", to: "<b>"})    -> Before adding a new dep
7. get_test_targets({ids: ["<id1>", "<id2>"]})                      -> Tests to re-run (includes cross-repo)
8. check_guards({ids: ["<id1>"]})                                   -> Project guard rules from .gortex.yaml
9. detect_changes({scope: "staged"})                                -> Pre-commit scope check
10. diff_context({scope: "staged"})                                 -> Graph-enriched diff for review
```

## Understanding Output

| Depth | Risk Level       | Meaning                  |
| ----- | ---------------- | ------------------------ |
| d=1   | **WILL BREAK**   | Direct callers/importers |
| d=2   | LIKELY AFFECTED  | Indirect dependencies    |
| d=3   | MAY NEED TESTING | Transitive effects       |

## Checklist

- search_symbols to find exact symbol IDs
- explain_change_impact with all symbols you plan to change
- Review risk level (LOW/MEDIUM/HIGH/CRITICAL)
- Check by_depth: d=1 items WILL BREAK
- Note affected_processes and affected_communities
- verify_change for every signature change (catches contract violations across repos)
- contracts action=check when changing HTTP routes, gRPC methods, topics, env contracts
- check_guards so team conventions from .gortex.yaml block bad changes early
- get_test_targets to see which test files need re-running
- Before commit: detect_changes to verify scope, diff_context for graph-enriched review
