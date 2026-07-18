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
    this.collapsedSubmenuFlyout = true,
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

  /// When the sidebar is collapsed and this item has sub-items,
  /// tapping it opens a flyout menu anchored next to the icon
  /// instead of expanding inline.
  final bool collapsedSubmenuFlyout;

  @override
  State<SidebarXCell> createState() => _SidebarXCellState();
}

class _SidebarXCellState extends State<SidebarXCell> {
  late Animation<double> _animation;
  var _hovered = false;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _flyoutEntry;

  bool get _hasSubItems =>
      widget.item.subItems != null && widget.item.subItems!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _animation = CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(covariant SidebarXCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Close any open flyout when the sidebar switches between
    // extended <-> collapsed, or when the item changes.
    if (oldWidget.extended != widget.extended ||
        !identical(oldWidget.item, widget.item)) {
      _removeFlyout();
    }
  }

  @override
  void dispose() {
    _removeFlyout();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.extended && _hasSubItems && widget.collapsedSubmenuFlyout) {
      _toggleFlyout();
    }
    widget.onTap();
  }

  void _toggleFlyout() {
    if (_flyoutEntry != null) {
      _removeFlyout();
    } else {
      _showFlyout();
    }
  }

  void _removeFlyout() {
    _flyoutEntry?.remove();
    _flyoutEntry = null;
  }

  void _showFlyout() {
    final overlay = Overlay.of(context);
    final theme = widget.theme;

    _flyoutEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            // Tap anywhere outside to dismiss
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _removeFlyout,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              targetAnchor: Alignment.topRight,
              followerAnchor: Alignment.topLeft,
              offset: const Offset(8, -4),
              child: _SubmenuFlyout(
                item: widget.item,
                theme: theme,
                itemRealIndex: widget.itemRealIndex,
                selectedIndex: widget.selectedIndex,
                onSubItemTap: (subItem, index) {
                  _removeFlyout();
                  subItem.onTap?.call();
                  widget.onSubItemTap?.call(subItem, index);
                },
              ),
            ),
          ],
        );
      },
    );
    overlay.insert(_flyoutEntry!);
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
        onTap: _handleTap,
        onLongPress: widget.onLongPress,
        onSecondaryTap: widget.onSecondaryTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            CompositedTransformTarget(
              link: _layerLink,
              child: Container(
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
                              if (_hasSubItems && widget.extended)
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
            ),
            // Inline sub-menu: only rendered while the sidebar is
            // extended. In collapsed mode the flyout is used instead,
            // which prevents squeezed/broken sub-items from showing
            // up in the narrow rail.
            if (_hasSubItems)
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: (widget.isExpanded && widget.extended)
                    ? Padding(
                        padding: const EdgeInsets.only(left: 24.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: (theme.iconTheme?.color ??
                                        Theme.of(context)
                                            .dividerColor)
                                    .withAlpha(60),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            children: widget.item.subItems!
                                .asMap()
                                .entries
                                .map((entry) {
                              final subItem = entry.value;
                              final index = entry.key;
                              return Padding(
                                padding: const EdgeInsets.only(left: 8.0),
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
                                    widget.onSubItemTap
                                        ?.call(subItem, index);
                                  },
                                  onLongPress: subItem.onLongPress ?? () {},
                                  onSecondaryTap:
                                      subItem.onSecondaryTap ?? () {},
                                  animationController:
                                      widget.animationController,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
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

/// Flyout panel shown next to a collapsed sidebar item that has
/// sub-items, mimicking the "popover sub-menu" pattern used by
/// most collapsible sidebars.
class _SubmenuFlyout extends StatelessWidget {
  const _SubmenuFlyout({
    Key? key,
    required this.item,
    required this.theme,
    required this.onSubItemTap,
    this.itemRealIndex,
    this.selectedIndex,
  }) : super(key: key);

  final SidebarXItem item;
  final SidebarXTheme theme;
  final void Function(SidebarXItem, int) onSubItemTap;
  final int? itemRealIndex;
  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final flutterTheme = Theme.of(context);
    final backgroundColor =
        theme.decoration?.color ?? flutterTheme.colorScheme.surface;

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(minWidth: 160, maxWidth: 240),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: flutterTheme.dividerColor.withAlpha(102),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(31),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: item.subItems!.asMap().entries.map((entry) {
            final index = entry.key;
            final subItem = entry.value;
            final selected = itemRealIndex != null &&
                selectedIndex != null &&
                selectedIndex == (itemRealIndex! + index + 1);
            return _FlyoutItem(
              item: subItem,
              theme: theme,
              selected: selected,
              onTap: () => onSubItemTap(subItem, index),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FlyoutItem extends StatefulWidget {
  const _FlyoutItem({
    Key? key,
    required this.item,
    required this.theme,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  final SidebarXItem item;
  final SidebarXTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_FlyoutItem> createState() => _FlyoutItemState();
}

class _FlyoutItemState extends State<_FlyoutItem> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final textStyle = widget.selected
        ? theme.selectedTextStyle
        : _hovered
            ? theme.hoverTextStyle ?? theme.textStyle
            : theme.textStyle;
    final decoration = widget.selected
        ? (theme.selectedItemDecoration ??
            BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ))
        : BoxDecoration(
            color: _hovered ? theme.hoverColor : null,
            borderRadius: BorderRadius.circular(10),
          );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: decoration,
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Text(
            widget.item.label ?? '',
            style: textStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
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
