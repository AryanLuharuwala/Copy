import 'package:flutter/material.dart';

import 'package:myapp/src/features/First_screen/loginscreen.dart';
import 'package:myapp/src/features/First_screen/seller/main_page.dart';
import 'package:myapp/src/features/learning/data_analytics.dart';
import 'package:myapp/src/features/user/Loading.dart';
import 'package:myapp/src/features/user/explorer.dart';
import 'package:myapp/src/features/user/user_screen.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);

                  case UserHomeScreen.routeName:
                    return UserHomeScreen(
                      settingsController: settingsController,
                    );

                  default:
                    return UserHomeScreen(
                      settingsController: settingsController,
                    );
                  // return UserHomeScreen(
                  //   settingsController: settingsController,
                  // );
                  // default:
                  //   return DataAnalyticsPage();
                  // return MainPage(
                  //     sellerId: <String, dynamic>{},
                  //     settingsController: settingsController);
                }
              },
            );
          },
        );
      },
    );
  }
}
