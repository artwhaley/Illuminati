
1) Goal and Scope
Implement app-wide color theming with three user-selectable modes:

Dark (current visual style baseline)
Light
CT Mode (monochromatic UI + user-controlled warm/cool tint slider)
In scope
Color-only theming (no layout variants)
Persistent user preference for mode + CT value
Immediate app-wide application at runtime
Settings UI control for mode and CT slider
Out of scope
Typography/layout changes
Per-screen theme overrides (unless required for contrast bugfix)
Animated theme transitions
2) Current-State Facts (from repo)
Root app theme is hardcoded in papertek/lib/ui/app.dart via _buildTheme().
App currently uses one dark ThemeData.
Most UI reads colors from Theme.of(context) and colorScheme, so app-wide replacement is feasible.
shared_preferences is already available in project, so use that for persistence.
3) Architecture to Implement
Create a dedicated theme module and move all theme logic out of PaperTekApp.

New files to create
papertek/lib/theme/app_theme_mode.dart
papertek/lib/theme/theme_prefs.dart
papertek/lib/theme/theme_color_utils.dart
papertek/lib/theme/app_theme_factory.dart
papertek/lib/providers/theme_provider.dart
papertek/lib/ui/settings/theme_settings_section.dart (or wherever app settings controls live)
4) Data Contracts (exact)
4.1 Theme mode enum
In app_theme_mode.dart:

enum AppThemeMode { dark, light, ct }
Add helpers:

String toStorageValue(AppThemeMode mode) returns 'dark' | 'light' | 'ct'
AppThemeMode fromStorageValue(String? raw) defaults to dark if unknown/null
4.2 Theme settings model
Define immutable model (can be a class or record wrapper):

AppThemeMode mode
double ctKelvin (valid range: 3000.0 to 9000.0)
Rules:

Clamp to [3000, 9000]
Neutral point = 6500
Storage keys:

papertek.theme.mode.v1
papertek.theme.ct_kelvin.v1
Defaults:

mode: dark
ctKelvin: 6500
5) Persistence Layer
In theme_prefs.dart implement:

Future<ThemeSettings> loadThemeSettings()
Future<void> saveThemeSettings(ThemeSettings settings)
Behavior requirements:

If prefs missing/corrupt, return defaults.
Save both values together every time user changes either mode or slider.
Never throw to UI; catch and fallback.
6) Color Utility Rules (CT math)
In theme_color_utils.dart, implement deterministic CT color adjustment function(s).

6.1 Required function
Color applyColorTemperature(Color input, double kelvin)
6.2 Algorithm requirement
Use one of these approaches (pick one and stick to it):

Kelvin-to-RGB multipliers and multiply channel values, or
Interpolate between warm and cool tint matrices around 6500K.
6.3 Exact constraints
kelvin == 6500 returns original color (or <=1 RGB diff).
3000K visibly warmer; 9000K visibly cooler.
Preserve alpha exactly.
Clamp channel output to [0..255].
Do not reduce contrast below acceptable readability (if transformed on* role gets too close to its surface role, fallback to original on*).
Add helper:

ColorScheme applyTemperatureToScheme(ColorScheme scheme, double kelvin, {required bool preserveContrast})
7) Theme Factory (single source of truth)
In app_theme_factory.dart, create:

ThemeData buildDarkTheme()
ThemeData buildLightTheme()
ThemeData buildCtTheme(double kelvin)
7.1 Dark mode requirements
Preserve current app appearance as closely as possible from existing _buildTheme() in app.dart.
Keep existing amber accent behavior unless a specific contrast conflict appears.
7.2 Light mode requirements
Build from Material 3 light baseline (ThemeData.light(useMaterial3: true) or equivalent).
Keep same semantic accent identity as dark (amber family), adjusted for light readability.
Ensure all surface/onSurface roles are not inverted incorrectly.
7.3 CT mode requirements
Start from a monochromatic seed/base scheme:
Use neutral grays (low chroma) for primary/surface family.
Apply temperature shift to all relevant color roles using utility from Section 6.
Ensure monochrome intent remains (no random saturated accent colors).
7.4 Shared component rules
All three builders must apply consistent component theming for:

inputDecorationTheme
dividerTheme
any existing app-level component tweaks currently in _buildTheme()
8) Riverpod State Management
In providers/theme_provider.dart:

Create a notifier/provider pair that owns theme settings.

8.1 Required API
Future<void> initialize()
Future<void> setMode(AppThemeMode mode)
Future<void> setCtKelvin(double kelvin)
8.2 Derived providers
Create derived providers for:

active ThemeData (light theme)
active ThemeData (dark theme)
ThemeMode for MaterialApp
Mapping rule:

mode dark => ThemeMode.dark
mode light => ThemeMode.light
mode ct => choose one deterministic path:
Recommended: route through ThemeMode.dark and set darkTheme to CT theme, OR
use ThemeMode.light with CT in theme
Do not switch mapping dynamically based on slider.

8.3 Initialization requirement
Initialize settings before first frame where possible; otherwise render defaults then update once loaded (no crash, no null state).

9) Wire into App Root
Modify papertek/lib/ui/app.dart:

Remove local _buildTheme().
Read theme providers.
Set:
theme: <light ThemeData from provider>
darkTheme: <dark/ct ThemeData from provider>
themeMode: <ThemeMode from provider>
Keep existing home routing behavior (StartScreen vs MainShell) unchanged.

10) Settings UI Implementation
Add a “Theme” section to existing settings surface.

10.1 Controls (exact)
Segmented control or radio group:
Dark
Light
CT Mode
Slider visible only when mode == ct:
Label: Color Temperature
Range: 3000 to 9000
Step: 100
Show current numeric value (e.g. 6500K)
Optional helper labels at ends:
Left: Warmer
Right: Cooler
10.2 Interaction behavior
Mode selection applies immediately.
Slider updates apply immediately while dragging.
Persist on every change.
No app restart required.
11) Contrast and Accessibility Guardrails
Non-negotiable checks:

Text remains readable on surfaces in all three modes.
Buttons, chips, focused inputs remain distinguishable in CT extremes.
Status colors (error/success/warning) remain semantically recognizable.
If CT transform causes unreadable role pair, fallback for that role to original unshifted color.
12) Testing Plan (must implement)
12.1 Unit tests
Create tests for:

enum serialization/deserialization defaults
preference load fallback behavior
applyColorTemperature():
identity at 6500K
warm shift at 3000K
cool shift at 9000K
alpha preserved
channel clamping valid
12.2 Widget tests
App root respects mode changes:
dark mode applies dark colors
light mode applies light colors
ct mode applies shifted scheme
CT slider visibility toggles only in ct mode.
Theme persists across app rebuild/restart simulation.
12.3 Manual verification checklist
Start screen, main shell, spreadsheet, maintenance, work notes:
no unreadable text
no invisible borders/dividers
selected/focused states still visible
CT slider extremes visually obvious but not destructive.
Theme changes do not affect undo/redo/data behavior.
13) Incremental Delivery Sequence (for your other agent)
Add enum + prefs model + storage layer.
Add CT color utility + unit tests.
Add theme factory and replicate current dark style.
Add Riverpod notifier/providers and root MaterialApp wiring.
Add settings UI controls and persistence hookups.
Run tests and perform manual pass on all major tabs.
Fix contrast regressions discovered in CT extremes.
Final polish: labels/tooltips and edge-case fallback handling.
14) Definition of Done
Feature is done only when all are true:

User can choose Dark, Light, or CT Mode.
CT mode exposes working warm/cool slider and visibly tints app colors.
Preferences persist across app restarts.
No crashes or null theme states during startup.
Existing screens remain readable and functionally unchanged.
Unit/widget tests added and passing for theme logic and persistence.