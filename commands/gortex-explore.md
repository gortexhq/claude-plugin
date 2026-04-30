# Exploring Codebases with Gortex

## Workflow

```
1. graph_stats                                  -> Confirm index, get node/edge counts
2. smart_context({task: "<what you want to understand>"}) -> One-call exploration bundle (start here)
3. get_communities                              -> See functional clusters (architecture overview)
4. search_symbols({query: "<concept>"})         -> Find symbols related to a concept
5. get_processes                                -> Discover execution flows
6. get_processes({id: "<process-id>"})          -> Trace a specific flow step by step
7. get_file_summary({path: "<file>"})           -> Symbols + imports for one file
8. get_editing_context({path: "<file>"})        -> Deep dive on a file (callers + callees)
9. export_context({...})                        -> Share findings as markdown/JSON (PRs, Slack, docs)
```

## Checklist

- Call graph_stats to confirm Gortex is running
- Call smart_context first — one call replaces 5-10 exploration calls
- Call get_communities for architecture overview when smart_context is not enough
- Call search_symbols for the concept you want to understand
- Call get_processes to discover execution flows
- Call get_processes with id on relevant flows for step-by-step traces
- Call get_editing_context on key files for full symbol context
- Call export_context to hand a findings packet outside the session
- Read source files only for implementation details you actually need to edit
