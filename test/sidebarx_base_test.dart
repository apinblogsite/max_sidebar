import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidebarx/sidebarx.dart';

import 'test_sidebarx_widget.dart';

void main() {
  group('SidebarX', () {
    testWidgets('Default build test', (tester) async {
      await _pumpDedaultTextWidget(tester);
      final homeFinder = find.text('Home');
      final searchFinder = find.text('Search');

      expect(homeFinder, findsOneWidget);
      expect(searchFinder, findsOneWidget);
    });

    testWidgets('Select item', (tester) async {
      final controller = await _pumpDedaultTextWidget(tester);

      final searchFinder = find.text('Search');
      final homeFinder = find.text('Home');

      expect(homeFinder, findsOneWidget);
      expect(searchFinder, findsOneWidget);

      await tester.tap(searchFinder);
      await tester.pump();
      expect(controller.selectedIndex, 1);

      await tester.tap(homeFinder);
      await tester.pump();
      expect(controller.selectedIndex, 0);
    });

    testWidgets('Toggle button tap', (tester) async {
      final controller = SidebarXController(selectedIndex: 0, extended: false);
      await tester.pumpWidget(
        TestSidebarX(
          animationDuration: Duration.zero,
          controller: controller,
          items: const [
            SidebarXItem(icon: Icons.home, label: 'Home'),
            SidebarXItem(icon: Icons.search, label: 'Search'),
          ],
        ),
      );

      final toggleButtonFinder =
          find.byKey(const Key('sidebarx_toggle_button'));
      expect(toggleButtonFinder, findsOneWidget);

      await tester.tap(toggleButtonFinder);
      await tester.pump();
      expect(controller.extended, true);

      await tester.tap(toggleButtonFinder);
      await tester.pump();
      expect(controller.extended, false);
    });

    testWidgets('Registers items on controller automatically', (tester) async {
      final controller = SidebarXController(selectedIndex: 0);
      const subItem =
          SidebarXItem(id: 'sub', icon: Icons.list, label: 'Sub item');
      const header = SidebarXItem(
        id: 'header',
        icon: Icons.category,
        label: 'Category',
        isExpandableOnly: true,
        subItems: [subItem],
      );
      await tester.pumpWidget(
        TestSidebarX(
          animationDuration: Duration.zero,
          controller: controller,
          items: const [
            SidebarXItem(id: 'home', icon: Icons.home, label: 'Home'),
            header,
          ],
          footerItems: const [
            SidebarXItem(id: 'logout', icon: Icons.logout, label: 'Logout'),
          ],
        ),
      );

      expect(controller.itemAt(0)?.id, 'home');
      expect(controller.itemAt(1)?.id, 'header');
      expect(controller.itemAt(2)?.id, 'sub');
      expect(controller.itemAt(3)?.id, 'logout');
      expect(controller.parentOf(subItem), same(header));
    });

    testWidgets(
        'Expanding a category fires onExpansionChanged and '
        'sub-item tap selects and calls onTap once', (tester) async {
      var subTapCount = 0;
      final expansionEvents = <String>[];
      final controller = SidebarXController(selectedIndex: 0, extended: true);
      final subItem = SidebarXItem(
        id: 'sub',
        icon: Icons.list,
        label: 'Sub item',
        onTap: () => subTapCount++,
      );
      final header = SidebarXItem(
        id: 'header',
        icon: Icons.category,
        label: 'Category',
        isExpandableOnly: true,
        subItems: [subItem],
      );
      await tester.pumpWidget(
        TestSidebarX(
          animationDuration: Duration.zero,
          controller: controller,
          theme: const SidebarXTheme(width: 250),
          items: [
            const SidebarXItem(id: 'home', icon: Icons.home, label: 'Home'),
            header,
          ],
          onExpansionChanged: (item, expanded) =>
              expansionEvents.add('${item.id}:$expanded'),
        ),
      );

      await tester.tap(find.text('Category'));
      await tester.pumpAndSettle();
      expect(expansionEvents, ['header:true']);
      expect(controller.selectedIndex, 0);

      await tester.tap(find.text('Sub item'));
      await tester.pumpAndSettle();
      expect(subTapCount, 1);
      expect(controller.selectedIndex, 2);
      expect(controller.selectedItem?.id, 'sub');
      expect(controller.selectedParent, same(header));

      await tester.tap(find.text('Category'));
      await tester.pumpAndSettle();
      expect(expansionEvents, ['header:true', 'header:false']);
    });

    testWidgets(
        'Collapsed sidebar shows flyout submenu instead of force-extending',
        (tester) async {
      var subTapCount = 0;
      final controller = SidebarXController(selectedIndex: 0, extended: false);
      final subItem = SidebarXItem(
        id: 'sub',
        icon: Icons.list,
        label: 'Sub item',
        onTap: () => subTapCount++,
      );
      final header = SidebarXItem(
        id: 'header',
        icon: Icons.category,
        label: 'Category',
        isExpandableOnly: true,
        subItems: [subItem],
      );
      await tester.pumpWidget(
        TestSidebarX(
          animationDuration: Duration.zero,
          controller: controller,
          items: [
            const SidebarXItem(id: 'home', icon: Icons.home, label: 'Home'),
            header,
          ],
        ),
      );

      // The sub item is not visible before tapping the header.
      expect(find.text('Sub item'), findsNothing);

      await tester.tap(find.byIcon(Icons.category));
      await tester.pumpAndSettle();

      // Sidebar must remain collapsed, and the flyout must be visible.
      expect(controller.extended, false);
      expect(find.text('Sub item'), findsOneWidget);

      // Selecting a sub item from the flyout selects it and closes
      // the flyout.
      await tester.tap(find.text('Sub item'));
      await tester.pumpAndSettle();
      expect(subTapCount, 1);
      expect(controller.selectedIndex, 2);
      expect(controller.selectedItem?.id, 'sub');
      expect(find.text('Sub item'), findsNothing);
      expect(controller.extended, false);
    });

    testWidgets('Flyout closes when tapping outside', (tester) async {
      final controller = SidebarXController(selectedIndex: 0, extended: false);
      const subItem = SidebarXItem(id: 'sub', icon: Icons.list, label: 'Sub');
      const header = SidebarXItem(
        id: 'header',
        icon: Icons.category,
        label: 'Category',
        isExpandableOnly: true,
        subItems: [subItem],
      );
      await tester.pumpWidget(
        TestSidebarX(
          animationDuration: Duration.zero,
          controller: controller,
          items: const [
            SidebarXItem(id: 'home', icon: Icons.home, label: 'Home'),
            header,
          ],
        ),
      );

      await tester.tap(find.byIcon(Icons.category));
      await tester.pumpAndSettle();
      expect(find.text('Sub'), findsOneWidget);

      // Tap far away from the flyout to dismiss it.
      await tester.tapAt(const Offset(700, 500));
      await tester.pumpAndSettle();
      expect(find.text('Sub'), findsNothing);
      expect(controller.extended, false);
    });

    testWidgets(
        'collapsedSubmenuFlyout: false keeps legacy force-extend behavior',
        (tester) async {
      final controller = SidebarXController(selectedIndex: 0, extended: false);
      const subItem = SidebarXItem(id: 'sub', icon: Icons.list, label: 'Sub');
      const header = SidebarXItem(
        id: 'header',
        icon: Icons.category,
        label: 'Category',
        isExpandableOnly: true,
        subItems: [subItem],
      );
      await tester.pumpWidget(
        TestSidebarX(
          animationDuration: Duration.zero,
          controller: controller,
          collapsedSubmenuFlyout: false,
          items: const [
            SidebarXItem(id: 'home', icon: Icons.home, label: 'Home'),
            header,
          ],
        ),
      );

      await tester.tap(find.byIcon(Icons.category));
      await tester.pumpAndSettle();
      expect(controller.extended, true);
      expect(find.text('Sub'), findsOneWidget);
    });

    testWidgets(
        'Collapsed parent is highlighted when one of its sub items '
        'is selected', (tester) async {
      final controller = SidebarXController(selectedIndex: 2, extended: false);
      const subItem = SidebarXItem(id: 'sub', icon: Icons.list, label: 'Sub');
      const header = SidebarXItem(
        id: 'header',
        icon: Icons.category,
        label: 'Category',
        isExpandableOnly: true,
        subItems: [subItem],
      );
      const selectedColor = Color(0xFF123456);
      await tester.pumpWidget(
        TestSidebarX(
          animationDuration: Duration.zero,
          controller: controller,
          theme: const SidebarXTheme(
            selectedIconTheme: IconThemeData(color: selectedColor),
          ),
          items: const [
            SidebarXItem(id: 'home', icon: Icons.home, label: 'Home'),
            header,
          ],
        ),
      );
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.category));
      expect(icon.color, selectedColor);
    });
  });
}

Future<SidebarXController> _pumpDedaultTextWidget(WidgetTester tester) async {
  final controller = SidebarXController(selectedIndex: 0);
  await tester.pumpWidget(
    TestSidebarX(
      controller: controller,
      items: const [
        SidebarXItem(icon: Icons.home, label: 'Home'),
        SidebarXItem(icon: Icons.search, label: 'Search'),
      ],
    ),
  );
  return controller;
}
