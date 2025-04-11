import 'package:flutter/material.dart';
import 'package:scroll_shadow_container/scroll_shadow_container.dart';
import 'package:tab_switcher/animated_grid.dart' as custom_grid;
import 'package:tab_switcher/tab_switcher_controller.dart';
import 'package:tab_switcher/tab_switcher_minimized_tab.dart';

/// Displays grid of minimized tabs
class TabSwitcherTabGrid extends StatefulWidget {
  const TabSwitcherTabGrid(this.controller, {Key? key}) : super(key: key);

  final TabSwitcherController controller;

  static const double kTabHeight = 256;

  @override
  State<TabSwitcherTabGrid> createState() => _TabSwitcherTabGridState();
}

class _TabSwitcherTabGridState extends State<TabSwitcherTabGrid> {
  @override
  Widget build(BuildContext context) {
    return ScrollShadowContainer(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Scrollbar(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: custom_grid.AnimatedGrid<TabSwitcherTab>(
              items: widget.controller.tabs.toList(),
              itemHeight: TabSwitcherTabGrid.kTabHeight,
              keyBuilder: (t) => t.key,
              builder: (context, tab, details) => TabSwitcherMinimizedTab(
                tab: tab,
                onTap: () => widget.controller.switchToTab(details.index),
                onClose: () => widget.controller.closeTab(widget.controller.tabs[details.index]),
                isCurrent: tab == widget.controller.currentTab,
              ),
              columns: 2,
              curve: Curves.ease,
              duration: const Duration(milliseconds: 175),
            ),
          ),
        ),
      ),
    );
  }
}
