## 0.19.1
* Fix toggle animation direction: the extend/collapse animation now follows the actual `extended` value instead of guessing from animation state, so rapid toggling via `setExtended`/`toggleExtended` can no longer desync the animation from the sidebar state
* Fix `extendStream` subscription leak: **SidebarX** now cancels its subscription on dispose and re-subscribes when the controller instance changes
* Flat index (`realIndex`) is now resolved through **SidebarXController.indexOf** instead of duplicated manual calculations in the widget, making `registerItems` the single source of truth for index math

## 0.19.0
* **Fix collapsed-mode sub-menu UX anomaly**: tapping an item with sub-items while the sidebar is collapsed no longer force-extends the sidebar
* **New: flyout sub-menu popup** — in collapsed (icon-only) mode, tapping a parent item opens a popup anchored next to the icon listing its sub-items (matching the common collapsible-sidebar pattern). Tap outside to dismiss; selecting a sub-item closes the flyout
* Inline sub-menus are no longer rendered while the sidebar is collapsed, fixing squeezed/broken sub-items in the narrow rail when a category was left expanded before collapsing
* Parent items are now highlighted in collapsed mode when one of their sub-items is selected, so the active section stays visible in icon-only mode
* Add **collapsedSubmenuFlyout** flag on **SidebarX** (default `true`); set to `false` to restore the legacy force-extend behavior

## 0.18.0
* Add **id** field for **SidebarXItem** to give items a stable identity
* Add item lookup API on **SidebarXController**: **itemAt**, **indexOf**, **indexOfId**, **selectedItem** — apps no longer need to duplicate the flat (pre-order) index calculation
* Add hierarchy API on **SidebarXController**: **parentOf** and **selectedParent** to distinguish top-level items from sub-items under a category header
* Add **onItemSelected** callback on **SidebarXController** that receives the resolved **SidebarXItem** on every selection
* Add **selectById** method on **SidebarXController**
* Add `notify` parameter to **selectIndex** (`selectIndex(index, notify: false)`) for silent state restore without triggering listeners or **onItemSelected**
* **selectIndex** on an expandable-only header (`isExpandableOnly: true` with sub-items) is now forwarded to its first child, so the selection never lands on a header without content
* Add **onExpansionChanged** callback on **SidebarX** fired when a category header is expanded or collapsed
* **SidebarXTheme.mergeFlutterTheme** now derives default colors from `ColorScheme` (`surface`, `onSurfaceVariant`, `primary`), so the sidebar follows light/dark theme changes consistently
* Fix sub-item **onTap** being invoked twice per tap

## 0.17.2
* Fix **SidebarXTheme** hoverIconTheme field merging in **mergeFlutterTheme** method

## 0.17.1
* Add deprecated annotation for **iconWidget** field
* Fix **SidebarXItem** assert rules

## 0.17.0
* Add **selectable** field for **SidebarXItem**
* Add **hoverIconTheme** field for **SidebarXTheme**
* Add **iconBuilder** field for **SidebarXItem**

## 0.16.3
* Add onLongPress, onSecondaryTap for SidebarXCell (SidebarX item)

Thanks to [MaurizioSodano](https://github.com/MaurizioSodano)

## 0.16.2
- Update packages and add repository in pubspec.yaml

## 0.16.1
- Add topics in pubspec.yaml

## 0.16.0
* **FIX** Add **hoverTextStyle** property

Thanks to [MaurizioSodano](https://github.com/MaurizioSodano)

## 0.15.0
* **FIX** clicking on a blank area does not respond

Thanks to [bai-3](https://github.com/bai-3)

## 0.14.0
* **FIX** sidebar menu items not occupying the whole height available

## 0.13.0
* **FEAT** Impement footerItems field
This provides adding footer items to the sidebar that are listed just above the expand icon

Thanks to [DavidCatalano](https://github.com/DavidCatalano)

## 0.12.0
* **FIX** Bug on items position
When a user open and closes the collapsed menu quickly, the position of the items menu becomes wrong in las version

 Thanks to [MonsterOfCode](https://github.com/MonsterOfCode)

## 0.11.0
* **FIX**: AnimationController disposing completed fix

## 0.10.0
* **FIX**: Implement AnimationController disposing

 Thanks to [xnxaxo](https://github.com/xnxaxo)

## 0.9.0
* **FEAT**: Implement SystemMouseCursors.click for Cell widget
* **FEAT**: Implement hoverColor field for Cell widget

## 0.8.0
* **FEAT**: Implement collapseIcon and extendIcon fields for simple toogle icon customization

 Thanks to [HaveANiceDay33](https://github.com/HaveANiceDay33)

## 0.7.0
* **FEAT**: Implement setExtended method to controller
* **INFO**: Implement tests for controller and SidebarX base widget

## 0.6.0
* **FIX**: Make animationDuration property Duration type
* **INFO**: Add simple documentation

## 0.5.0
* - **FEAT**: Add animation duration property to constructor

 Thanks to [hulohot](https://github.com/hulohot)

## 0.4.0
* - **FEAT** Implement Widget iconWidget field for custom icons in SidebarXItem

## 0.3.0
* - **FEAT** Implement padding and margin for item and selected item in SidebarXTheme
* - **INFO** Update flutter_lints to ^2.0.1
* - **INFO**: Update example packages

 Thanks to [rainbowloop](https://github.com/rainbowloop) from [LEANNOVA](https://github.com/LEANNOVA)

## 0.2.2
* - **FIX**: Fix the mergeFlutterTheme function that wasn't using the selectedIconTheme but the iconTheme

 Thanks to [nank1ro](https://github.com/nank1ro)

## 0.2.1
* - **INFO**: Update docs in README

## 0.2.0
* - **FEAT**: Edit theme configuration
* - **FEAT**: Made it possible to use with mobile devices
* - **INFO**: Add README package information and examples

## 0.1.0
* - **FEAT**: Add SidebarXTheme to make widget UI in extend and common mode
* - **FEAT**: Add builder for footer and header
* - **FEAT**: Add separatorBuilder, toggleButtonBuilder, showToggleButton, toggleButtonLabel, headerDivider, footerDivider fields

## 0.0.1

* - **FEAT**: Add initial sidebar UI
