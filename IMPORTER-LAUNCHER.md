# Importer Rework — Launch Prompt

Copy everything between the dashes and paste it to a fresh Claude Sonnet session
opened in the c:\Users\artwh\Downloads\Illuminati directory.

---

You are executing a pre-planned, fully-specified implementation of the PaperTek importer rework.

**Working directory:** `c:\Users\artwh\Downloads\Illuminati`
**Flutter project root:** `papertek/`

**Start by reading:** `tickets/IMPORTER-ORCHESTRATOR.md`

That file contains your full role, file scope, ticket protocol, blocked protocol, and final report format. Follow it exactly.

**Critical rules:**
- Read IMPORTER-ORCHESTRATOR.md before touching any code
- Work through tickets 01→07 in order; do not skip or reorder
- Only touch the files listed in the orchestrator's permitted scope
- Run `flutter analyze` from `papertek/` after each ticket and verify zero errors before proceeding
- If `flutter analyze` still shows errors after one fix attempt, STOP and report to the user using the BLOCKED format from the orchestrator
- Do not wander into unrelated files or fix unrelated bugs
- Use TodoWrite to track ticket completion
- Spawn subagents as directed in each ticket; always run AC checks yourself after a subagent returns
- End with the completion report format specified in the orchestrator

**Begin now. Read IMPORTER-ORCHESTRATOR.md first.**

---
