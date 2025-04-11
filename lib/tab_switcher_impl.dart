import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tab_switcher/preview_capturer_widget.dart';
import 'package:tab_switcher/tab_switcher_app_bar.dart';
import 'package:tab_switcher/tab_switcher_controller.dart';
import 'package:tab_switcher/tab_switcher_tab_grid.dart';

typedef TabWidgetBuilder = Widget Function(BuildContext context, TabSwitcherTab? tab);

/// Root widget for building apps with full screen tabs
class TabSwitcherWidget extends StatefulWidget {
  TabSwitcherWidget({
    Key? key,
    required this.controller,
    required this.appBarBuilder,
    this.bodyBuilder,
    this.emptyScreenBuilder,
    this.switcherFooterBuilder,
    this.appBarHeight = 56,
    this.backgroundColor,
  }) : super(key: key) {
    _initializePageControllers();
  }

  void _initializePageControllers() {
    // فقط اگه هنوز مقداردهی نشده باشن، مقداردهی می‌کنیم
    _appBarPageController ??= PageController(initialPage: controller.currentTab?.index ?? 0);
    _bodyPageController ??= PageController(initialPage: controller.currentTab?.index ?? 0);

    _appBarPageController!.addListener(() {
      // syncing body PageView with header PageView
      if (_bodyPageController!.hasClients) {
        _bodyPageController!.position.correctPixels(_appBarPageController!.offset);
        _bodyPageController!.position.notifyListeners();
      }

      // syncing controller's current page after header swipe gesture
      if (_appBarPageController!.hasClients &&
          _appBarPageController!.page == _appBarPageController!.page!.floorToDouble() &&
          !_isNavigatingToPage) {
        final index = _appBarPageController!.page!.floor();
        if (controller.currentTab != null && controller.currentTab!.index != index) {
          controller.switchToTab(index);
        }
      }
    });
  }

  PageController? _appBarPageController;
  PageController? _bodyPageController;
  bool _isNavigatingToPage = false;

  final TabSwitcherController controller;
  final TabWidgetBuilder? appBarBuilder;
  final TabWidgetBuilder? bodyBuilder;
  final WidgetBuilder? emptyScreenBuilder;
  final WidgetBuilder? switcherFooterBuilder;
  final Color? backgroundColor;
  final double appBarHeight;

  @override
  State<TabSwitcherWidget> createState() => _TabSwitcherWidgetState();
}

class _TabSwitcherWidgetState extends State<TabSwitcherWidget> {
  late StreamSubscription<TabSwitcherTab> _sub1;
  late StreamSubscription<TabSwitcherTab> _sub2;
  late StreamSubscription<bool> _sub3;
  late StreamSubscription<TabSwitcherTab?> _sub4;

  @override
  void initState() {
    super.initState();
    _sub1 = widget.controller.onTabClosed.listen((e) => setState(() {}));
    _sub2 = widget.controller.onNewTab.listen((e) => setState(() {}));
    _sub3 = widget.controller.onSwitchModeChanged.listen((e) => setState(() {})); // اینجا دیگه initPageControllers رو صدا نمی‌زنیم
    _sub4 = widget.controller.onCurrentTabChanged.listen((e) => setState(() {
      if (!widget.controller.switcherActive &&
          widget.controller.currentTab != null &&
          widget._appBarPageController!.hasClients) {
        widget._isNavigatingToPage = true;
        widget._appBarPageController!.jumpToPage(widget.controller.currentTab!.index);
        widget._isNavigatingToPage = false;
      }
    }));
  }

  @override
  void dispose() {
    _sub1.cancel();
    _sub2.cancel();
    _sub3.cancel();
    _sub4.cancel();
    widget._appBarPageController?.dispose();
    widget._bodyPageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noTabs = widget.controller.tabCount == 0;
    final displaySwitcher = widget.controller.switcherActive;
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.scaffoldBackgroundColor;

    return ColoredBox(
      color: backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: TabSwitcherAppBar(
          widget.appBarBuilder,
          widget.controller,
          widget._appBarPageController!,
          MediaQuery.of(context),
          widget.appBarHeight.toInt(),
          backgroundColor,
        ),
        body: displaySwitcher
            ? Column(
          children: [
            Expanded(
              child: noTabs
                  ? widget.emptyScreenBuilder?.call(context) ??
                  Center(
                    child: Text(
                      'No open tabs',
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  )
                  : TabSwitcherTabGrid(widget.controller),
            ),
            if (widget.switcherFooterBuilder != null)
              widget.switcherFooterBuilder!(context),
          ],
        )
            : PageView.builder(
          controller: widget._bodyPageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.controller.tabCount,
          itemBuilder: (c, i) {
            final tab = widget.controller.tabs[i];
            return PreviewCapturerWidget(
              tag: tab.getTitle(),
              child: widget.bodyBuilder?.call(c, tab) ??
                  Column(
                    children: [
                      Expanded(
                        child: tab.getContent(),
                      ),
                    ],
                  ),
              callback: (image) {
                tab.previewImage = image;
                setState(() {});
              },
            );
          },
        ),
      ),
    );
  }
}
