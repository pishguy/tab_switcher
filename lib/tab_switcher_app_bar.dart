import 'package:flutter/material.dart';
import 'package:tab_switcher/tab_switcher_controller.dart';
import 'package:tab_switcher/utils/responsive_page_view_scroll_physics.dart';

typedef TabWidgetBuilder = Widget Function(BuildContext context, TabSwitcherTab? tab);

/// Wraps supplied app bar builder to add gesture support, animations and transitions
class TabSwitcherAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TabSwitcherAppBar(
      this.builder,
      this.controller,
      this.pageController,
      this.mediaQuery,
      this.appBarHeight,
      this.backgroundColor, {
        super.key,
      });

  final PageController pageController;
  final TabWidgetBuilder? builder;
  final MediaQueryData mediaQuery;
  final int appBarHeight;
  final TabSwitcherController controller;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (_) {
        if (!controller.switcherActive) {
          controller.switcherActive = true;
        }
      },
      child: SizedBox(
        height: mediaQuery.padding.top + appBarHeight,
        child: Stack(
          children: [
            builder!(context, null),
            IgnorePointer(
              ignoring: controller.switcherActive,
              child: AnimatedOpacity(
                opacity: controller.switcherActive ? 0 : 1,
                duration: const Duration(milliseconds: 125),
                child: controller.switcherActive
                    ? builder!(
                  context,
                  controller.currentTab != null ? controller.tabs[controller.currentTab!.index] : null,
                )
                    : ColoredBox(
                  color: backgroundColor,
                  child: PageView.builder(
                    controller: pageController,
                    physics: const ResponsiveBouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    itemCount: controller.tabCount,
                    itemBuilder: (c, i) => builder!(context, controller.tabs[i]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size(double.infinity, mediaQuery.padding.top + appBarHeight);
}
