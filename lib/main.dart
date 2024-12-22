import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/utils/cart_provider.dart'; // Your CartProvider import
import 'package:myapp/utils/product_provider.dart';
import '/src/app.dart';
import '/src/settings/settings_controller.dart';
import '/src/settings/settings_service.dart';

void main() async {
  // Ensure WidgetsFlutterBinding is initialized before using async methods.
  WidgetsFlutterBinding.ensureInitialized();

  // Set up the SettingsController, which will be used to control the themeMode of the app.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred settings while the splash screen is displayed.
  await settingsController.loadSettings();

  // Run the app with the CartProvider in the provider context
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(), // Initialize CartProvider here
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(), // Initialize CartProvider here
        ),
      ],
      child: MyApp(
          settingsController:
              settingsController), // Pass SettingsController directly
    ),
  );
}
