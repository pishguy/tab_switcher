import 'package:flutter/material.dart';
import 'package:tab_switcher/tab_switcher_controller.dart';

/// Reusable button which shows supplied [TabSwitcherController]'s tab count
/// and triggers tab switching if tapped. For use in AppBar.
class TabCountIcon extends StatelessWidget {
  const TabCountIcon({
    super.key,
    required this.controller,
  });

  final TabSwitcherController controller;

  @override
  Widget build(BuildContext context) {
    final iconColor = IconTheme.of(context).color ?? Colors.white;
    return InkResponse(
      highlightShape: BoxShape.circle,
      onTap: controller.toggleTabSwitcher,
      child: SizedBox(
        width: 48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: iconColor, width: 2),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.5),
                child: Center(
                  child: Opacity(
                    opacity: controller.tabCount == 0 ? 0 : 1,
                    child: Text(
                      controller.tabCount.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
