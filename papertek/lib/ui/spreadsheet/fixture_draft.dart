import '../../repositories/fixture_repository.dart';

/// A mutable draft of a fixture being composed in the "Add Fixture" sidebar.
///
/// The [mask] is a set of column IDs that were selected for prefill from a
/// donor row. Fields not in the mask are left null even when a donor exists.
class FixtureDraft {
  // ── Fixture-level fields ────────────────────────────────────────────────────
  String? position;
  int?    unitNumber;
  String? fixtureType;
  String? wattage;
  String? function;
  String? focus;
  String? accessories;

  // ── Intensity-part fields ───────────────────────────────────────────────────
  String? channel;
  String? dimmer;    // stored as `address` in fixture_parts
  String? circuit;
  String? ipAddress;
  String? subnet;
  String? macAddress;
  String? ipv6;

  // ── Other-part fields ───────────────────────────────────────────────────────
  String? color;
  String? gobo;

  // ── Factory: empty draft ────────────────────────────────────────────────────
  FixtureDraft({
    this.position,
    this.unitNumber,
    this.fixtureType,
    this.wattage,
    this.function,
    this.focus,
    this.accessories,
    this.channel,
    this.dimmer,
    this.circuit,
    this.ipAddress,
    this.subnet,
    this.macAddress,
    this.ipv6,
    this.color,
    this.gobo,
  });

  // ── Factory: prefill from donor using mask ──────────────────────────────────
  factory FixtureDraft.fromDonor(FixtureRow donor, Set<String> mask) {
    final d = FixtureDraft();
    if (mask.contains('position'))    d.position    = donor.position;
    if (mask.contains('unit'))        d.unitNumber  = donor.unitNumber;
    if (mask.contains('type'))        d.fixtureType = donor.fixtureType;
    if (mask.contains('wattage'))     d.wattage     = donor.wattage;
    if (mask.contains('function'))    d.function    = donor.function;
    if (mask.contains('focus'))       d.focus       = donor.focus;
    if (mask.contains('accessories')) d.accessories = donor.accessories;
    if (mask.contains('chan'))        d.channel     = donor.channel;
    if (mask.contains('dimmer'))      d.dimmer      = donor.dimmer;
    if (mask.contains('circuit'))     d.circuit     = donor.circuit;
    if (mask.contains('ip'))          d.ipAddress   = donor.ipAddress;
    if (mask.contains('subnet'))      d.subnet      = donor.subnet;
    if (mask.contains('mac'))         d.macAddress  = donor.macAddress;
    if (mask.contains('ipv6'))        d.ipv6        = donor.ipv6;
    if (mask.contains('color'))       d.color       = donor.color;
    if (mask.contains('gobo'))        d.gobo        = donor.gobo;
    return d;
  }

  /// After a successful insert with [continueAdding] = true, advance
  /// fields that should auto-increment and clear fields that should reset.
  ///
  /// - unitNumber is incremented if non-null.
  /// - channel, dimmer, circuit are cleared (they are almost always unique per fixture).
  void advanceForContinue() {
    if (unitNumber != null) unitNumber = unitNumber! + 1;
    channel = null;
    dimmer  = null;
    circuit = null;
  }
}
