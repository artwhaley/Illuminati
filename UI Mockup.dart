// PaperTek — desktop UI mockup (design reference; not wired to Drift/Supabase).
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const PaperTekApp());

class PaperTekApp extends StatelessWidget {
  const PaperTekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PaperTek',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0D11),
        dividerTheme:
            const DividerThemeData(color: Color(0xFF23272E), space: 1),
      ),
      home: const MainDashboard(),
    );
  }
}

class AppColors {
  static const bg0 = Color(0xFF0B0D11);
  static const bg1 = Color(0xFF13161B);
  static const panel = Color(0xFF191C22);
  static const border = Color(0xFF23272E);
  static const amber = Color(0xFFE5A50A);
  static const amberDim = Color(0xFF2A2418);
  static const textMuted = Color(0xFF5C6370);
  static const textMain = Color(0xFFC4C7CC);
}

/// One row in the main fixture grid (matches spreadsheet columns in the spec).
class Fixture {
  final int chan;
  final String dimmer;
  final String circuit;
  final String position;
  final int unit;
  final String type;
  final String wattage;
  final String color;
  final String gobo1;
  final String gobo2;
  final String function;
  final String focus;
  final String notes;
  final bool patched;
  final bool flagged;

  Fixture({
    required this.chan,
    required this.dimmer,
    required this.circuit,
    required this.position,
    required this.unit,
    required this.type,
    required this.wattage,
    required this.color,
    required this.gobo1,
    required this.gobo2,
    required this.function,
    required this.focus,
    required this.notes,
    this.patched = true,
    this.flagged = false,
  });
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int selectedIndex = 0;
  String selectedTab = 'Spreadsheet';

  final List<Fixture> fixtures = [
    Fixture(
        chan: 101,
        dimmer: '2-15',
        circuit: '2-015',
        position: '1st Electric',
        unit: 7,
        type: 'Source Four 36°',
        wattage: '575W',
        color: 'R02',
        gobo1: '-',
        gobo2: '-',
        function: 'Down Lt Wash',
        focus: 'CS',
        notes: '-',
        patched: true,
        flagged: false),
    Fixture(
        chan: 102,
        dimmer: '2-16',
        circuit: '2-016',
        position: '1st Electric',
        unit: 8,
        type: 'Source Four 36°',
        wattage: '575W',
        color: 'R02',
        gobo1: '-',
        gobo2: '-',
        function: 'Down Lt Wash',
        focus: 'CSL',
        notes: '-',
        patched: true,
        flagged: false),
    Fixture(
        chan: 103,
        dimmer: '2-17',
        circuit: '2-017',
        position: '1st Electric',
        unit: 9,
        type: 'Source Four 36°',
        wattage: '575W',
        color: 'R02',
        gobo1: '-',
        gobo2: '-',
        function: 'Down Lt Wash',
        focus: 'CSR',
        notes: '-',
        patched: true,
        flagged: false),
    Fixture(
        chan: 104,
        dimmer: '2-18',
        circuit: '2-018',
        position: '1st Electric',
        unit: 10,
        type: 'Source Four 36°',
        wattage: '575W',
        color: 'L201',
        gobo1: '-',
        gobo2: '-',
        function: 'Down Cool Wash',
        focus: 'CS',
        notes: '-',
        patched: true,
        flagged: false),
    Fixture(
        chan: 105,
        dimmer: '2-19',
        circuit: '2-019',
        position: '1st Electric',
        unit: 11,
        type: 'Source Four 36°',
        wattage: '575W',
        color: 'L201',
        gobo1: '-',
        gobo2: '-',
        function: 'Down Cool Wash',
        focus: 'DSL',
        notes: '-',
        patched: true,
        flagged: false),
    Fixture(
        chan: 106,
        dimmer: '2-20',
        circuit: '2-020',
        position: '1st Electric',
        unit: 12,
        type: 'Source Four 36°',
        wattage: '575W',
        color: 'L201',
        gobo1: '-',
        gobo2: '-',
        function: 'Down Cool Wash',
        focus: 'DSR',
        notes: 'CHECK CABLE',
        patched: true,
        flagged: true),
    Fixture(
        chan: 111,
        dimmer: '2-01',
        circuit: '2-001',
        position: '1st Electric',
        unit: 1,
        type: 'ETC Lustr+ Array',
        wattage: 'LED',
        color: 'LED',
        gobo1: '-',
        gobo2: '-',
        function: 'Color Special',
        focus: 'US CS',
        notes: '-',
        patched: true,
        flagged: false),
    Fixture(
        chan: 112,
        dimmer: '2-02',
        circuit: '2-002',
        position: '1st Electric',
        unit: 2,
        type: 'ETC Lustr+ Array',
        wattage: 'LED',
        color: 'LED',
        gobo1: '-',
        gobo2: '-',
        function: 'Color Special',
        focus: 'DS CS',
        notes: '-',
        patched: true,
        flagged: false),
    Fixture(
        chan: 121,
        dimmer: '2-05',
        circuit: '2-005',
        position: '1st Electric',
        unit: 3,
        type: 'Source Four 19°',
        wattage: '575W',
        color: 'N/C',
        gobo1: 'R77735',
        gobo2: '-',
        function: 'Breakup',
        focus: 'CS',
        notes: '-',
        patched: true,
        flagged: false),
    Fixture(
        chan: 122,
        dimmer: '2-06',
        circuit: '2-006',
        position: '1st Electric',
        unit: 4,
        type: 'Source Four 19°',
        wattage: '575W',
        color: 'N/C',
        gobo1: 'R77735',
        gobo2: '-',
        function: '● Breakup',
        focus: 'USL',
        notes: '-',
        patched: true,
        flagged: false),
    Fixture(
        chan: 123,
        dimmer: '2-07',
        circuit: '2-007',
        position: '1st Electric',
        unit: 5,
        type: 'Source Four 19°',
        wattage: '575W',
        color: '6940',
        gobo1: 'R77720',
        gobo2: '-',
        function: 'Texture',
        focus: 'USR',
        notes: '-',
        patched: true,
        flagged: false),
    Fixture(
        chan: 131,
        dimmer: '2-10',
        circuit: '2-010',
        position: '1st Electric',
        unit: 6,
        type: 'GLP JDC1',
        wattage: 'LED',
        color: 'LED',
        gobo1: '-',
        gobo2: '-',
        function: 'Strobe FX',
        focus: 'CS',
        notes: 'DP unit',
        patched: true,
        flagged: false),
    Fixture(
        chan: 201,
        dimmer: '3-01',
        circuit: '3-001',
        position: '2nd Electric',
        unit: 1,
        type: 'Source Four 36°',
        wattage: '575W',
        color: 'R02',
        gobo1: '-',
        gobo2: '-',
        function: 'Mid Wash',
        focus: 'CS',
        notes: '-',
        patched: true,
        flagged: false),
    Fixture(
        chan: 202,
        dimmer: '3-02',
        circuit: '3-002',
        position: '2nd Electric',
        unit: 2,
        type: 'Source Four 36°',
        wattage: '575W',
        color: 'R02',
        gobo1: '-',
        gobo2: '-',
        function: 'Mid Wash',
        focus: 'SL',
        notes: '-',
        patched: true,
        flagged: false),
    Fixture(
        chan: 203,
        dimmer: '3-03',
        circuit: '3-003',
        position: '2nd Electric',
        unit: 3,
        type: 'Source Four 36°',
        wattage: '575W',
        color: 'R02',
        gobo1: '-',
        gobo2: '-',
        function: 'Mid Wash',
        focus: 'SR',
        notes: '-',
        patched: true,
        flagged: false),
    Fixture(
        chan: 211,
        dimmer: '3-05',
        circuit: '3-005',
        position: '2nd Electric',
        unit: 4,
        type: 'Vari*Lite VL3500',
        wattage: 'LED',
        color: 'LED',
        gobo1: 'Custom',
        gobo2: '-',
        function: 'Moving Spot',
        focus: '-',
        notes: 'Net ID 201',
        patched: true,
        flagged: false),
    Fixture(
        chan: 212,
        dimmer: '3-06',
        circuit: '3-006',
        position: '2nd Electric',
        unit: 5,
        type: 'Vari*Lite VL3500',
        wattage: 'LED',
        color: 'LED',
        gobo1: 'Custom',
        gobo2: '-',
        function: 'Moving Spot',
        focus: '-',
        notes: 'Net ID 202',
        patched: true,
        flagged: false),
    Fixture(
        chan: 301,
        dimmer: '4-01',
        circuit: '4-001',
        position: '3rd Electric',
        unit: 1,
        type: 'Source Four PAR',
        wattage: '575W',
        color: 'R05',
        gobo1: '-',
        gobo2: '-',
        function: 'Backlight',
        focus: 'CS',
        notes: '-',
        patched: true,
        flagged: false),
    Fixture(
        chan: 302,
        dimmer: '4-02',
        circuit: '4-002',
        position: '3rd Electric',
        unit: 2,
        type: 'Source Four PAR',
        wattage: '575W',
        color: 'R05',
        gobo1: '-',
        gobo2: '-',
        function: 'Backlight',
        focus: 'USL',
        notes: '-',
        patched: true,
        flagged: false),
    Fixture(
        chan: 303,
        dimmer: '4-03',
        circuit: '4-003',
        position: '3rd Electric',
        unit: 3,
        type: 'Source Four PAR',
        wattage: '575W',
        color: 'R05',
        gobo1: '-',
        gobo2: '-',
        function: 'Backlight',
        focus: 'USR',
        notes: '-',
        patched: true,
        flagged: false),
    Fixture(
        chan: 401,
        dimmer: '5-01',
        circuit: '5-001',
        position: 'Balcony Rail',
        unit: 1,
        type: 'Source Four 50°',
        wattage: '575W',
        color: 'L202',
        gobo1: '-',
        gobo2: '-',
        function: 'Front Lt Wash',
        focus: 'CS',
        notes: '-',
        patched: true,
        flagged: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildTopMenu(),
          Expanded(
            child: Row(
              children: [
                SidebarWidget(
                  selectedFixture: fixtures[selectedIndex],
                  onAddFixture: () {},
                  onCloneFixture: () {},
                ),
                const VerticalDivider(),
                Expanded(
                  child: SpreadsheetWidget(
                    fixtures: fixtures,
                    selectedIndex: selectedIndex,
                    onRowSelected: (int index) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          BottomNavigationBarWidget(
            selectedTab: selectedTab,
            onTabSelected: (String tabName) {
              setState(() {
                selectedTab = tabName;
              });
            },
          ),
          StatusBarWidget(
            totalFixtures: fixtures.length,
            selectedFixtures: 1,
            filter: '1st Electric',
            connectionStatus: 'CONNECTED',
            readiness: 'Ready',
            showName: 'Hamlet',
            mode: 'Tech',
          ),
        ],
      ),
    );
  }

  Widget _buildTopMenu() {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppColors.bg0,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: <Widget>[
          Text("PaperTek",
              style: GoogleFonts.dmSans(
                color: AppColors.amber,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.5,
              )),
          const SizedBox(width: 24),
          ...<String>[
            'File',
            'Edit',
            'View',
            'Selection',
            'Help'
          ].map<Padding>((String e) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(e,
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.textMain)),
              )),
        ],
      ),
    );
  }
}

class SidebarWidget extends StatelessWidget {
  final Fixture selectedFixture;
  final VoidCallback onAddFixture;
  final VoidCallback onCloneFixture;

  const SidebarWidget({
    super.key,
    required this.selectedFixture,
    required this.onAddFixture,
    required this.onCloneFixture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(color: AppColors.bg1),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AddCloneButtons(
              onAddFixture: onAddFixture, onCloneFixture: onCloneFixture),
          const SizedBox(height: 16),
          Expanded(
            child: PropertiesPanel(fixture: selectedFixture),
          ),
        ],
      ),
    );
  }
}

class AddCloneButtons extends StatelessWidget {
  final VoidCallback onAddFixture;
  final VoidCallback onCloneFixture;

  const AddCloneButtons({
    super.key,
    required this.onAddFixture,
    required this.onCloneFixture,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        OutlinedButton(
          onPressed: onAddFixture,
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.amberDim,
            side: const BorderSide(color: Color(0xFF7A5A00)),
            foregroundColor: AppColors.amber,
            minimumSize: const Size(double.infinity, 36),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: const Text("+ Add Fixture",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onCloneFixture,
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.bg1,
            side: const BorderSide(color: AppColors.border),
            foregroundColor: AppColors.textMain,
            minimumSize: const Size(double.infinity, 36),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: const Text("Clone Fixture",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ),
      ],
    );
  }
}

class PropertiesPanel extends StatelessWidget {
  final Fixture fixture;

  const PropertiesPanel({
    super.key,
    required this.fixture,
  });

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 12.0),
      child: Row(
        children: <Widget>[
          const Icon(Icons.tune, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                  letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _propItem(String label, String value,
      {bool isAmber = false, bool isYesNo = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          SizedBox(
              width: 65,
              child: Text(label,
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.textMuted))),
          Expanded(
              child: Text(value,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    color: isAmber
                        ? AppColors.amber
                        : (isYesNo
                            ? (value == 'Yes' ? Colors.green : AppColors.textMain)
                            : AppColors.textMain),
                    fontWeight: isYesNo ? FontWeight.w600 : FontWeight.normal,
                  ))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView(
        children: <Widget>[
          _buildSectionHeader("SELECTION"),
          _propItem("Channel", fixture.chan.toString(), isAmber: true),
          _propItem("Dimmer", fixture.dimmer),
          _propItem("Circuit", fixture.circuit),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
          _buildSectionHeader("FIXTURE"),
          _propItem("Position", fixture.position),
          _propItem("Unit #", fixture.unit.toString()),
          _propItem("Type", fixture.type),
          _propItem("Wattage", fixture.wattage),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
          _buildSectionHeader("COLOR & GOBO"),
          _propItem("Color", fixture.color, isAmber: true),
          _propItem("Gobo 1", fixture.gobo1),
          _propItem("Gobo 2", fixture.gobo2),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
          _buildSectionHeader("PURPOSE"),
          _propItem("Function", fixture.function),
          _propItem("Focus", fixture.focus),
          _propItem("Notes", fixture.notes),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
          _buildSectionHeader("STATUS"),
          _propItem("Patched", fixture.patched ? "Yes" : "No", isYesNo: true),
          _propItem("Flagged", fixture.flagged ? "Yes" : "No", isYesNo: true),
        ],
      ),
    );
  }
}

// Wraps both the sticky header and the scrollable rows in a single horizontal
// scroll so they always stay in sync.
class SpreadsheetWidget extends StatefulWidget {
  final List<Fixture> fixtures;
  final int selectedIndex;
  final ValueChanged<int> onRowSelected;

  const SpreadsheetWidget({
    super.key,
    required this.fixtures,
    required this.selectedIndex,
    required this.onRowSelected,
  });

  @override
  State<SpreadsheetWidget> createState() => _SpreadsheetWidgetState();
}

class _SpreadsheetWidgetState extends State<SpreadsheetWidget> {
  final ScrollController _horizontalScroll = ScrollController();

  static const double _totalGridWidth = 1240;

  @override
  void dispose() {
    _horizontalScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.panel),
      child: Column(
        children: <Widget>[
          const SpreadsheetToolbar(),
          Expanded(
            child: SingleChildScrollView(
              controller: _horizontalScroll,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: _totalGridWidth,
                child: Column(
                  children: <Widget>[
                    const SpreadsheetHeader(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.fixtures.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Fixture row = widget.fixtures[index];
                          final bool isSelected = index == widget.selectedIndex;
                          return GestureDetector(
                            onTap: () => widget.onRowSelected(index),
                            child: SpreadsheetRow(
                              index: index + 1,
                              fixture: row,
                              isSelected: isSelected,
                              isEvenRow: index.isEven,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SpreadsheetToolbar extends StatelessWidget {
  const SpreadsheetToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: <Widget>[
          Container(
            width: 200,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.bg0,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: <Widget>[
                const Icon(Icons.search, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Text("Search...",
                    style: GoogleFonts.dmSans(
                        color: AppColors.textMuted, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _buildToolbarButton(label: "T↓ Sort", icon: Icons.sort),
          const SizedBox(width: 8),
          _buildToolbarButton(label: "Filter 1", icon: Icons.filter_list),
          const SizedBox(width: 8),
          _buildFilterChip("1st Electric", onPressed: () {}),
          const Spacer(),
          _buildToolbarButton(label: "Columns", icon: Icons.keyboard_arrow_down),
          const SizedBox(width: 16),
          const Icon(Icons.menu, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 16),
          const Icon(Icons.grid_view, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({required String label, required IconData icon}) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(label,
              style:
                  const TextStyle(color: AppColors.textMuted, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {VoidCallback? onPressed}) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.amberDim,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.amber),
      ),
      child: Row(
        children: <Widget>[
          Text(label, style: const TextStyle(color: AppColors.amber, fontSize: 12)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onPressed,
            child: const Icon(Icons.close, size: 18, color: AppColors.amber),
          ),
        ],
      ),
    );
  }
}

class SpreadsheetHeader extends StatelessWidget {
  const SpreadsheetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.bg1,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: <Widget>[
          _headerCell("#", width: 40),
          _headerCell("CHAN", width: 60),
          _headerCell("DIMMER", width: 80),
          _headerCell("CIRCUIT", width: 80),
          _headerCell("POSITION", width: 140),
          _headerCell("U#", width: 50),
          _headerCell("FIXTURE TYPE", width: 160),
          _headerCell("W", width: 50),
          _headerCell("COLOR", width: 80),
          _headerCell("GOBO 1", width: 80),
          _headerCell("GOBO 2", width: 80),
          _headerCell("FUNCTION", width: 140),
          _headerCell("FOCUS", width: 80),
          _headerCell("NOTES", width: 120),
          _headerCell("PATCH", width: 60),
          _headerCell("!", width: 40),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {double width = 100}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class SpreadsheetRow extends StatelessWidget {
  final int index;
  final Fixture fixture;
  final bool isSelected;
  final bool isEvenRow;

  const SpreadsheetRow({
    super.key,
    required this.index,
    required this.fixture,
    required this.isSelected,
    required this.isEvenRow,
  });

  @override
  Widget build(BuildContext context) {
    Color rowBackgroundColor = Colors.transparent;
    if (isSelected) {
      rowBackgroundColor = const Color(0xFF2D2A1C);
    } else if (!isEvenRow) {
      rowBackgroundColor = const Color(0xFF1D2026);
    }

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: rowBackgroundColor,
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: <Widget>[
          _cell(index.toString(),
              width: 40,
              color: isSelected ? AppColors.textMain : AppColors.textMuted,
              bold: isSelected),
          _cell(fixture.chan.toString(),
              width: 60, isAmber: true, bold: true),
          _cell(fixture.dimmer, width: 80, isAmber: isSelected),
          _cell(fixture.circuit, width: 80, isAmber: isSelected),
          _cell(fixture.position, width: 140, isAmber: isSelected),
          _cell(fixture.unit.toString(), width: 50, isAmber: isSelected),
          _cell(fixture.type, width: 160, isAmber: isSelected),
          _cell(fixture.wattage,
              width: 50,
              specialColor: fixture.wattage == 'LED' ? Colors.green : null,
              isAmber: isSelected),
          _cell(fixture.color,
              width: 80,
              specialColor: fixture.color == 'LED'
                  ? Colors.green
                  : (fixture.color == '6940' ? AppColors.amber : null),
              isAmber: isSelected),
          _cell(fixture.gobo1, width: 80, isAmber: isSelected),
          _cell(fixture.gobo2, width: 80, isAmber: isSelected),
          _cell(fixture.function, width: 140, isAmber: isSelected),
          _cell(fixture.focus, width: 80, isAmber: isSelected),
          _cell(fixture.notes,
              width: 120,
              specialColor: fixture.notes != '-' ? AppColors.amber : null,
              isAmber: isSelected),
          _cell(fixture.patched ? "●" : "○",
              width: 60,
              color: fixture.patched ? Colors.green : AppColors.textMuted),
          _cell(fixture.flagged ? "⚑" : "",
              width: 40,
              color: fixture.flagged ? AppColors.amber : AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _cell(
    String text, {
    double width = 100,
    bool isAmber = false,
    bool bold = false,
    Color? color,
    Color? specialColor,
  }) {
    Color textColor = AppColors.textMain;
    if (color != null) {
      textColor = color;
    } else if (specialColor != null && !isSelected) {
      textColor = specialColor;
    } else if (isAmber) {
      textColor = AppColors.amber;
    }

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class BottomNavigationBarWidget extends StatelessWidget {
  final String selectedTab;
  final ValueChanged<String> onTabSelected;

  const BottomNavigationBarWidget({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.bg0,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _navItem("Show", Icons.theater_comedy,
              isActive: selectedTab == "Show",
              onTap: () => onTabSelected("Show")),
          _navItem("Spreadsheet", Icons.table_chart,
              isActive: selectedTab == "Spreadsheet",
              onTap: () => onTabSelected("Spreadsheet")),
          _navItem("Work Notes", Icons.notes,
              isActive: selectedTab == "Work Notes",
              onTap: () => onTabSelected("Work Notes")),
          _navItem("Maintenance", Icons.build_circle,
              isActive: selectedTab == "Maintenance",
              onTap: () => onTabSelected("Maintenance")),
          _navItem("Reports", Icons.fax_rounded,
              isActive: selectedTab == "Reports",
              onTap: () => onTabSelected("Reports")),
        ],
      ),
    );
  }

  Widget _navItem(String label, IconData icon,
      {bool isActive = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: isActive
              ? const Border(top: BorderSide(color: AppColors.amber, width: 2))
              : null,
        ),
        child: Row(
          children: <Widget>[
            Icon(icon,
                size: 18,
                color: isActive ? AppColors.amber : AppColors.textMuted),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? AppColors.amber : AppColors.textMuted,
                )),
          ],
        ),
      ),
    );
  }
}

class StatusBarWidget extends StatelessWidget {
  final int totalFixtures;
  final int selectedFixtures;
  final String filter;
  final String connectionStatus;
  final String readiness;
  final String showName;
  final String mode;

  const StatusBarWidget({
    super.key,
    required this.totalFixtures,
    required this.selectedFixtures,
    required this.filter,
    required this.connectionStatus,
    required this.readiness,
    required this.showName,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF07080A),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.circle, size: 8, color: Colors.green),
          const SizedBox(width: 12),
          Text(
            connectionStatus.isNotEmpty
                ? "LOCAL · $connectionStatus"
                : "LOCAL",
            style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          if (filter.isNotEmpty) ...<Widget>[
            Text('Filter: $filter',
                style: GoogleFonts.dmSans(
                    fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(width: 16),
          ],
          Text("$totalFixtures fixtures",
              style:
                  GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(width: 24),
          Text("$selectedFixtures selected",
              style:
                  GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted)),
          const Spacer(),
          Text(readiness,
              style:
                  GoogleFonts.dmSans(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(width: 16),
          Text(showName,
              style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: AppColors.textMain,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text('· $mode',
              style:
                  GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
