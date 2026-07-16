import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

class TestSidebarX extends StatelessWidget {
  const TestSidebarX({
    Key? key,
    required this.controller,
    required this.items,
    this.footerItems = const [],
    this.toggleButtonBuilder,
    this.animationDuration = const Duration(milliseconds: 300),
    this.onExpansionChanged,
    this.theme = const SidebarXTheme(),
    this.collapsedSubmenuFlyout = true,
  }) : super(key: key);

  final SidebarXController controller;
  final List<SidebarXItem> items;
  final List<SidebarXItem> footerItems;
  final SidebarXBuilder? toggleButtonBuilder;
  final Duration animationDuration;
  final void Function(SidebarXItem item, bool expanded)? onExpansionChanged;
  final SidebarXTheme theme;
  final bool collapsedSubmenuFlyout;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SidebarX test app',
      home: Scaffold(
        body: SidebarX(
          animationDuration: animationDuration,
          controller: controller,
          items: items,
          footerItems: footerItems,
          toggleButtonBuilder: toggleButtonBuilder,
          onExpansionChanged: onExpansionChanged,
          theme: theme,
          collapsedSubmenuFlyout: collapsedSubmenuFlyout,
        ),
      ),
    );
  }
}
