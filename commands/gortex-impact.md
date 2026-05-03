# Impact Analysis with Gortex

## Workflow

```
1. search_symbols({query: "X"})                                     -> Find the symbol ID
2. explain_change_impact({ids: "<id1>, <id2>"})                     -> Risk-tiered blast radius
3. get_dependents({id: "<symbol-id>", depth: 3})                    -> Detailed dependent tree
4. analyze({kind: "ownership", path_prefix: "<dir>/"})              -> Who owns this area (review pinging)
5. verify_change({id: "<id>", new_signature: "..."})                -> Check callers + interface implementors for signature-level breaks
6. contracts({action: "check"})                                     -> Cross-repo API breakage (HTTP/gRPC/GraphQL/topics)
7. analyze({kind: "would_create_cycle", from: "<a>", to: "<b>"})    -> Before adding a new dep
8. analyze({kind: "error_surface", path_prefix: "<dir>/"})          -> What error surface does this area produce — widening risk
9. get_test_targets({ids: ["<id1>", "<id2>"]})                      -> Tests to re-run (includes cross-repo)
10. analyze({kind: "coverage_gaps", path_prefix: "<dir>/"})         -> Undertested code in the change area — extra-risky refactor zones
11. check_guards({ids: ["<id1>"]})                                  -> Project guard rules from .gortex.yaml
12. detect_changes({scope: "staged"})                               -> Pre-commit scope check
13. diff_context({scope: "staged"})                                 -> Graph-enriched diff for review
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
- analyze kind=ownership path_prefix=<dir>/ — who should review (pinging policy without CODEOWNERS)
- verify_change for every signature change (catches contract violations across repos)
- contracts action=check when changing HTTP routes, gRPC methods, topics, env contracts
- analyze kind=error_surface path_prefix=<dir>/ — confirm the change does not widen the error surface
- analyze kind=coverage_gaps path_prefix=<dir>/ — areas with weak coverage need extra scrutiny
- check_guards so team conventions from .gortex.yaml block bad changes early
- get_test_targets to see which test files need re-running
- Before commit: detect_changes to verify scope, diff_context for graph-enriched review
