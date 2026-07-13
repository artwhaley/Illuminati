# EOS Phase 1 T01 — Stateless UDP send boundary

## Objective

Make proven UDP transmission usable without a Connect/Start prerequisite. Separate
send configuration from optional receive lifecycle while preserving the existing
unframed OSC datagrams and `int32` channel percentages.

This is transport refactoring, not a TCP investigation. Do not send anything to the
live console while implementing or testing this ticket.

## Concrete anchors

- `papertek_eos_probe/packages/eos_osc_client/lib/src/eos_tcp_transport.dart`
  currently contains `EosTransport`, `EosTcpTransport`, and `EosUdpTransport`.
- `EosUdpTransport.connect()` currently creates both the optional receive socket and
  ephemeral send socket.
- `papertek_eos_probe/packages/eos_osc_client/lib/src/eos_client.dart` gates `_send`
  through `_ensureReady()` and a TCP-shaped connection state.
- `papertek_eos_probe/packages/eos_osc_client/lib/src/eos_models.dart` exposes
  `connect()`/`disconnect()` on `EosClient` and combines send/receive settings in
  `EosConnectionConfig`.

## Required behavior

1. Add a pure-Dart UDP sender abstraction that can be configured without opening a
   receive socket and sends on first use without a prior `connect()` call.
2. Lazily bind an ephemeral local source port. Honor an optional local source IPv4;
   blank means OS-selected routing.
3. Retain a sender socket between commands. Recreate it after endpoint changes,
   sender faults, or explicit disposal. Never replay a command.
4. Validate host, destination port 1–65535, channel, and level before sending.
5. Preserve one raw/unframed OSC datagram per command.
6. Preserve `/eos/chan/<channel>` with one OSC `int32` percentage from 0 through
   100. Do not normalize to a float.
7. Report local send success only as “datagram sent” or equivalent. Do not report
   Eos acknowledgement.
8. Define the optional UDP receiver as an independent lifecycle. A receiver bind
   failure must not close, fault, or disable the sender.
9. Keep TCP code compiling for possible future investigation, but the app must not
   instantiate it, probe it, expose it, or fall back to it.
10. Preserve existing query/feedback parsing for later phases. Do not implement Cue
    Stack here.

The cleanest implementation may introduce `EosUdpSender`, `EosUdpReceiver`, and a
small facade. Exact names may differ, but no public API should require a fake UDP
connection state before transmission.

## Tests first

Add pure-Dart loopback tests proving:

- first send works without `connect()`;
- exact level packet bytes decode as OSC `int32 45`;
- endpoint changes route the next datagram to the new fake receiver;
- sender disposal and recreation do not replay stale datagrams;
- receiver bind failure leaves sender able to transmit;
- an invalid endpoint sends nothing;
- TCP transport is never selected by the UDP facade.

Use local loopback sockets only. Do not use the cached console IP.

## Acceptance gates

From `papertek_eos_probe/`:

```powershell
Push-Location packages/eos_osc_client
dart format --output=none --set-exit-if-changed lib test
dart test
Pop-Location
flutter analyze
```

All package tests pass and no new analyzer errors are introduced.

## Completion report

Report the new sender/receiver ownership, exact packet contract, tests run, and
confirmation that no live-console packet and no TCP probe occurred.
