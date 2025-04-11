import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scroll_shadow_container/scroll_shadow_container.dart';
import 'package:tab_switcher/tab_switcher_controller.dart';
import 'package:tab_switcher/tab_switcher_minimized_tab.dart';

/// Displays list of minimized tabs
class TabSwitcherTabList extends StatefulWidget {
  const TabSwitcherTabList(this.controller, {super.key});

  final TabSwitcherController controller;

  static const double kTabHeight = 148;

  @override
  State<TabSwitcherTabList> createState() => _TabSwitcherTabListState();
}

class _TabSwitcherTabListState extends State<TabSwitcherTabList> {
  final GlobalKey<AnimatedListState> animatedListKey = GlobalKey<AnimatedListState>();
  late StreamSubscription<TabSwitcherTab> _addSub;
  late StreamSubscription<TabSwitcherTab> _closeSub;

  @override
  void initState() {
    super.initState();
    _addSub = widget.controller.onNewTab.listen((tab) {
      animatedListKey.currentState?.insertItem(tab.index, duration: const Duration(milliseconds: 1));
    });
    _closeSub = widget.controller.onTabClosed.listen((tab) {
      animatedListKey.currentState?.removeItem(
        tab.index,
            (context, animation) => SizeTransition(
          axis: Axis.vertical,
          sizeFactor: CurvedAnimation(parent: animation, curve: Curves.ease),
          child: const SizedBox(height: TabSwitcherTabList.kTabHeight),
        ),
        duration: const Duration(milliseconds: 150),
      );
    });
  }

  @override
  void dispose() {
    _addSub.cancel();
    _closeSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollShadowContainer(
      child: Scrollbar(
        child: AnimatedList(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          key: animatedListKey,
          itemBuilder: (context, i, animation) => SizeTransition(
            sizeFactor: animation,
            child: SlideTransition(
              position: animation.drive(Tween(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              )),
              child: SizedBox(
                height: TabSwitcherTabList.kTabHeight,
                child: TabSwitcherMinimizedTab(
                  widget.controller.tabs[i],
                      () => widget.controller.switchToTab(i),
                      () => widget.controller.closeTab(widget.controller.tabs[i]),
                  widget.controller.tabs[i] == widget.controller.currentTab,
                ),
              ),
            ),
          ),
          initialItemCount: widget.controller.tabCount,
        ),
      ),
    );
  }
}
