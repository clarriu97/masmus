import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../game/cards.dart';
import '../game/count.dart';
import '../game/hand_value.dart';
import '../game/outcome.dart';
import 'buttons/primary_button.dart';

class RoundSummary extends StatelessWidget {
  const RoundSummary({
    required this.count,
    required this.names,
    required this.hands,
    required this.score,
    required this.onContinue,
    super.key,
    this.winner,
  });

  /// Null when a "no quiero" ended the match mid-hand.
  final HandCount? count;
  final List<String> names;
  final List<List<PlayingCard>> hands;
  final List<int> score;

  /// The team that won the match, if it is over.
  final int? winner;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(200),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accentGold),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  switch (winner) {
                    0 => '¡Ganáis la partida!',
                    1 => 'Ganan ellos',
                    _ => 'Resumen de la mano',
                  },
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.accentGold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                for (final lance in count?.lances ?? const <LanceCount>[])
                  _row(lance),
                const SizedBox(height: 16),
                Text(
                  'Nosotros ${score[0]} · Ellos ${score[1]}',
                  style: AppTextStyles.bodyBold,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: winner == null ? 'Siguiente mano' : 'Volver',
                  onPressed: onContinue,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(LanceCount lance) {
    final team = lance.team;
    final seat = lance.seat;
    final detail = team == null
        ? 'No se juega'
        : !lance.counted
        ? 'No se cuenta'
        : [
            '${team == 0 ? 'Nosotros' : 'Ellos'} +${lance.points + lance.paidAtOnce}',
            switch (lance.outcome) {
              EnPaso() => 'en paso',
              Querido(:final stake) => 'querido $stake',
              NoQuerido(:final points) => 'no quiero, $points al momento',
              SinDisputa() => 'sin disputa',
              OrdagoQuerido() => 'órdago',
              NotPlayed() => '',
            },
            if (seat != null)
              'con ${hands[seat].map((card) => card.code[0]).join('-')} '
                  'de ${names[seat]}',
          ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              switch (lance.outcome.lance) {
                Lance.grande => 'Grande',
                Lance.chica => 'Chica',
                Lance.pares => 'Pares',
                Lance.juego => 'Juego',
                Lance.punto => 'Punto',
              },
              style: AppTextStyles.bodyBold.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              detail,
              style: AppTextStyles.body.copyWith(
                color: team != null && lance.counted
                    ? Colors.white
                    : Colors.white38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
