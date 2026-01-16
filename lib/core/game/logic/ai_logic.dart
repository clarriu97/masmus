import 'dart:math';

import '../models/ai_profile.dart';
import '../models/card.dart';
import '../models/game_config.dart';
import '../models/player.dart';
import 'hand_evaluator.dart';
import 'mus_game.dart';

class AiLogic {
  static final Random _random = Random();

  /// Decide si quiere mus.
  /// Estrategia básica: si tiene buena mano (Juego o pares altos) corta.
  /// Si es mano (dealer) tiende a cortar más si tiene juego mínimamente decente.
  static bool shouldAcceptMus(
    Player player,
    HandEvaluationResult ev, {
    bool isDealer = false,
  }) {
    if (player.aiProfile == null) {
      return true; // Fallback
    }

    final bool hasJuego = ev.hasJuego;
    final int points = ev.pointSum;
    final ParesType pares = ev.paresType;

    // Si tiene 31 real o juego muy bueno (31, 32), corta seguro casi siempre
    if (points == 31 || points == 32) {
      // 95% corta, 5% deja mus por despiste/estrategia rara
      return _random.nextDouble() > 0.05;
    }

    // Si tiene buen juego (40)
    if (points == 40) {
      return _random.nextDouble() > 0.1;
    }

    // Si tiene duples de reyes/caballos, corta
    if (pares == ParesType.duples && ev.sortedRanks.first >= 11) {
      return true;
    }

    // Si es mano y tiene juego, corta con alta probabilidad
    if (isDealer && hasJuego) {
      return _random.nextDouble() > 0.2;
    }

    // En general, si la mano es mala, quiere mus
    return false;
  }

  /// Decide qué cartas descartar.
  /// Estrategia simple: Quedarse con Reyes, Ases (para pares de ases), y cartas de juego si se está cerca.
  /// O intentar ir a por juego si se tiene > 20 puntos.
  static List<MusCard> getCardsToDiscard(
    Player player,
    HandEvaluationResult ev,
  ) {
    final List<MusCard> hand = player.hand;
    final Set<int> keepIndices = <int>{};

    // Estrategia: "A la caza"
    // Mantener Reyes (12) y Ases (1) (en ranks 1 -> 1, 3->12 si 8 reyes)
    // Asumimos configuración estándar para simplificación de logica aquí,
    // pero HandEvaluator ya nos da "Effective Rank".

    // 1. Conservar Reyes/Treses (Rank >= 10)
    for (int i = 0; i < hand.length; i++) {
      // Obtenemos el rank efectivo re-calculandolo o asumiendo config.
      // Lo ideal sería que HandEvaluator devolviera los ranks mapeados a las cartas,
      // pero ev.sortedRanks pierde la referencia a la carta original.
      // Calculamos de nuevo para linkear.
      final int rank = HandEvaluator.getEffectiveRank(
        hand[i],
        const GameConfig(),
      ); // TODO: Pass config
      if (rank >= 10 || rank == 1) {
        // Reyes o Ases
        keepIndices.add(i);
      }
    }

    // Si tenemos una pareja hecha que no sean reyes/ases, ¿la guardamos?
    // Si boldness es bajo, conservamos pares.
    if (ev.paresType != ParesType.none &&
        (player.aiProfile?.boldness ?? 0.5) < 0.6) {
      // Identificar cartas del par
      final Map<int, List<int>> counts = <int, List<int>>{};
      for (int i = 0; i < hand.length; i++) {
        final int r = HandEvaluator.getEffectiveRank(
          hand[i],
          const GameConfig(),
        );
        counts.putIfAbsent(r, () => []).add(i);
      }
      for (final entry in counts.entries) {
        if (entry.value.length >= 2) {
          keepIndices.addAll(entry.value);
        }
      }
    }

    // Lista de retorno
    final List<MusCard> toDiscard = <MusCard>[];
    for (int i = 0; i < hand.length; i++) {
      if (!keepIndices.contains(i)) {
        toDiscard.add(hand[i]);
      }
    }

    // Si decidimos quedarnos con todo (raro si pedimos mus, pero posible),
    // descartar la más baja que no sea As o al azar 1.
    if (toDiscard.isEmpty && hand.isNotEmpty) {
      toDiscard.add(hand.last); // Simplificado
    }

    // Si descartamos todo, es todo
    if (toDiscard.isEmpty && keepIndices.isEmpty) {
      // Should not happen with logic above
      return List.from(hand);
    }

    return toDiscard;
  }

  /// Decide acción de apuesta: Pase, Quiero, Envido, Órdago
  /// phase: Fase actual
  /// currentBet: Cuánto hay que igualar (0 si es abrir)
  /// isLast: Si somos el postre (última palabra)
  static BettingDecision makeBettingDecision({
    required Player player,
    required HandEvaluationResult ev,
    required GamePhase phase,
    required int currentBet, // 0 = nadie ha abierto
    required bool isPartnerWinning, // Si mi compa ya va ganando (llevamos mano)
  }) {
    if (player.aiProfile == null) {
      return BettingDecision.pass;
    }

    final AiProfile profile = player.aiProfile!;
    final double score = _calculateHandStrength(ev, phase);

    // Factor de "Boldness" y "Bluff"
    // Random factor
    final double luck = _random.nextDouble();

    // Fuerza percibida = Fuerza real + (FactorFarol si toca)
    double perceivedStrength = score;

    // Si decide farolear (Bluff)
    if (luck < profile.bluffing && score < 0.4) {
      // Farol: Aumentamos artificialmente la fuerza percibida
      perceivedStrength += 0.5;
    }

    // Decision Logic
    if (currentBet == 0) {
      // ABRIR O PASAR
      if (perceivedStrength > 0.7) {
        // Mano fuerte -> Envido
        return const BettingDecision(type: BettingType.envido, amount: 2);
      } else if (perceivedStrength > 0.9 && profile.boldness > 0.8) {
        return const BettingDecision(type: BettingType.ordago);
      }
      return BettingDecision.pass;
    } else {
      // RESPONDER A APUESTA
      // Umbrales para querer
      double threshold = 0.6; // Base para querer 2 piedras
      if (currentBet > 5) {
        threshold = 0.8;
      } // Para envites grandes
      if (currentBet > 20) {
        threshold = 0.95;
      } // Para órdagos

      if (perceivedStrength > threshold) {
        // Si vamos muy sobrados, reenvidamos
        if (perceivedStrength > threshold + 0.2 && profile.boldness > 0.6) {
          if (_random.nextDouble() < profile.boldness) {
            return BettingDecision(
              type: BettingType.envido,
              amount: currentBet + 5,
            );
          }
        }
        return BettingDecision.quiero;
      } else {
        return BettingDecision.noQuiero;
      }
    }
  }

  static double _calculateHandStrength(
    HandEvaluationResult ev,
    GamePhase phase,
  ) {
    // Retorna 0.0 a 1.0 (aprox)
    switch (phase) {
      case GamePhase.grande:
        // Basado en cartas altas. 4 Reyes es top (1.0).
        // Suma de ranks. Max ranks sum = 12*4 = 48.
        final int sum = ev.sortedRanks.fold(0, (p, c) => p + c);
        return sum / 48;
      case GamePhase.chica:
        // Inverso. Max valor son 1,1,1,1 -> sum 4. Peor 12*4=48.
        final int sum = ev.sortedRanks.fold(0, (p, c) => p + c);
        return 1.0 - (sum / 48);
      case GamePhase.pares:
        if (ev.paresType == ParesType.none) {
          return 0;
        }
        if (ev.paresType == ParesType.duples) {
          return 0.9 + (ev.paresValue / 120); // 0.9 - 1.0
        }
        if (ev.paresType == ParesType.medias) {
          return 0.6 + (ev.paresValue / 120);
        }
        return 0.3 + (ev.paresValue / 120);
      case GamePhase.juego:
        if (!ev.hasJuego) {
          return 0;
        }
        if (ev.pointSum == 31) {
          return 1;
        }
        if (ev.pointSum == 32) {
          return 0.9;
        }
        if (ev.pointSum == 40) {
          return 0.8;
        }
        return 0.5; // Resto
      case GamePhase.punto:
        if (ev.hasJuego) {
          return 0; // No debería jugarse juego en fase punto pero bueno
        }
        return ev.pointSum / 30; // 30 es el maximo punto
      default:
        return 0;
    }
  }

  static bool shouldConsultPartner(Player player) {
    // Solo consultan a veces para dar sensación de vida
    if (player.aiProfile == null) {
      return false;
    }
    // Mas probabilidad si boldness bajo
    return _random.nextDouble() > player.aiProfile!.boldness;
  }
}

enum BettingType { pass, quiero, noQuiero, envido, ordago }

class BettingDecision {
  const BettingDecision({required this.type, this.amount = 0});

  final BettingType type;
  final int amount; // Para envites específicos

  static const pass = BettingDecision(type: BettingType.pass);
  static const quiero = BettingDecision(type: BettingType.quiero);
  static const noQuiero = BettingDecision(type: BettingType.noQuiero);
  static const ordago = BettingDecision(type: BettingType.ordago);
}
