import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/show_provider.dart';
import '../../features/reports/report_template.dart';

// Margin widths as a fraction of total page width.
// PDF PageTheme has left: 52, right: 52 margins.
// Letter portrait:  612pt wide → 52/612 ≈ 8.5% each side
// Letter landscape: 792pt wide → 52/792 ≈ 6.6% each side
double _marginFraction(String orientation) =>
    orientation == 'landscape' ? 52.0 / 792.0 : 52.0 / 612.0;

class ColumnResizer extends ConsumerStatefulWidget {
  const ColumnResizer({super.key});

  @override
  ConsumerState<ColumnResizer> createState() => _ColumnResizerState();
}

class _ColumnResizerState extends ConsumerState<ColumnResizer> {
  int? _activeHandleIndex;

  @override
  Widget build(BuildContext context) {
    final template = ref.watch(activeReportTemplateProvider);
    final notifier = ref.read(activeReportTemplateProvider.notifier);
    final theme = Theme.of(context);

    if (template.columns.length < 2) return const SizedBox.shrink();

    final marginFrac = _marginFraction(template.orientation);
    final marginColor = theme.colorScheme.onSurface.withOpacity(0.06);
    final marginBorderColor = theme.colorScheme.onSurface.withOpacity(0.25);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final marginPx = totalWidth * marginFrac;
        // The printable zone is the center strip between the two margin zones.
        final printableWidth = totalWidth - 2 * marginPx;
        final columns = template.columns;

        // Handle positions are relative to the *start of the printable zone*.
        final handlePositions = <double>[];
        double currentOffset = marginPx;
        for (int i = 0; i < columns.length - 1; i++) {
          currentOffset += (columns[i].widthPercent / 100.0) * printableWidth;
          handlePositions.add(currentOffset);
        }

        return Container(
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Column segments (only in printable zone) ──────────────────
              Positioned(
                left: marginPx,
                top: 0,
                bottom: 0,
                width: printableWidth,
                child: Row(
                  children: [
                    for (int i = 0; i < columns.length; i++)
                      Expanded(
                        flex: (columns[i].widthPercent * 100).toInt(),
                        child: Container(
                          height: 36,
                          margin: const EdgeInsets.symmetric(horizontal: 0.5),
                          decoration: BoxDecoration(
                            color: i % 2 == 0
                                ? theme.colorScheme.primaryContainer.withOpacity(0.45)
                                : theme.colorScheme.secondaryContainer.withOpacity(0.45),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${columns[i].label}  ${columns[i].widthPercent.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Left margin zone ──────────────────────────────────────────
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: marginPx,
                child: _MarginZone(
                  color: marginColor,
                  borderColor: marginBorderColor,
                  labelSide: TextDirection.ltr, // label on right side
                ),
              ),

              // ── Right margin zone ─────────────────────────────────────────
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: marginPx,
                child: _MarginZone(
                  color: marginColor,
                  borderColor: marginBorderColor,
                  labelSide: TextDirection.rtl, // label on left side
                ),
              ),

              // ── Drag handles ──────────────────────────────────────────────
              for (int i = 0; i < handlePositions.length; i++)
                Positioned(
                  left: handlePositions[i] - 6,
                  top: 0,
                  bottom: 0,
                  child: _ResizerHandle(
                    index: i,
                    isActive: _activeHandleIndex == i,
                    onDragUpdate: (deltaPx) {
                      // Delta is in screen pixels; convert to % of printable width.
                      // Multiplied by 2.0 for increased drag sensitivity.
                      final deltaPct = (deltaPx / printableWidth) * 100.0 * 2.0;
                      final leftCol = columns[i];
                      final rightCol = columns[i + 1];

                      var newLeft = leftCol.widthPercent + deltaPct;
                      var newRight = rightCol.widthPercent - deltaPct;

                      const minPct = 3.0;
                      if (newLeft < minPct) {
                        newLeft = minPct;
                        newRight = leftCol.widthPercent + rightCol.widthPercent - minPct;
                      }
                      if (newRight < minPct) {
                        newRight = minPct;
                        newLeft = leftCol.widthPercent + rightCol.widthPercent - minPct;
                      }

                      notifier.resizeColumns(i, newLeft, newRight);
                    },
                    onDragStart: () => setState(() => _activeHandleIndex = i),
                    onDragEnd: () => setState(() => _activeHandleIndex = null),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// The greyed-out margin zone with a subtle "MARGIN" label and an inner border
/// to clearly delineate where the printable area starts/stops.
class _MarginZone extends StatelessWidget {
  const _MarginZone({
    required this.color,
    required this.borderColor,
    required this.labelSide,
  });

  final Color color;
  final Color borderColor;
  final TextDirection labelSide;

  @override
  Widget build(BuildContext context) {
    final isLeft = labelSide == TextDirection.ltr;
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border(
          // Draw the inner border (the one touching the printable area)
          right: isLeft
              ? BorderSide(color: borderColor, width: 1.5)
              : BorderSide.none,
          left: !isLeft
              ? BorderSide(color: borderColor, width: 1.5)
              : BorderSide.none,
        ),
      ),
      alignment: Alignment.center,
      child: RotatedBox(
        quarterTurns: isLeft ? 3 : 1,
        child: Text(
          'MARGIN',
          style: TextStyle(
            fontSize: 7,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
            color: borderColor,
          ),
        ),
      ),
    );
  }
}

class _ResizerHandle extends StatefulWidget {
  const _ResizerHandle({
    required this.index,
    required this.isActive,
    required this.onDragUpdate,
    required this.onDragStart,
    required this.onDragEnd,
  });

  final int index;
  final bool isActive;
  final Function(double) onDragUpdate;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;

  @override
  State<_ResizerHandle> createState() => _ResizerHandleState();
}

class _ResizerHandleState extends State<_ResizerHandle> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.isActive
        ? theme.colorScheme.inversePrimary
        : (_isHovering
            ? theme.colorScheme.primary
            : theme.colorScheme.primary.withOpacity(0.5));

    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => widget.onDragStart(),
        onHorizontalDragUpdate: (details) => widget.onDragUpdate(details.delta.dx),
        onHorizontalDragEnd: (_) => widget.onDragEnd(),
        child: Container(
          width: 12,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Vertical line
              Container(width: 2, color: color.withOpacity(0.3)),
              // Grab pill
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: (_isHovering || widget.isActive) ? 6 : 4,
                height: (_isHovering || widget.isActive) ? 14 : 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
