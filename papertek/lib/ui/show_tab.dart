// -- Show tab barrel export -----------------------------------------------------
//
// Re-exports ShowTab so that callers (main_shell.dart) continue to work with
// their existing import path.  The implementation lives in show/.

export 'show/show_tab_impl.dart' show ShowTab;
