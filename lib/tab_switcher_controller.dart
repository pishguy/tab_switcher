import 'dart:async';
import 'dart:collection';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Main controller of the tab switcher.
/// Opens new tabs, closes tabs, switches tabs programmatically.
/// Provides streams for common events.
class TabSwitcherController {
  int get tabCount => _tabs.length;
  UnmodifiableListView<TabSwitcherTab> get tabs => UnmodifiableListView(_tabs);
  TabSwitcherTab? get currentTab => _currentTab;

  Stream<TabSwitcherTab> get onNewTab => _newTabSubject.stream;
  Stream<TabSwitcherTab> get onTabClosed => _tabClosedSubject.stream;
  Stream<TabSwitcherTab?> get onCurrentTabChanged => _currentTabChangedSubject.stream;
  Stream<bool> get onSwitchModeChanged => _switchModeSubject.stream;

  T? getTab<T extends TabSwitcherTab>() {
    for (var tab in _tabs) {
      if (tab is T) {
        return tab;
      }
    }
    return null;
  }

  void toggleTabSwitcher() => switcherActive = !switcherActive;

  bool get switcherActive => _switcherActive ??= _tabs.isEmpty;
  set switcherActive(bool value) {
    if (value == false && tabCount == 0) return;
    if (_switcherActive != value) {
      _switcherActive = value;
      _switchModeSubject.add(value);
    }
  }

  void pushTab(TabSwitcherTab tab, {int index = 0, bool foreground = true}) {
    _tabs.add(tab);
    tab._index = _tabs.length - 1;

    if (foreground) {
      _currentTab?.onSave(_currentTab!._state);
      _currentTab = tab;
      if (_switcherActive == true) {
        _switcherActive = false;
        _switchModeSubject.add(_switcherActive!);
      }
      _currentTabChangedSubject.add(_currentTab);
    }

    _newTabSubject.add(tab);
  }

  void closeTab(TabSwitcherTab tab) {
    _tabs.remove(tab);

    var i = 0;
    for (var t in _tabs) {
      t._index = i++;
    }

    if (_currentTab == tab) {
      if (_tabs.isNotEmpty) {
        _currentTab = _tabs.last;
      } else {
        _currentTab = null;
        if (_switcherActive == false) {
          _switcherActive = true;
          _switchModeSubject.add(_switcherActive!);
        }
      }
      _currentTabChangedSubject.add(_currentTab);
    }

    _tabClosedSubject.add(tab);
  }

  void switchToTab(int index) {
    if (index >= 0 && index < _tabs.length) {
      _currentTab?.onSave(_currentTab!._state);
      _currentTab = _tabs[index];
      _currentTabChangedSubject.add(_currentTab);
    }

    if (switcherActive) {
      switcherActive = false;
    }
  }

  TabSwitcherTab? _currentTab;
  final List<TabSwitcherTab> _tabs = [];
  bool? _switcherActive;

  final _newTabSubject = StreamController<TabSwitcherTab>.broadcast();
  final _tabClosedSubject = StreamController<TabSwitcherTab>.broadcast();
  final _currentTabChangedSubject = StreamController<TabSwitcherTab?>.broadcast();
  final _switchModeSubject = StreamController<bool>.broadcast();

  void dispose() {
    _newTabSubject.close();
    _tabClosedSubject.close();
    _currentTabChangedSubject.close();
    _switchModeSubject.close();
  }
}

abstract class TabSwitcherTab {
  int get index => _index;
  Key get key => _key;

  String getTitle();
  String? getSubtitle() => null;

  Widget build(TabState state);
  void onSave(TabState state);

  Widget getContent() => _content ??= build(_state);

  ui.Image? previewImage;

  Widget? _content;
  late int _index;
  final UniqueKey _key = UniqueKey();
  final TabState _state = TabState();
}

class TabState {
  void set(String id, dynamic content) => _items[id] = content;
  T get<T>(String id) => _items[id] as T;

  final Map<String, dynamic> _items = <String, dynamic>{};
}
