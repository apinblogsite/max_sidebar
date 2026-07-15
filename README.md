<h1 align="center">
  Max Sidebar
</h1>

| Mobile | Desktop | Web |
| :------------: | :------------: | :------------: |
| ![Image](https://github.com/Frezyx/sidebarx/blob/main/example/repo/example_mobile_small.gif?raw=true) | ![Image](https://github.com/Frezyx/sidebarx/blob/main/example/repo/example.gif?raw=true) | ![Image](https://github.com/Frezyx/sidebarx/blob/main/example/repo/example_web.gif?raw=true) |

## Getting started
Follow these steps to use this package

### Add dependency

```yaml
dependencies:
  sidebarx:
    git:
      url: https://github.com/apinblogsite/max_sidebar.git
      ref: main
```

### Add import package

```dart
import 'package:sidebarx/sidebarx.dart';
```

## Easy to use
The package is designed with maximum adaptation to large screens.<br>
Therefore, adding a widget to your screen will be very simple.
```dart
    Scaffold(
      body: Row(
        children: [
          SidebarX(
            controller: SidebarXController(selectedIndex: 0),
            items: const [
              SidebarXItem(icon: Icons.home, label: 'Home'),
              SidebarXItem(icon: Icons.search, label: 'Search'),
            ],
          ),
          // Your app screen body
        ],
      ),
    )
```
## Use with small mobile screens
On small screens and mobile devices, you can use the ready-made Sidebar widget as your application's drawer for excellent UX.
<br>Otherwise, leave the code unchanged and get the same experience

```dart
    Scaffold(
      drawer: SidebarX(
        controller: SidebarXController(selectedIndex: 0, extended: true),
        items: const [
          SidebarXItem(icon: Icons.home, label: 'Home'),
          SidebarXItem(icon: Icons.search, label: 'Search'),
        ],
      ),
      body: const Center(child: Text('Your app body')),
    )
```

# API overview

## SidebarXItem

An entry in the sidebar. At least one of `icon`, `iconBuilder`, or the
deprecated `iconWidget` is required.

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `id` | `String?` | `null` | Stable identity for the item. Lets you map the selection to app-level data (screens, routes, analytics) without depending on flat indices. |
| `label` | `String?` | `null` | Text shown when the sidebar is extended. |
| `icon` | `IconData?` | `null` | Item icon. |
| `iconBuilder` | `Widget Function(bool selected, bool hovered)?` | `null` | Builds a custom icon that can react to selected/hovered state. |
| `onTap` | `Function()?` | `null` | Called when the item is tapped (once per tap). |
| `onLongPress` | `Function()?` | `null` | Called on long press. |
| `onSecondaryTap` | `Function()?` | `null` | Called on secondary (right-click) tap. |
| `selectable` | `bool` | `true` | If `false`, tapping runs `onTap` but does not change `selectedIndex`. |
| `subItems` | `List<SidebarXItem>?` | `null` | Nested items rendered under this item when it is expanded. |
| `isExpandableOnly` | `bool` | `true` | When the item has `subItems`: if `true`, tapping it only expands/collapses the sub-menu and the item itself is never selected. |

### Sub-menus (categories)

```dart
SidebarXItem(
  id: 'refurbish',
  icon: Icons.build,
  label: 'Refurbish',
  isExpandableOnly: true, // header only expands, never gets selected
  subItems: [
    SidebarXItem(id: 'stok-aktif', icon: Icons.inventory, label: 'Stok Aktif'),
    SidebarXItem(id: 'stok-nonaktif', icon: Icons.inventory_2, label: 'Stok Nonaktif'),
  ],
),
```

### The flat index space

`selectedIndex` addresses items in **pre-order**: each item is followed by its
sub-items, main `items` come first, then `footerItems`.

```
0  Home
1  Refurbish        (header)
2  ├─ Stok Aktif
3  └─ Stok Nonaktif
4  Settings
5  Logout           (footer item)
```

You normally don't need to compute these indices yourself — use the identity
API below (`itemAt`, `indexOfId`, `selectedItem`, …) instead.

## SidebarXController

Controls and observes the sidebar. It is a `ChangeNotifier`, so you can
`addListener` or rebuild with `AnimatedBuilder`.

```dart
final controller = SidebarXController(
  selectedIndex: 0,
  extended: true,
  onItemSelected: (item) => print('Selected: ${item.id}'),
);
```

### Selection

| Member | Description |
| --- | --- |
| `int selectedIndex` | Currently selected flat index. |
| `void selectIndex(int index, {bool notify = true})` | Selects the item at `index`. If `index` points to an expandable-only header with sub-items, the selection is forwarded to its **first child** — `selectedIndex` never lands on a header without content. With `notify: false` the index is updated silently: listeners and `onItemSelected` are not called (see below). |
| `bool selectById(String id, {bool notify = true})` | Selects the item whose `id` matches. Returns `false` (and changes nothing) when no item has that id. |
| `void Function(SidebarXItem item)? onItemSelected` | Called on every selection with the resolved item instead of a raw index. Settable via constructor or later. |

#### Silent select (state restore)

Use `notify: false` when restoring state programmatically (e.g. after an auth
level change) so your navigation listeners don't treat the restore as a user
navigation and wipe the page stack or breadcrumb:

```dart
controller.selectIndex(savedIndex, notify: false);
// or
controller.selectById('stok-aktif', notify: false);
```

The sidebar picks up the new selection on its next rebuild.

### Item identity & hierarchy

The `SidebarX` widget automatically registers its (flattened) items on the
controller, so these lookups are available after the first build:

| Member | Description |
| --- | --- |
| `SidebarXItem? itemAt(int flatIndex)` | Item at a flat index, or `null` when out of range. |
| `int indexOf(SidebarXItem item)` | Flat index of an item (matched by instance, then by `id`), or `-1`. |
| `int indexOfId(String id)` | Flat index of the item with the given `id`, or `-1`. |
| `SidebarXItem? get selectedItem` | The currently selected item. |
| `SidebarXItem? get selectedParent` | Parent (category header) of the selected item; `null` for top-level items. |
| `SidebarXItem? parentOf(SidebarXItem item)` | Parent of any item; `null` for top-level or unregistered items. |

This removes the need to duplicate the library's index math in your app:

```dart
final screens = <String, Widget>{
  'home': const HomeScreen(),
  'stok-aktif': const StokAktifScreen(),
};

controller.onItemSelected = (item) {
  final screen = screens[item.id];
  final parent = controller.parentOf(item); // null => top-level item
  // build your breadcrumb / navigate here
};
```

### Extended state

| Member | Description |
| --- | --- |
| `bool extended` | Whether the sidebar is extended (wide) or collapsed. |
| `void setExtended(bool value)` | Sets the extended state. |
| `void toggleExtended()` | Toggles the extended state. |
| `Stream<bool> extendStream` | Broadcast stream of extended-state changes. |

## SidebarX widget

| Parameter | Description |
| --- | --- |
| `controller` | `SidebarXController` — required. |
| `items` | Main items (each may carry `subItems`). |
| `footerItems` | Items pinned above the toggle button. |
| `theme` | `SidebarXTheme` for the collapsed state. |
| `extendedTheme` | `SidebarXTheme` for the extended state; merged with `theme`. |
| `headerBuilder` / `footerBuilder` | Custom header/footer widgets. |
| `headerDivider` / `footerDivider` | Dividers around the item list. |
| `separatorBuilder` | Separator between items. |
| `toggleButtonBuilder` | Custom collapse/extend button. |
| `showToggleButton` | Show the built-in toggle button (default `true`). |
| `collapseIcon` / `extendIcon` | Icons for the built-in toggle button. |
| `animationDuration` | Extend/collapse animation duration. |
| `onExpansionChanged` | `void Function(SidebarXItem item, bool expanded)?` — called when a category header is expanded or collapsed. Useful for analytics or persisting expansion state across sessions. |

```dart
SidebarX(
  controller: controller,
  items: items,
  footerItems: const [
    SidebarXItem(id: 'logout', icon: Icons.logout, label: 'Logout'),
  ],
  onExpansionChanged: (item, expanded) {
    debugPrint('${item.id} is now ${expanded ? 'expanded' : 'collapsed'}');
  },
)
```

## SidebarXTheme

All fields are optional; anything you don't set falls back to your app's
`Theme` via `ColorScheme` (`surface`, `onSurfaceVariant`, `primary`), so the
sidebar follows light/dark brightness changes automatically — no manual
rebuild needed when the theme switches.

| Field | Description |
| --- | --- |
| `width` / `height` | Sidebar size (`width` defaults to 70). |
| `padding` / `margin` | Outer spacing. |
| `decoration` | Sidebar background decoration. |
| `iconTheme` / `textStyle` | Unselected item styling. |
| `selectedIconTheme` / `selectedTextStyle` | Selected item styling. |
| `hoverIconTheme` / `hoverTextStyle` / `hoverColor` | Hover styling. |
| `itemDecoration` / `selectedItemDecoration` | Per-item decoration. |
| `itemMargin` / `itemPadding` / `itemTextPadding` | Per-item spacing (plus `selected*` variants). |

```dart
SidebarX(
  controller: controller,
  theme: const SidebarXTheme(width: 70),
  extendedTheme: const SidebarXTheme(width: 250),
  items: items,
)
```

