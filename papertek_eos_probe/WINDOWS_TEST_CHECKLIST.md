# Windows rehearsal checklist

This checklist is for the user-led console session after reviewing the Release directory. The executor did not run it.

1. In **Setup**, verify the cached endpoint and ports. Leave feedback stopped. On one explicitly agreed safe channel, send a known level and Release it; confirm no Start/Connect action was needed.
2. In **Focus Remote**, resize the window narrow and wide. Confirm the telephone keypad and every action row retain their portrait ordering without reshuffling or horizontal overflow.
3. On the designated safe channel, enter `<channel> Full`, then press bare **Release**. Confirm the TX log shows that same channel in both commands. Press bare **@**, enter `55`, then **Enter**; confirm the remembered channel is visibly inserted on the command line and appears in the single TX entry. Repeat with bare Out only if safe.
4. Test Previous/Next only after adjacent channels are confirmed safe. Test Position/Color/Beam only on an agreed suitable fixture and palette. Test Record/Update/Cue Only only in a disposable test-cue context.
5. Configure Eos OSC TX IP as this computer's show-network address and OSC UDP TX port as the App UDP RX port, then start feedback. Confirm Setup reports `0.0.0.0:8001`. In Cue Stack, confirm **Raw UDP packets** rises and **Last raw packet** shows the console address. If the count stays zero, recheck Eos OSC TX, the console interface's **UDP Strings & OSC** setting, and Windows Firewall. If the count rises but **Decode errors** is nonzero, capture the Diagnostics entry. Confirm current/next cue identity, labels, and last-feedback time update.
6. In **Cue Stack**, choose a disposable/safe cue list or rehearsal context. Test GO once and verify one advance, Stop during a timed fade, then Back once. Back now uses Eos's main-playback **Stop/Back** key; confirm it moves back exactly once while no fade is active. Verify labels and determinate progress behavior.
7. With the selected cue list safe to reset, press **Go to Cue 0** once. Confirm one `/eos/newcmd` TX entry and that Eos returns the selected cue list to cue 0/top. This can fade cue-owned intensities out, so do not test it on a live output state.
8. Stop feedback. Confirm Focus and GO/Back/Stop/Go to Cue 0 remain enabled and that no stale command is replayed. Restore feedback and confirm normal updates resume.

Each playback control should produce one local TX entry and the status should say **sent**, never executed or acknowledged.
