// -- sub_tab_panel.dart -----------------------------------------------------
//
// Tabs containing positions, inventory, and venue infrastructure sub-tabs.

import 'package:flutter/material.dart';
import '../positions/lighting_positions_tab.dart';
import '../positions/inventory_tab.dart';
import '../positions/venue_tabs.dart';

class SubTabPanel extends StatefulWidget {
  const SubTabPanel();

  @override
  State<SubTabPanel> createState() => _SubTabPanelState();
}

class _SubTabPanelState extends State<SubTabPanel>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tab,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            controller: _tab,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Positions'),
              Tab(text: 'Inventory'),
              Tab(text: 'Channels'),
              Tab(text: 'Addresses'),
              Tab(text: 'Dimmers'),
              Tab(text: 'Circuits'),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: IndexedStack(
              index: _tab.index,
              // IndexedStack preserves each tab's state (scroll + selection) across
              // switches. TabBarView would rebuild offscreen tabs and lose state.
              children: const [
                LightingPositionsTab(),
                InventoryTab(),
                ChannelsTab(),
                AddressesTab(),
                DimmersTab(),
                CircuitsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

