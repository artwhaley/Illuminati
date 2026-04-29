import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme_mode.dart';

class ThemeSettingsSection extends ConsumerWidget {
  const ThemeSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'APPEARANCE',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Mode Selector
        Row(
          children: [
            _ModeButton(
              label: 'Dark',
              isSelected: settings.mode == AppThemeMode.dark,
              onTap: () => notifier.setMode(AppThemeMode.dark),
            ),
            const SizedBox(width: 8),
            _ModeButton(
              label: 'Light',
              isSelected: settings.mode == AppThemeMode.light,
              onTap: () => notifier.setMode(AppThemeMode.light),
            ),
            const SizedBox(width: 8),
            _ModeButton(
              label: 'CT Mode',
              isSelected: settings.mode == AppThemeMode.ct,
              onTap: () => notifier.setMode(AppThemeMode.ct),
            ),
          ],
        ),

        if (settings.mode == AppThemeMode.ct) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Color Temperature',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '${settings.ctKelvin.round()}K',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Warmer',
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.orange.withValues(alpha: 0.7)),
              ),
              Expanded(
                child: Slider(
                  value: settings.ctKelvin,
                  min: 3000,
                  max: 9000,
                  divisions: 60, // 100K steps
                  onChanged: (v) => notifier.setCtKelvin(v),
                ),
              ),
              Text(
                'Cooler',
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.blue.withValues(alpha: 0.7)),
              ),
            ],
          ),
          Center(
            child: Text(
              'Tints the entire monochromatic UI based on theatrical gel temperature.',
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.outline;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: isSelected ? 2 : 1),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : null,
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
