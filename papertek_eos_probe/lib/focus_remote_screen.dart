import 'package:eos_osc_client/eos_osc_client.dart';
import 'package:flutter/material.dart';

import 'focus/focus_remote_tab.dart';

/// Compatibility entry point retained for callers that hosted the former
/// single-screen probe. The application now uses [RemoteShell].
final class FocusRemoteScreen extends StatelessWidget {
  const FocusRemoteScreen({required this.client, super.key});
  final EosClient client;

  @override
  Widget build(BuildContext context) => FocusRemoteTab(
        client: client,
        sendConfigured: client.connectionState == EosConnectionState.ready,
      );
}
