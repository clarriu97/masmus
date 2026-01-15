import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/secondary_button.dart';

/// Pantalla de splash con opciones de registro perezoso
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundDark, AppColors.primaryGreenDark],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Logo
                Text(
                  'MASMUS',
                  style: AppTextStyles.display.copyWith(
                    fontSize: 48,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'El juego de cartas tradicional',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.accentGold,
                  ),
                ),

                const Spacer(),

                // Botones
                PrimaryButton(
                  text: 'Explorar como invitado',
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/main');
                  },
                  width: double.infinity,
                  icon: Icons.explore,
                ),

                const SizedBox(height: 16),

                SecondaryButton(
                  text: 'Iniciar sesión',
                  onPressed: () {
                    // TODO: Implementar login
                  },
                  width: double.infinity,
                  icon: Icons.login,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
