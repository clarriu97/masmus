import 'package:flutter/material.dart';

import '../navigation/main_navigation.dart';
import '../screens/game/game_setup_screen.dart';
import '../screens/game/game_table_screen.dart';
import '../screens/splash/splash_screen.dart';

/// Router de la aplicación con rutas nombradas
class AppRouter {
  static const String splash = '/';
  static const String main = '/main';
  static const String gameSetup = '/game-setup';
  static const String gameTable = '/game-table';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case main:
        return MaterialPageRoute(builder: (_) => const MainNavigation());

      case gameSetup:
        return MaterialPageRoute(builder: (_) => const GameSetupScreen());

      case gameTable:
        return MaterialPageRoute(builder: (_) => const GameTableScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Ruta no encontrada: ${settings.name}')),
          ),
        );
    }
  }
}
