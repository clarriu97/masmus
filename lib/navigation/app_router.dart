import 'package:flutter/material.dart';

import '../navigation/main_navigation.dart';
import '../screens/splash/splash_screen.dart';

/// Router de la aplicación con rutas nombradas
class AppRouter {
  static const String splash = '/';
  static const String main = '/main';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case main:
        return MaterialPageRoute(builder: (_) => const MainNavigation());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Ruta no encontrada: ${settings.name}')),
          ),
        );
    }
  }
}
