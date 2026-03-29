import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

class SidebarXCell extends StatefulWidget {
  const SidebarXCell({
    Key? key,
    required this.item,
    required this.extended,
    required this.selected,
    required this.theme,
    required this.onTap,
    required this.onLongPress,
    required this.onSecondaryTap,
    required this.animationController,
    this.isExpanded = false,
    this.onSubItemTap,
    this.itemRealIndex,
    this.selectedIndex,
  }) : super(key: key);

  final bool extended;
  final bool selected;
  final SidebarXItem item;
  final SidebarXTheme theme;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onSecondaryTap;
  final AnimationController animationController;
  final bool isExpanded;
  final void Function(SidebarXItem, int)? onSubItemTap;
  final int? itemRealIndex;
  final int? selectedIndex;

  @override
  State<SidebarXCell> createState() => _SidebarXCellState();
}

class _SidebarXCellState extends State<SidebarXCell> {
  late Animation<double> _animation;
  var _hovered = false;

  @override
  void initState() {
    super.initState();
    _animation = CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final iconTheme = widget.selected
        ? theme.selectedIconTheme
        : _hovered
            ? theme.hoverIconTheme ?? theme.selectedIconTheme
            : theme.iconTheme;
    final textStyle = widget.selected
        ? theme.selectedTextStyle
        : _hovered
            ? theme.hoverTextStyle
            : theme.textStyle;
    final decoration =
        (widget.selected ? theme.selectedItemDecoration : theme.itemDecoration);
    final margin =
        (widget.selected ? theme.selectedItemMargin : theme.itemMargin);
    final padding =
        (widget.selected ? theme.selectedItemPadding : theme.itemPadding);
    final textPadding =
        widget.selected ? theme.selectedItemTextPadding : theme.itemTextPadding;

    return MouseRegion(
      onEnter: (_) => _onEnteredCellZone(),
      onExit: (_) => _onExitCellZone(),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onSecondaryTap: widget.onSecondaryTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Container(
              decoration: decoration?.copyWith(
                color: _hovered && !widget.selected ? theme.hoverColor : null,
              ),
              padding: padding ?? const EdgeInsets.all(8),
              margin: margin ?? const EdgeInsets.all(4),
              child: Row(
                mainAxisAlignment: widget.extended
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, _) {
                      final value = ((1 - _animation.value) * 6).toInt();
                      if (value <= 0) {
                        return const SizedBox();
                      }
                      return Spacer(flex: value);
                    },
                  ),
                  if (widget.item.iconBuilder != null)
                    widget.item.iconBuilder!.call(widget.selected, _hovered)
                  else if (widget.item.icon != null)
                    _Icon(item: widget.item, iconTheme: iconTheme)
                  // ignore: deprecated_member_use_from_same_package
                  else if (widget.item.iconWidget != null)
                    // ignore: deprecated_member_use_from_same_package
                    widget.item.iconWidget!,
                  Flexible(
                    flex: 6,
                    child: FadeTransition(
                      opacity: _animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(-0.1, 0),
                          end: Offset.zero,
                        ).animate(_animation),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: textPadding ?? EdgeInsets.zero,
                                child: Text(
                                  widget.item.label ?? '',
                                  style: textStyle,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            if (widget.item.subItems != null &&
                                widget.item.subItems!.isNotEmpty &&
                                widget.extended)
                              AnimatedRotation(
                                turns: widget.isExpanded ? 0.25 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: iconTheme?.color,
                                  size: iconTheme?.size,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.item.subItems != null &&
                widget.item.subItems!.isNotEmpty)
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: widget.isExpanded
                    ? Column(
                        children:
                            widget.item.subItems!.asMap().entries.map((entry) {
                          final subItem = entry.value;
                          final index = entry.key;
                          return Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: SidebarXCell(
                              item: subItem,
                              extended: widget.extended,
                              selected: widget.itemRealIndex != null &&
                                      widget.selectedIndex != null
                                  ? widget.selectedIndex ==
                                      (widget.itemRealIndex! + index + 1)
                                  : false,
                              theme: theme,
                              onTap: () {
                                subItem.onTap?.call();
                                widget.onSubItemTap?.call(subItem, index);
                              },
                              onLongPress: subItem.onLongPress ?? () {},
                              onSecondaryTap: subItem.onSecondaryTap ?? () {},
                              animationController: widget.animationController,
                            ),
                          );
                        }).toList(),
                      )
                    : const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }

  void _onEnteredCellZone() {
    setState(() => _hovered = true);
  }

  void _onExitCellZone() {
    setState(() => _hovered = false);
  }
}

class _Icon extends StatelessWidget {
  const _Icon({
    Key? key,
    required this.item,
    required this.iconTheme,
  }) : super(key: key);

  final SidebarXItem item;
  final IconThemeData? iconTheme;

  @override
  Widget build(BuildContext context) {
    return Icon(
      item.icon,
      color: iconTheme?.color,
      size: iconTheme?.size,
    );
  }
}
