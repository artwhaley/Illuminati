# Ticket 02: RowReader Interface + DelimitedRowReader

## Goal
Create the abstract `RowReader` interface and `DelimitedRowReader` implementation that reads CSV/TSV/delimited files, auto-detects the delimiter, and returns structured row data.

## Depends on
Nothing. Can run in parallel with Ticket 03 if desired, but sequential is fine.

## Delegate to
**Sonnet** — non-trivial delimiter detection logic.

---

## Context to load
Read `papertek/lib/services/import/csv_import_parser.dart` in full.
Understand its file-reading approach, encoding handling, and blank-row skipping so the new implementation is consistent. The new files REPLACE this one (deletion happens in Ticket 07 — do not delete it yet).

---

## Create: `papertek/lib/services/import/row_reader.dart`

```dart
abstract class RowReader {
  Future<List<String>> readHeaders(String path);
  Future<List<Map<String, String>>> readRows(String path);
}
```

That's the entire file. No imports needed (dart:async is implicit).

---

## Create: `papertek/lib/services/import/delimited_row_reader.dart`

### Imports
```dart
import 'dart:io';
import 'row_reader.dart';
```

### Class structure
`class DelimitedRowReader implements RowReader`

### Delimiter detection: `String _detectDelimiter(String firstLine)`
1. Count occurrences of `\t`, `,`, `;`, `|` in `firstLine`.
2. If all counts are 0, throw `FormatException('Could not detect delimiter in file header')`.
3. Return the character with the highest count.
4. Tie-break order (highest priority first): `\t` > `,` > `;` > `|`.
   Implement tie-breaking by checking in that order: if tab count >= comma count and tab count >= semicolon count and tab count >= pipe count, return tab, etc.

### `Future<String> _readFileContent(String path)`
```dart
return File(path).readAsString(encoding: utf8);
```
Use `dart:convert` utf8. Catch any encoding error and rethrow as a descriptive FormatException.

### `List<String> _splitLines(String content)`
Split on `'\n'` after replacing all `'\r\n'` with `'\n'` and all lone `'\r'` with `'\n'`.
Return non-empty lines only (after trimming trailing whitespace from each line).

### `Future<List<String>> readHeaders(String path)`
1. Read file content.
2. Split into lines.
3. If no lines, throw FormatException.
4. Detect delimiter from line 0.
5. Split line 0 on delimiter.
6. Return list of trimmed strings.

### `Future<List<Map<String, String>>> readRows(String path)`
1. Read file content.
2. Split into lines.
3. If fewer than 2 lines, return empty list.
4. Detect delimiter from line 0.
5. Parse headers from line 0 (same as readHeaders).
6. For lines 1+:
   a. Split on delimiter.
   b. Zip with headers: for index i, map `headers[i]` → `cells[i]` (if cells has fewer entries than headers, use empty string for missing cells).
   c. Trim all cell values.
   d. If every cell value is empty or is exactly `'-'`, skip this row (it's a blank/placeholder row).
   e. Otherwise, add the Map to the result.
7. Return the list.

---

## Acceptance criteria

Run from `papertek/` directory. All must pass before proceeding to Ticket 03.

```bash
# 1. Both new files exist
test -f lib/services/import/row_reader.dart && echo "OK" || echo "MISSING"
test -f lib/services/import/delimited_row_reader.dart && echo "OK" || echo "MISSING"

# 2. No analysis errors
flutter analyze

# 3. Abstract class present
grep "abstract class RowReader" lib/services/import/row_reader.dart
# Expected: matches

# 4. Delimiter detection present
grep "_detectDelimiter" lib/services/import/delimited_row_reader.dart
# Expected: matches

# 5. Implements interface
grep "implements RowReader" lib/services/import/delimited_row_reader.dart
# Expected: matches

# 6. csv_import_parser.dart still exists (not deleted yet)
test -f lib/services/import/csv_import_parser.dart && echo "OK" || echo "MISSING"
# Expected: OK
```

---

## Subagent prompt

```
You are creating two new Dart files for a Flutter project.

Working directory: c:\Users\artwh\Downloads\Illuminati\papertek

First, read this existing file to understand the project's file-reading patterns:
  lib/services/import/csv_import_parser.dart

Then create these two new files. Do not modify any existing files.

---

FILE 1: lib/services/import/row_reader.dart

Content:
  abstract class RowReader {
    Future<List<String>> readHeaders(String path);
    Future<List<Map<String, String>>> readRows(String path);
  }

---

FILE 2: lib/services/import/delimited_row_reader.dart

Imports needed: dart:io, dart:convert, and the row_reader.dart file above (relative import).

Implement `class DelimitedRowReader implements RowReader` with:

1. Private method `String _detectDelimiter(String firstLine)`:
   - Count occurrences of tab (\t), comma (,), semicolon (;), pipe (|) in firstLine
   - Throw FormatException if all counts are zero
   - Return the highest-count character; break ties in this priority order: tab > comma > semicolon > pipe

2. Private method `Future<String> _readFileContent(String path)`:
   - Read file as UTF-8 string using dart:io File and dart:convert utf8 encoding

3. Private method `List<String> _splitLines(String content)`:
   - Normalize line endings: replace \r\n and lone \r with \n
   - Split on \n
   - Return only non-empty lines (trim trailing whitespace per line before checking)

4. `Future<List<String>> readHeaders(String path)`:
   - Read and split into lines
   - Detect delimiter from line 0
   - Split line 0 on delimiter, return trimmed strings

5. `Future<List<Map<String, String>>> readRows(String path)`:
   - Read and split into lines
   - If fewer than 2 lines, return []
   - Parse headers from line 0
   - For each line at index 1+:
     * Split on delimiter
     * Zip with headers (missing cells → empty string, extra cells → ignored)
     * Trim all values
     * Skip the row if every value is empty or exactly '-'
     * Otherwise add Map<String,String> to result
   - Return result list

After creating both files, run `flutter analyze` from the papertek/ directory and report the full output.
Only create the two specified files. Do not modify any existing files.
```
