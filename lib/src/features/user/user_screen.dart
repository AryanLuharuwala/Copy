import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/features/user/explorer.dart';
import 'package:myapp/src/features/user/widget/cart_popup.dart';
import 'package:myapp/src/features/user/widget/settings_page.dart';
import 'package:myapp/src/features/user/build_profile_page.dart';
import 'package:myapp/src/settings/settings_controller.dart';
import 'package:myapp/utils/product_provider.dart';

class UserHomeScreen extends StatefulWidget {
  final SettingsController settingsController;
  static const routeName = 'userscreen';

  const UserHomeScreen({super.key, required this.settingsController});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0;
  bool _isCartOverlayVisible = false;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    // Initialize pages only once
    _pages.addAll([
      const ExplorerPage(),
      BuildProfilePage(settingsController: widget.settingsController),
      SettingsPage(settingsController: widget.settingsController),
    ]);

    // Fetch products once when the app starts
    Provider.of<ProductProvider>(context, listen: false).fetchProducts(1);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleCartOverlay() {
    setState(() {
      _isCartOverlayVisible = !_isCartOverlayVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = widget.settingsController.themeMode == ThemeMode.dark;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        backgroundColor: isDarkTheme ? Colors.black : Colors.grey[200],
        appBar: AppBar(
          backgroundColor: isDarkTheme ? Colors.black : Colors.grey[100],
          title: const Text(
            'SURDS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
            if (_isCartOverlayVisible)
              CartPopupOverlay(
                onClose: _toggleCartOverlay,
              ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _toggleCartOverlay,
          backgroundColor: isDarkTheme ? Colors.orange : Colors.blue,
          child: const Icon(Icons.shopping_cart),
        ),
      ),
    );
  }
}
