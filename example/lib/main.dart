import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

void main() {
  runApp(SidebarXExampleApp());
}

class SidebarXExampleApp extends StatelessWidget {
  SidebarXExampleApp({Key? key}) : super(key: key);

  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SidebarX Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        canvasColor: canvasColor,
        scaffoldBackgroundColor: scaffoldBackgroundColor,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: Colors.white,
            fontSize: 46,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      home: Builder(
        builder: (context) {
          final isSmallScreen = MediaQuery.of(context).size.width < 600;
          return Scaffold(
            key: _key,
            appBar: isSmallScreen
                ? AppBar(
                    backgroundColor: canvasColor,
                    title: Text(_getTitleByIndex(_controller.selectedIndex)),
                    leading: IconButton(
                      onPressed: () {
                        // if (!Platform.isAndroid && !Platform.isIOS) {
                        //   _controller.setExtended(true);
                        // }
                        _key.currentState?.openDrawer();
                      },
                      icon: const Icon(Icons.menu),
                    ),
                  )
                : null,
            drawer: ExampleSidebarX(controller: _controller),
            body: Row(
              children: [
                if (!isSmallScreen) ExampleSidebarX(controller: _controller),
                Expanded(
                  child: Center(
                    child: _ScreensExample(
                      controller: _controller,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ExampleSidebarX extends StatefulWidget {
  const ExampleSidebarX({
    Key? key,
    required SidebarXController controller,
  })  : _controller = controller,
        super(key: key);

  final SidebarXController _controller;

  @override
  State<ExampleSidebarX> createState() => _ExampleSidebarXState();
}

class _ExampleSidebarXState extends State<ExampleSidebarX> {
  String selectedLanguage = 'id';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final isMobile = mediaQuery.size.width < 768;
    final isMobileLandscape = isMobile && isLandscape;

    return SidebarX(
      controller: widget._controller,
      theme: _buildTheme(theme, isMobile),
      extendedTheme: _buildExtendedTheme(theme, isMobile),
      headerBuilder: (context, extended) => _SidebarHeader(
        extended: extended,
        isMobileLandscape: isMobileLandscape,
      ),
      footerBuilder: (context, extended) => _SidebarFooter(
        extended: extended,
        isMobileLandscape: isMobileLandscape,
        selectedLanguage: selectedLanguage,
        onLanguageChanged: (lang) {
          setState(() {
            selectedLanguage = lang;
          });
        },
      ),
      showToggleButton: !isMobile,
      collapseIcon: Icons.keyboard_double_arrow_left_rounded,
      extendIcon: Icons.keyboard_double_arrow_right_rounded,
      items: [
        SidebarXItem(
          icon: Icons.home,
          label: 'Home',
          onTap: () {
            debugPrint('Home');
          },
        ),
        const SidebarXItem(
          icon: Icons.search,
          label: 'Search',
        ),
        const SidebarXItem(
          icon: Icons.people,
          label: 'People',
        ),
        SidebarXItem(
          icon: Icons.favorite,
          label: 'Favorites',
          selectable: false,
          onTap: () => _showDisabledAlert(context),
        ),
        const SidebarXItem(
          iconWidget: FlutterLogo(size: 20),
          label: 'Flutter',
        ),
        SidebarXItem(
          icon: Icons.menu_book,
          label: 'More',
          subItems: [
            SidebarXItem(
              icon: Icons.abc,
              label: 'Sub Item 1',
              onTap: () {
                debugPrint('Sub Item 1');
              },
            ),
            SidebarXItem(
              icon: Icons.ac_unit,
              label: 'Sub Item 2',
              onTap: () {
                debugPrint('Sub Item 2');
              },
            ),
          ],
        ),
      ],
    );
  }

  SidebarXTheme _buildTheme(ThemeData theme, bool isMobile) {
    final colorScheme = theme.colorScheme;
    return SidebarXTheme(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      textStyle: TextStyle(
          color: colorScheme.onSurface.withOpacity(0.7), fontSize: 14),
      selectedTextStyle: TextStyle(
          color: colorScheme.primary,
          fontSize: 14,
          fontWeight: FontWeight.w600),
      itemTextPadding: const EdgeInsets.only(left: 10),
      selectedItemTextPadding: const EdgeInsets.only(left: 10),
      itemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.transparent),
      ),
      selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.primary.withOpacity(0.05)
            ],
          ),
          boxShadow: [
            BoxShadow(
                color: colorScheme.primary.withOpacity(0.1), blurRadius: 5)
          ]),
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 20),
      selectedIconTheme: IconThemeData(color: colorScheme.primary, size: 22),
      width: 75,
    );
  }

  SidebarXTheme _buildExtendedTheme(ThemeData theme, bool isMobile) {
    return _buildTheme(theme, isMobile).copyWith(
      width: 220,
      margin: const EdgeInsets.all(16),
    );
  }

  void _showDisabledAlert(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Item disabled for selecting',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final bool extended;
  final bool isMobileLandscape;

  const _SidebarHeader(
      {required this.extended, required this.isMobileLandscape});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final double height = isMobileLandscape ? 60 : 100;

    return SizedBox(
      height: height,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: extended ? 16.0 : 8.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment:
              extended ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.build_circle_outlined,
                  color: theme.onPrimary, size: 20),
            ),
            if (extended && !isMobileLandscape) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "TCL Toolbox",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.onSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "v1.0.0",
                      style: TextStyle(
                          fontSize: 10, color: theme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  final bool extended;
  final bool isMobileLandscape;
  final String selectedLanguage;
  final Function(String) onLanguageChanged;

  const _SidebarFooter({
    required this.extended,
    required this.isMobileLandscape,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.all(extended ? 16.0 : 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (extended && !isMobileLandscape) ...[
            _LanguageSelector(
              selectedLanguage: selectedLanguage,
              onLanguageChanged: onLanguageChanged,
            ),
            const SizedBox(height: 16),
          ],
          InkWell(
            onTap: () {}, // mock logout
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(extended ? 8 : 6),
              decoration: BoxDecoration(
                color: theme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: extended
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.primaryContainer,
                    child: Text(
                      "U",
                      style: TextStyle(
                          color: theme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                  if (extended) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "User",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: theme.onSurface),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Guest",
                            style: TextStyle(
                                fontSize: 10, color: theme.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.logout, size: 18, color: theme.error),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) onLanguageChanged;

  const _LanguageSelector({
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final isId = selectedLanguage == 'id';

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildOption(context, 'ID', isId, () => onLanguageChanged('id')),
          _buildOption(context, 'EN', !isId, () => onLanguageChanged('en')),
        ],
      ),
    );
  }

  Widget _buildOption(
      BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? theme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: theme.primary.withOpacity(0.3), blurRadius: 4)
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? theme.onPrimary : theme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScreensExample extends StatelessWidget {
  const _ScreensExample({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final pageTitle = _getTitleByIndex(controller.selectedIndex);
        switch (controller.selectedIndex) {
          case 0:
            return ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemBuilder: (context, index) => Container(
                height: 100,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).canvasColor,
                  boxShadow: const [BoxShadow()],
                ),
              ),
            );
          default:
            return Text(
              pageTitle,
              style: theme.textTheme.headlineSmall,
            );
        }
      },
    );
  }
}

String _getTitleByIndex(int index) {
  switch (index) {
    case 0:
      return 'Home';
    case 1:
      return 'Search';
    case 2:
      return 'People';
    case 3:
      return 'Favorites';
    case 4:
      return 'Custom iconWidget';
    case 5:
      return 'More';
    case 6:
      return 'Sub Item 1';
    case 7:
      return 'Sub Item 2';
    case 8:
      return 'Profile';
    case 9:
      return 'Settings';
    default:
      return 'Not found page';
  }
}

const primaryColor = Color(0xFF685BFF);
const canvasColor = Color(0xFF2E2E48);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: white.withOpacity(0.3), height: 1);
