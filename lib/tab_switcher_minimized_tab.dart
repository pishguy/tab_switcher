import 'package:flutter/material.dart';
import 'package:tab_switcher/tab_switcher_controller.dart';
import 'package:tab_switcher/ui_image_widget.dart';

/// A widget representing single minimized tab.
/// Consists of title, subtitle, preview image and a close button.
/// Implements swipe to dismiss on it's own.
class TabSwitcherMinimizedTab extends StatelessWidget {
  const TabSwitcherMinimizedTab({
    Key? key,
    required this.tab,
    required this.onTap,
    required this.onClose,
    required this.isCurrent,
  }) : super(key: key);

  final TabSwitcherTab tab;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final title = tab.getTitle();
    final subtitle = tab.getSubtitle();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: ValueKey(tab.index),
      onDismissed: (direction) => onClose(),
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isCurrent ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(color: Colors.black12, spreadRadius: 1.5, blurRadius: 4),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 4, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          color: isCurrent ? colorScheme.onPrimary : colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onClose,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2, right: 2),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: isCurrent
                              ? colorScheme.onPrimary.withOpacity(0.5)
                              : colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isCurrent
                                ? colorScheme.onPrimary.withOpacity(0.5)
                                : colorScheme.onSurface.withOpacity(0.5),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: tab.previewImage == null
                        ? ColoredBox(
                      color: colorScheme.surface,
                      child: Center(
                        child: Text(
                          'No preview',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    )
                        : UiImageWidget(image: tab.previewImage!, fit: BoxFit.fitWidth),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
