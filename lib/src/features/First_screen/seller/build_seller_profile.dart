import 'package:flutter/material.dart';
import 'package:myapp/src/settings/settings_controller.dart';

class BuildSellerProfilePage extends StatefulWidget {
  final SettingsController settingsController;

  const BuildSellerProfilePage({super.key, required this.settingsController});

  @override
  _BuildSellerProfilePageState createState() => _BuildSellerProfilePageState();
}

class _BuildSellerProfilePageState extends State<BuildSellerProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedMenuIndex = 0; // Track selected menu item index

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.settingsController,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: widget.settingsController.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.black,
            colorScheme: ColorScheme.light(
              surface: Colors.grey[100]!,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.white,
            colorScheme: ColorScheme.dark(
              surface: Colors.grey[900]!,
            ),
          ),
          home: Scaffold(
            key: _scaffoldKey, // Using a global key to manage scaffold state
            appBar: AppBar(
              title: const Text('User Profile'),
              backgroundColor: Theme.of(context).primaryColor,
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            ),
            drawer: _buildSideNavigationBar(context),
            body: GestureDetector(
              onTap: () {
                // Close the drawer if it's open
                if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                  Navigator.of(context).pop();
                }
              },
              child: _buildContent(), // Display content based on selection
            ),
          ),
        );
      },
    );
  }

  Widget _buildSideNavigationBar(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context),
          _buildMenuItems(context),
          Divider(color: Theme.of(context).dividerColor),
          _buildProfileSection(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 24,
            child: Text(
              'U', // Initials or profile image placeholder
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'User Name',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                'user@example.com',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.shopping_bag_outlined),
          title: const Text('Orders'),
          onTap: () => _onMenuItemSelected(0),
          selected: _selectedMenuIndex == 0,
        ),
        ListTile(
          leading: const Icon(Icons.favorite_border),
          title: const Text('Wishlist'),
          onTap: () => _onMenuItemSelected(1),
          selected: _selectedMenuIndex == 1,
        ),
        ListTile(
          leading: const Icon(Icons.shopping_cart_outlined),
          title: const Text('Cart'),
          onTap: () => _onMenuItemSelected(2),
          selected: _selectedMenuIndex == 2,
        ),
        ListTile(
          leading: const Icon(Icons.notifications_outlined),
          title: const Text('Notifications'),
          onTap: () => _onMenuItemSelected(3),
          selected: _selectedMenuIndex == 3,
        ),
        ListTile(
          leading: const Icon(Icons.account_circle_outlined),
          title: const Text('Account Settings'),
          onTap: () => _onMenuItemSelected(4),
          selected: _selectedMenuIndex == 4,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Log Out'),
          onTap: () {
            // Add your logout logic here
          },
        ),
      ],
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.green,
                radius: 20,
                child: Text(
                  'U', // Initials or profile image placeholder
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    'user@example.com',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 12),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.7, // Profile completion percentage
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Complete your profile to access all features',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Updates the selected menu index and triggers a rebuild to show different content
  void _onMenuItemSelected(int index) {
    setState(() {
      _selectedMenuIndex = index;
    });
    //Navigator.pop(context); // Close the drawer after selecting
  }

  // Displays content based on the selected menu item
  Widget _buildContent() {
    switch (_selectedMenuIndex) {
      case 0:
        return const Center(
            child: Text('Your Orders', style: TextStyle(fontSize: 24)));
      case 1:
        return const Center(
            child: Text('Your Wishlist', style: TextStyle(fontSize: 24)));
      case 2:
        return const Center(child: Text('Your Cart', style: TextStyle(fontSize: 24)));
      case 3:
        return const Center(
            child: Text('Your Notifications', style: TextStyle(fontSize: 24)));
      case 4:
        return const Center(
            child: Text('Account Settings', style: TextStyle(fontSize: 24)));
      default:
        return const Center(
            child: Text('Welcome to Your Profile',
                style: TextStyle(fontSize: 24)));
    }
  }
}
