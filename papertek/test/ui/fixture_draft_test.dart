import 'package:flutter_test/flutter_test.dart';
import 'package:papertek/ui/spreadsheet/fixture_draft.dart';
import 'package:papertek/repositories/fixture_repository.dart';

void main() {
  group('FixtureDraft', () {
    final donor = FixtureRow(
      id: 1, position: 'Balcony Rail', unitNumber: 5,
      fixtureType: 'Source Four', flagged: false, patched: false,
      sortOrder: 1.0, hung: false, focused: false,
      channel: '42', dimmer: '42/5',
    );

    test('empty() creates all-null draft', () {
      final d = FixtureDraft();
      expect(d.position, isNull);
      expect(d.channel, isNull);
    });

    test('fromDonor copies only masked fields', () {
      final d = FixtureDraft.fromDonor(donor, {'position', 'type'});
      expect(d.position, 'Balcony Rail');
      expect(d.fixtureType, 'Source Four');
      expect(d.channel, isNull); // chan not in mask
      expect(d.unitNumber, isNull); // unit not in mask
    });

    test('advanceForContinue increments unitNumber and clears patch fields', () {
      final d = FixtureDraft.fromDonor(donor, {'unit', 'chan', 'dimmer'});
      d.advanceForContinue();
      expect(d.unitNumber, 6);
      expect(d.channel, isNull);
      expect(d.dimmer, isNull);
    });
  });
}
