import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidebarx/sidebarx.dart';

const _home = SidebarXItem(id: 'home', icon: Icons.home, label: 'Home');
const _stokAktif = SidebarXItem(
  id: 'stok-aktif',
  icon: Icons.inventory,
  label: 'Stok Aktif',
);
const _stokNonaktif = SidebarXItem(
  id: 'stok-nonaktif',
  icon: Icons.inventory_2,
  label: 'Stok Nonaktif',
);
const _refurbish = SidebarXItem(
  id: 'refurbish',
  icon: Icons.build,
  label: 'Refurbish',
  isExpandableOnly: true,
  subItems: [_stokAktif, _stokNonaktif],
);
const _settings = SidebarXItem(
  id: 'settings',
  icon: Icons.settings,
  label: 'Settings',
);
const _logout = SidebarXItem(id: 'logout', icon: Icons.logout, label: 'Logout');

SidebarXController _registeredController({int selectedIndex = 0}) {
  final controller = SidebarXController(selectedIndex: selectedIndex);
  controller.registerItems(
    const [_home, _refurbish, _settings],
    footerItems: const [_logout],
  );
  // Flat index space: 0 Home, 1 Refurbish, 2 Stok Aktif,
  // 3 Stok Nonaktif, 4 Settings, 5 Logout
  return controller;
}

void main() {
  group('SidebarXController', () {
    test('setExtended', () {
      final controller = SidebarXController(selectedIndex: 0);
      controller.setExtended(true);
      expect(controller.extended, true);
      controller.setExtended(false);
      expect(controller.extended, false);
    });

    test('toggleExtended', () {
      final controller = SidebarXController(selectedIndex: 0, extended: false);
      controller.toggleExtended();
      expect(controller.extended, true);
      controller.toggleExtended();
      expect(controller.extended, false);
    });

    test('selectIndex', () {
      final controller = SidebarXController(selectedIndex: 0);
      controller.selectIndex(1);
      expect(controller.selectedIndex, 1);
      controller.selectIndex(20);
      expect(controller.selectedIndex, 20);
    });

    test('extendStream', () {
      final controller = SidebarXController(selectedIndex: 0, extended: true);
      expectLater(controller.extendStream, emits(false));
      controller.toggleExtended();
    });

    test('itemAt follows the flat pre-order index space', () {
      final controller = _registeredController();
      expect(controller.itemAt(0), same(_home));
      expect(controller.itemAt(1), same(_refurbish));
      expect(controller.itemAt(2), same(_stokAktif));
      expect(controller.itemAt(3), same(_stokNonaktif));
      expect(controller.itemAt(4), same(_settings));
      expect(controller.itemAt(5), same(_logout));
      expect(controller.itemAt(6), isNull);
      expect(controller.itemAt(-1), isNull);
    });

    test('indexOf and indexOfId resolve identity', () {
      final controller = _registeredController();
      expect(controller.indexOf(_stokNonaktif), 3);
      expect(controller.indexOfId('logout'), 5);
      expect(controller.indexOfId('unknown'), -1);
      expect(
        controller.indexOf(
          const SidebarXItem(id: 'settings', icon: Icons.settings),
        ),
        4,
      );
    });

    test('selectedItem and selectById', () {
      final controller = _registeredController();
      expect(controller.selectedItem, same(_home));
      expect(controller.selectById('stok-aktif'), isTrue);
      expect(controller.selectedIndex, 2);
      expect(controller.selectedItem, same(_stokAktif));
      expect(controller.selectById('unknown'), isFalse);
      expect(controller.selectedIndex, 2);
    });

    test('parentOf and selectedParent expose hierarchy', () {
      final controller = _registeredController();
      expect(controller.parentOf(_stokAktif), same(_refurbish));
      expect(controller.parentOf(_home), isNull);
      expect(controller.selectedParent, isNull);
      controller.selectById('stok-nonaktif');
      expect(controller.selectedParent, same(_refurbish));
      controller.selectById('settings');
      expect(controller.selectedParent, isNull);
    });

    test('selectIndex forwards expandable-only headers to first child', () {
      final controller = _registeredController();
      controller.selectIndex(1);
      expect(controller.selectedIndex, 2);
      expect(controller.selectedItem, same(_stokAktif));
    });

    test('selectIndex with notify false skips listeners and callback', () {
      final controller = _registeredController();
      var listenerCalls = 0;
      SidebarXItem? selectedViaCallback;
      controller.addListener(() => listenerCalls++);
      controller.onItemSelected = (item) => selectedViaCallback = item;

      controller.selectIndex(4, notify: false);
      expect(controller.selectedIndex, 4);
      expect(listenerCalls, 0);
      expect(selectedViaCallback, isNull);

      controller.selectIndex(5);
      expect(listenerCalls, 1);
      expect(selectedViaCallback, same(_logout));
    });

    test('onItemSelected receives resolved item on selection', () {
      final selections = <SidebarXItem>[];
      final controller = SidebarXController(
        selectedIndex: 0,
        onItemSelected: selections.add,
      );
      controller.registerItems(const [_home, _refurbish, _settings]);

      controller.selectIndex(4);
      controller.selectIndex(1); // header, forwarded to first child
      expect(selections, [same(_settings), same(_stokAktif)]);
    });
  });
}
