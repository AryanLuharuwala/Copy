import 'package:flutter/material.dart';
import 'package:myapp/src/settings/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  final SettingsController settingsController;

  const SettingsPage({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: Theme.of(context).primaryColor,
            actions: [
              IconButton(
                icon: Icon(
                  settingsController.themeMode == ThemeMode.dark
                      ? Icons.wb_sunny
                      : Icons.brightness_2,
                ),
                onPressed: () {
                  settingsController.updateThemeMode(
                    settingsController.themeMode == ThemeMode.dark
                        ? ThemeMode.light
                        : ThemeMode.dark,
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SwitchListTile(
                  title: Text(
                    'Dark Mode',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  value: settingsController.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    settingsController.updateThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
                const Divider(),
                // Additional settings can go here
              ],
            ),
          ),
        );
      },
    );
  }
}
