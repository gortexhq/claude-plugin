# Refactoring with Gortex

## Workflow

```
1. search_symbols({query: "X"})                                     -> Find the symbol ID
2. explain_change_impact({ids: "<id>"})                             -> Map blast radius
3. verify_change({id: "<id>", new_signature: "..."})                -> Catch contract violations in callers + implementors
4. get_editing_context({path: "<file>"})                            -> See all symbols and relationships
5. find_usages({id: "<id>"})                                        -> Every reference to change
6. get_edit_plan({ids: ["<id1>", "<id2>"]})                         -> Dependency-ordered file list
7. batch_edit({edits: [...]})                                       -> Apply edits in order, re-indexing between steps
8. check_guards({ids: [...]})                                       -> Post-edit: team conventions from .gortex.yaml
9. get_test_targets({ids: [...]})                                   -> Tests to re-run (cross-repo aware)
10. detect_changes({scope: "all"})                                  -> Verify scope; diff_context for review
```

## Rename Symbol

- search_symbols to find the symbol ID
- explain_change_impact to assess blast radius
- verify_change before signature-changing renames — fails fast on interface breaks
- rename_symbol({id: "<id>", new_name: "<name>"}) — generates edits for definition + all references
- Review the generated edits, apply via batch_edit or edit_symbol (no Read→Edit roundtrip)
- check_guards, then detect_changes to verify only expected files changed

## Extract Module

- get_editing_context on the source file — see all symbols
- get_dependents on symbols to extract — find external callers
- explain_change_impact on symbols being moved
- analyze({kind: "would_create_cycle", from: "<new module>", to: "<old module>"}) before wiring imports
- suggest_pattern + scaffold from a comparable existing module — generates code, wiring, test stubs
- Extract code, update imports (find_import_path for correct paths)
- get_edit_plan + batch_edit for dependency-ordered atomic application
- check_guards, detect_changes to verify affected scope

## Split Function/Service

- get_call_chain on the function — understand all callees
- Group callees by responsibility
- get_callers to map all call sites that need updating
- find_implementations when splitting along an interface
- explain_change_impact for full blast radius
- Create new functions/services (scaffold from a similar example)
- Update callers (find_usages for precise locations, batch_edit to apply in order)
- check_guards, detect_changes to verify affected scope

## API Contract Changes

- Before changing an HTTP route, gRPC method, topic, env, or OpenAPI contract: contracts({action: "check"}) to find cross-repo consumers
- verify_change on the provider signature
- Coordinate consumer-side edits in the same batch_edit when repos are tracked together
