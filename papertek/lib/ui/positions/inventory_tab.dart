// -- Inventory tab barrel export ------------------------------------------------
//
// Re-exports InventoryTab so that callers (show_tab.dart) continue to work with
// their existing import path.  The implementation lives in inventory/.

export 'inventory/inventory_tab_impl.dart' show InventoryTab;
