import 'package:flutter/material.dart';

import 'remote_shell.dart';

void main() {
  runApp(const PaperTekEosProbeApp());
}

final class PaperTekEosProbeApp extends StatelessWidget {
  const PaperTekEosProbeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PaperTek Eos Focus Remote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff315c86)),
        useMaterial3: true,
      ),
      home: const RemoteShell(),
    );
  }
}
