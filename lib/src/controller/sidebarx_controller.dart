import 'dart:async';

import 'package:flutter/material.dart';

import '../models/sidebarx_item.dart';

class SidebarXController extends ChangeNotifier {
  SidebarXController({
    required int selectedIndex,
    bool? extended,
    this.onItemSelected,
  }) : _selectedIndex = selectedIndex {
    _setExtedned(extended ?? false);
  }

  /// Called whenever an item becomes selected (by tap or [selectIndex]),
  /// with the resolved [SidebarXItem] instead of a raw index.
  ///
  /// Not called when [selectIndex] is invoked with `notify: false`.
  void Function(SidebarXItem item)? onItemSelected;

  int _selectedIndex;
  var _extended = false;

  var _flatItems = <SidebarXItem>[];
  var _flatParents = <SidebarXItem?>[];

  final _extendedController = StreamController<bool>.broadcast();
  Stream<bool> get extendStream =>
      _extendedController.stream.asBroadcastStream();

  int get selectedIndex => _selectedIndex;

  /// Selects the item at flat index [val].
  ///
  /// If [val] points to an expandable-only header (an item with
  /// `isExpandableOnly: true` and non-empty `subItems`), the selection is
  /// forwarded to its first child, so [selectedIndex] never lands on a
  /// header that has no content of its own.
  ///
  /// Pass `notify: false` to update the index silently (e.g. when restoring
  /// state): listeners and [onItemSelected] are not called, so the change
  /// is picked up on the next rebuild without triggering navigation logic.
  void selectIndex(int val, {bool notify = true}) {
    final target = itemAt(val);
    if (target != null &&
        target.isExpandableOnly &&
        (target.subItems?.isNotEmpty ?? false)) {
      val = val + 1;
    }
    _selectedIndex = val;
    if (notify) {
      notifyListeners();
      final item = itemAt(val);
      if (item != null) {
        onItemSelected?.call(item);
      }
    }
  }

  /// Selects the item whose [SidebarXItem.id] equals [id].
  ///
  /// Returns `false` (and changes nothing) if no registered item has that id.
  bool selectById(String id, {bool notify = true}) {
    final index = indexOfId(id);
    if (index == -1) return false;
    selectIndex(index, notify: notify);
    return true;
  }

  /// Registers the items rendered by a `SidebarX` widget so index-based
  /// lookups ([itemAt], [indexOf], [parentOf]) resolve to real items.
  ///
  /// Called automatically by `SidebarX`; the order matches the widget's
  /// flat index space: each item followed by its sub-items (pre-order),
  /// main items first, then footer items.
  void registerItems(
    List<SidebarXItem> items, {
    List<SidebarXItem> footerItems = const [],
  }) {
    final flatItems = <SidebarXItem>[];
    final flatParents = <SidebarXItem?>[];
    void addAll(List<SidebarXItem> source) {
      for (final item in source) {
        flatItems.add(item);
        flatParents.add(null);
        for (final subItem in item.subItems ?? const <SidebarXItem>[]) {
          flatItems.add(subItem);
          flatParents.add(item);
        }
      }
    }

    addAll(items);
    addAll(footerItems);
    _flatItems = flatItems;
    _flatParents = flatParents;
  }

  /// The item at flat index [flatIndex], or `null` when out of range or
  /// before any `SidebarX` widget registered its items.
  SidebarXItem? itemAt(int flatIndex) {
    if (flatIndex < 0 || flatIndex >= _flatItems.length) return null;
    return _flatItems[flatIndex];
  }

  /// The flat index of [item], or `-1` if it is not registered.
  ///
  /// Matches by instance identity first, then by [SidebarXItem.id].
  int indexOf(SidebarXItem item) {
    for (var i = 0; i < _flatItems.length; i++) {
      if (identical(_flatItems[i], item)) return i;
    }
    if (item.id != null) return indexOfId(item.id!);
    return -1;
  }

  /// The flat index of the item with [SidebarXItem.id] equal to [id],
  /// or `-1` if there is none.
  int indexOfId(String id) {
    for (var i = 0; i < _flatItems.length; i++) {
      if (_flatItems[i].id == id) return i;
    }
    return -1;
  }

  /// The currently selected item, or `null` when [selectedIndex] is out of
  /// range or items are not registered yet.
  SidebarXItem? get selectedItem => itemAt(_selectedIndex);

  /// The parent (category header) of the currently selected item, or `null`
  /// when the selected item is top-level.
  SidebarXItem? get selectedParent {
    if (_selectedIndex < 0 || _selectedIndex >= _flatParents.length) {
      return null;
    }
    return _flatParents[_selectedIndex];
  }

  /// The parent (category header) of [item], or `null` when [item] is
  /// top-level or not registered.
  SidebarXItem? parentOf(SidebarXItem item) {
    final index = indexOf(item);
    if (index == -1) return null;
    return _flatParents[index];
  }

  bool get extended => _extended;
  void setExtended(bool extended) {
    _extended = extended;
    _extendedController.add(extended);
    notifyListeners();
  }

  void toggleExtended() {
    _extended = !_extended;
    _extendedController.add(_extended);
    notifyListeners();
  }

  void _setExtedned(bool val) {
    _extended = val;
    notifyListeners();
  }

  @override
  void dispose() {
    _extendedController.close();
    super.dispose();
  }
}
