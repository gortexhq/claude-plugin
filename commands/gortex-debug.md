# Debugging with Gortex

## Workflow

```
1. search_symbols({query: "<error or suspect>"})          -> Find related symbols
2. get_callers({id: "<suspect>"})                         -> Who calls it?
3. get_call_chain({id: "<suspect>"})                      -> What does it call?
4. get_editing_context({path: "<file>"})                  -> Full file context
5. get_processes({id: "<process>"})                       -> Trace execution flow
6. get_symbol_history                                     -> Symbols churning this session (regression hotspot)
7. explain_change_impact({ids: "<fix target>"})           -> Who else will feel the fix
```

## Debugging Patterns

| Symptom                 | Gortex Approach |
| ----------------------- | --------------- |
| Error message           | search_symbols for error-related names -> get_callers on throw sites; analyze kind=error_surface to map who throws what |
| Wrong return value      | get_call_chain on the function -> trace callees for data flow |
| Intermittent failure    | get_editing_context -> look for external calls, async deps; analyze kind=goroutine_spawns to find unowned background work |
| Channel deadlock        | analyze kind=channel_ops -> channels with sends but no receivers (or vice versa) |
| Performance issue       | find_usages -> find symbols with many callers (hot paths) |
| Recent regression       | detect_changes -> see what your changes affect. get_symbol_history flags symbols edited 3+ times this session |
| Flaky test              | get_untested_symbols near the suspect -> find coverage gaps the flake may hide |
| Stale index suspect     | index_health -> parse failures and stale files can mask the real bug |
| Stale-flag suspect      | analyze kind=stale_flags -> flags with every caller untouched for `older_than` days are dead-rollout candidates |
| Config drift            | analyze kind=config_readers -> who reads this env/viper key? Surfaces forgotten readers |
| Event/log volume spike  | analyze kind=event_emitters with level=error -> find every site that logs an error |
| Mutation race suspicion | analyze kind=field_writers id=<field> -> every function that writes the contended field |
| Annotation drift        | analyze kind=annotation_users name=Deprecated -> every site still using a deprecated API |
