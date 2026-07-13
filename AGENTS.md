# Project Working Rules

## Database compatibility

This project is being used for a full production test show with imported data. Before making any change that could affect database or show-file compatibility, stop and discuss the change intentionally with the user.

This gate includes schema or migration changes, table/column/index/constraint changes, serialization changes, import/export format changes, delete semantics, and changes to database lifecycle, opening, closing, backup, restore, autosave, or recovery behavior.

Before implementation, explain:

- why the compatibility-affecting change is needed;
- whether existing show files remain readable and writable;
- the migration, rollback, and data-loss risks;
- how compatibility and recovery will be tested.

Do not implement such a change until the user explicitly approves it after that discussion. Read-only investigation, diagnosis, tests against disposable data, and specification work are allowed without approval. When uncertain whether a change affects compatibility, treat it as compatibility-affecting and ask.

## Live Eos console safety

The Eos console may be controlling a live show. Never send GO, Back, Stop, cue fire,
Go To Cue, Record, Update, Record Only, Cue Only recording, palette, macro,
submaster, or other show-wide/programming commands during development or automated
testing unless the user explicitly authorizes that exact live test at that time.

During the current focus-remote build phase, live testing is limited to a single
channel explicitly designated by the user for that execution. That channel may be
raised to an agreed level, lowered, and released. Do not infer a safe channel from
old messages or cached values. If no channel is designated, use loopback/fake UDP
tests only and report the live test as deferred.

Cue-stack implementation and all live cue-stack exploration are deferred until the
user states that the show is no longer running and explicitly authorizes cue tests.
Merely having a console endpoint in cached settings is never authorization to send.
