import 'package:flutter/material.dart';
import 'package:myapp/src/features/First_screen/seller/add_product.dart';
import 'package:myapp/src/features/First_screen/seller/build_seller_profile.dart';
import 'package:myapp/src/features/First_screen/seller/stats.dart';
import 'package:myapp/src/settings/settings_controller.dart';
import 'seller_home_page.dart';

class MainPage extends StatefulWidget {
  final Map<String, dynamic> sellerId;
  final SettingsController settingsController;

  const MainPage({
    super.key,
    required this.sellerId,
    required this.settingsController,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    // List of pages with unique PageStorageKeys
    final List<Widget> pages = [
      SellerHomePage(
        sellerId: widget.sellerId,
        key: const PageStorageKey('SellerHomePage'),
      ),
      StatisticsPage(
        sellerId: widget.sellerId,
        key: const PageStorageKey('StatisticsPage'),
      ),
      BuildSellerProfilePage(
        settingsController: widget.settingsController,
        key: const PageStorageKey('BuildSellerProfilePage'),
      ),
      const AddProductPage(
        key: PageStorageKey('AddProductPage'),
      ),
    ];

    return AnimatedBuilder(
      animation: widget.settingsController,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: widget.settingsController.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.blue,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.blueGrey,
          ),
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Seller Home Page'),
              backgroundColor: Theme.of(context).primaryColor,
              actions: [
                IconButton(
                  icon: Icon(
                    widget.settingsController.themeMode == ThemeMode.dark
                        ? Icons.wb_sunny
                        : Icons.brightness_2,
                  ),
                  onPressed: () {
                    widget.settingsController.updateThemeMode(
                      widget.settingsController.themeMode == ThemeMode.dark
                          ? ThemeMode.light
                          : ThemeMode.dark,
                    );
                  },
                ),
              ],
            ),
            body: PageStorage(
              bucket: _bucket,
              child: pages[_selectedIndex],
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.show_chart),
                  label: 'Statistics',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.plus_one),
                  label: 'Add Product',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        );
      },
    );
  }
}
