import 'report_template.dart';

const kDefaultTemplates = <ReportTemplate>[
  // 1. Channel Hookup
  ReportTemplate(
    name: 'Channel Hookup',
    columns: [
      ReportColumn(id: 'chan', label: 'CH', fieldKeys: ['chan'], fixedWidth: 30, isBold: true),
      ReportColumn(id: 'dimmer', label: 'DIM', fieldKeys: ['dimmer'], fixedWidth: 40),
      ReportColumn(id: 'position', label: 'POSITION', fieldKeys: ['position'], fixedWidth: 80),
      ReportColumn(id: 'unit', label: 'U#', fieldKeys: ['unit'], fixedWidth: 30),
      ReportColumn(id: 'stack_purpose_area', label: 'PURPOSE / AREA', fieldKeys: ['function', 'focus'], flex: 1),
      ReportColumn(id: 'stack_instrument', label: 'FULL DEFINITION', fieldKeys: ['type', 'wattage'], flex: 2),
      ReportColumn(id: 'stack_color_template', label: 'COLOR / TEMPLATE', fieldKeys: ['color', 'gobo1'], fixedWidth: 80),
    ],
    groupByFieldKey: 'position',
    sortByFieldKey: 'chan',
    sortAscending: true,
    orientation: 'portrait',
  ),

  // 2. Instrument Schedule
  ReportTemplate(
    name: 'Instrument Schedule',
    columns: [
      ReportColumn(id: 'position', label: 'POSITION', fieldKeys: ['position'], fixedWidth: 100),
      ReportColumn(id: 'unit', label: 'U#', fieldKeys: ['unit'], fixedWidth: 30),
      ReportColumn(id: 'type', label: 'TYPE', fieldKeys: ['type'], flex: 1),
      ReportColumn(id: 'wattage', label: 'WATT', fieldKeys: ['wattage'], fixedWidth: 60),
      ReportColumn(id: 'accessories', label: 'ACCESSORIES', fieldKeys: ['accessories'], flex: 1),
      ReportColumn(id: 'color', label: 'COLOR', fieldKeys: ['color'], fixedWidth: 80),
      ReportColumn(id: 'chan', label: 'CH', fieldKeys: ['chan'], fixedWidth: 40),
      ReportColumn(id: 'dimmer', label: 'DIM', fieldKeys: ['dimmer'], fixedWidth: 50),
    ],
    groupByFieldKey: 'position',
    sortByFieldKey: 'unit',
    sortAscending: true,
    orientation: 'landscape',
  ),

  // 3. Channel Schedule
  ReportTemplate(
    name: 'Channel Schedule',
    columns: [
      ReportColumn(id: 'chan', label: 'CH', fieldKeys: ['chan'], fixedWidth: 40, isBold: true),
      ReportColumn(id: 'dimmer', label: 'DIM', fieldKeys: ['dimmer'], fixedWidth: 50),
      ReportColumn(id: 'circuit', label: 'CKT', fieldKeys: ['circuit'], fixedWidth: 50),
      ReportColumn(id: 'position', label: 'POSITION', fieldKeys: ['position'], fixedWidth: 80),
      ReportColumn(id: 'unit', label: 'U#', fieldKeys: ['unit'], fixedWidth: 30),
      ReportColumn(id: 'function', label: 'PURPOSE', fieldKeys: ['function'], flex: 1),
      ReportColumn(id: 'type', label: 'TYPE', fieldKeys: ['type'], flex: 1),
      ReportColumn(id: 'color', label: 'COLOR', fieldKeys: ['color'], fixedWidth: 60),
    ],
    sortByFieldKey: 'chan',
    sortAscending: true,
    orientation: 'portrait',
  ),
];
