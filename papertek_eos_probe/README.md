# PaperTek Eos Focus Remote

A small Flutter remote-control application for ETC Eos-family lighting consoles.

## Transport policy: UDP only

This project uses unframed OSC over UDP only. The live console path that has been
proven in this project is:

- app source: the selected local network interface, using an ephemeral UDP port;
- console destination: the console IP and its configured **OSC UDP RX** port;
- OSC payload: one unframed UDP datagram per command.

Do not switch the application to TCP, add a TCP fallback, or make TCP the default
without an explicit discussion and a new live-console test plan. TCP may be
investigated later, but it is outside the current product boundary.

UDP sending has no session handshake. A command can be sent as soon as the console
endpoint is valid; a UI-level Connect action is not required. A local UDP socket
still has to be opened by the app, but it should be created lazily and transparently
when a command is sent.

Receiving is separate and optional. Live cue feedback and query responses require:

1. a UDP listener in the app;
2. Eos **OSC TX** enabled;
3. the Eos OSC UDP TX destination IP set to this device; and
4. the Eos OSC UDP TX port matching the app's feedback-listen port.

On Android, the app binds its process to the active Wi-Fi `Network` before it
opens UDP sockets. This is required when Android keeps cellular as the default
network because the console Wi-Fi has no internet access. Setup and feedback
startup fail clearly when no Wi-Fi network is available. Commands are not
broadcast across interfaces; each Eos command is still sent exactly once to the
configured console endpoint.

A feedback-listener failure must never disable send-only focus or playback controls.
UDP is fire-and-forget: successful local transmission does not acknowledge that Eos
received or executed a command, and packets can be dropped or arrive out of order.

ETC references:

- [Eos OSC setup](https://www.etcconnect.com/WebDocs/Controls/EosFamilyOnlineHelp/en/Content/23_Show_Control/08_OSC/Using_OSC_with_Eos/Eos_OSC_Setup.htm)
- [Eos OSC control methods](https://www.etcconnect.com/WebDocs/Controls/EosFamilyOnlineHelp/en/Content/23_Show_Control/08_OSC/Using_OSC_with_Eos/OSC_Eos_Control.htm)
- [Eos OSC dictionary](https://www.etcconnect.com/WebDocs/Controls/EosFamilyOnlineHelp/en/Content/23_Show_Control/08_OSC/OSC_Dictionary.htm)

## Current proven console settings

The first live setup used:

- console: `10.101.50.100`;
- app/local Ethernet: `10.101.100.50`;
- console OSC UDP RX: `8000`;
- console OSC UDP TX: `8001`.

These values are cached per device and remain editable. They are examples, not
hard-coded protocol requirements.

The proven channel-level packet is an OSC `int32` percentage sent to
`/eos/chan/<channel>`. For example, channel 1 at 50% sends `/eos/chan/1` with the
integer argument `50`. Do not normalize this value to `0.5`.

## Project layout

```text
lib/
  main.dart                  Flutter entry point
  focus_remote_screen.dart   Current control surface
  osc_log_view.dart          Bounded diagnostic log

packages/eos_osc_client/lib/
  eos_osc_client.dart        Public package exports
  src/osc_codec.dart         OSC 1.0 message codec
  src/eos_tcp_transport.dart Transport interfaces and UDP implementation
  src/eos_protocol.dart      Eos commands and response parsers
  src/eos_client.dart        Reusable Eos client
  src/eos_models.dart        Models, events, interfaces, and errors
```

The file name `eos_tcp_transport.dart` is historical and currently also contains
the UDP implementation. Its presence does not change the UDP-only application
policy.

## Build and test

```powershell
Push-Location .\packages\eos_osc_client
dart test
Pop-Location

flutter analyze
flutter test
flutter build windows --release
flutter build apk --release
```

The Android build requires a JDK/Android toolchain; the Codemagic Android
workflow provides that environment. The Windows workstation build remains the
validated desktop release path.

The current checked-in runner targets Windows. Android support is part of the
tabbed/mobile change specification and requires generating and validating the
Android runner before it is considered supported.

### Codemagic Android build

The repository-root `codemagic.yaml` defines the Android-only
`eos-probe-android` workflow. It uses `papertek_eos_probe` as the monorepo
working directory, runs the protocol and Flutter tests plus analysis, and builds
an unsigned release APK. In Codemagic, scan the branch for `codemagic.yaml` and
select **Eos Probe Android Release** instead of the legacy Workflow Editor
configuration.

The workflow uses Codemagic's default `mac_mini_m2` Android-capable worker and publishes
`build/app/outputs/flutter-apk/app-release.apk`. Signing and store distribution
are intentionally not configured; install the unsigned APK for device testing
or add a Codemagic Android keystore when a signed release is required.

## Safety behavior

- Sending does not depend on feedback reception or a handshake.
- GO, Back, Stop, Record, and Update commands are never automatically retried.
- The app never replays stale commands after restart or network recovery.
- Stopping feedback does not send Out, Release, Stop, or any other console command.
- Endpoint changes are cached, but no command is sent merely by opening the app.
- Record and Update actions require an explicit final Enter from the user.

## Planned interface

The implementation-ready plan for the desktop/mobile tabbed UI is in
[`tickets/EOS_FOCUS_REMOTE_TABBED_MOBILE.md`](../tickets/EOS_FOCUS_REMOTE_TABBED_MOBILE.md).
