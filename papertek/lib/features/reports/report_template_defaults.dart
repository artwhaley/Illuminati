import 'report_template.dart';

const kDefaultTemplates = [
  ReportTemplate(
    name: 'Instrument Schedule',
    columns: [
      ReportColumn(id: 'position', label: 'POSITION', fieldKeys: ['position'], widthPercent: 22),
      ReportColumn(id: 'unit',     label: 'U#',       fieldKeys: ['unit'],     widthPercent: 6),
      ReportColumn(id: 'type',     label: 'TYPE',     fieldKeys: ['type'],     widthPercent: 28),
      ReportColumn(id: 'function', label: 'PURPOSE',  fieldKeys: ['function'], widthPercent: 22),
      ReportColumn(id: 'color',    label: 'COLOR',    fieldKeys: ['color'],    widthPercent: 10),
      ReportColumn(id: 'chan',     label: 'CH',       fieldKeys: ['chan'],     widthPercent: 6),
      ReportColumn(id: 'dimmer',   label: 'DIM',      fieldKeys: ['dimmer'],   widthPercent: 6),
    ],
    groupByFieldKey: 'position',
    sortLevels: [
      SortLevel(fieldKey: 'position', ascending: true),
      SortLevel(fieldKey: 'unit', ascending: true),
    ],
    orientation: 'landscape',
  ),
  ReportTemplate(
    name: 'Channel Hookup',
    columns: [
      ReportColumn(id: 'chan',     label: 'CHAN',       fieldKeys: ['chan'],     widthPercent: 8,  isBold: true),
      ReportColumn(id: 'dimmer',   label: 'DIM / ADDR', fieldKeys: ['dimmer'],  widthPercent: 14),
      ReportColumn(id: 'type',     label: 'INSTRUMENT', fieldKeys: ['type'],    widthPercent: 28),
      ReportColumn(id: 'position', label: 'POSITION',   fieldKeys: ['position'],widthPercent: 22),
      ReportColumn(id: 'function', label: 'PURPOSE',    fieldKeys: ['function'],widthPercent: 20),
      ReportColumn(id: 'color',    label: 'COLOR',      fieldKeys: ['color'],   widthPercent: 8),
    ],
    sortLevels: [
      SortLevel(fieldKey: 'chan', ascending: true),
    ],
    orientation: 'portrait',
  ),
  ReportTemplate(
    name: 'Dimmer Hookup',
    columns: [
      ReportColumn(id: 'dimmer',   label: 'DIM',        fieldKeys: ['dimmer'],  widthPercent: 14, isBold: true),
      ReportColumn(id: 'chan',     label: 'CHAN',        fieldKeys: ['chan'],    widthPercent: 8),
      ReportColumn(id: 'type',     label: 'INSTRUMENT', fieldKeys: ['type'],    widthPercent: 40),
      ReportColumn(id: 'position', label: 'POSITION',   fieldKeys: ['position'],widthPercent: 38),
    ],
    sortLevels: [
      SortLevel(fieldKey: 'dimmer', ascending: true),
    ],
    orientation: 'portrait',
  ),
];
