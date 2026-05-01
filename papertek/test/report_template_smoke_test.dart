import 'package:flutter_test/flutter_test.dart';
import 'package:papertek/features/reports/report_template.dart';

void main() {
  test('ReportTemplate multipartHeader serialization', () {
    final t1 = ReportTemplate(
      name: 'Test',
      columns: [],
    );
    expect(t1.multipartHeader, false);

    final json = t1.toJson();
    expect(json['multipartHeader'], false);

    final t2 = ReportTemplate.fromJson(json);
    expect(t2.multipartHeader, false);

    final t3 = t1.copyWith(multipartHeader: true);
    expect(t3.multipartHeader, true);

    final json3 = t3.toJson();
    expect(json3['multipartHeader'], true);

    final t4 = ReportTemplate.fromJson(json3);
    expect(t4.multipartHeader, true);

    // Test migration from old JSON (missing key)
    final oldJson = {
      'name': 'Old',
      'columns': [],
    };
    final tOld = ReportTemplate.fromJson(oldJson);
    expect(tOld.multipartHeader, false);
  });
}
