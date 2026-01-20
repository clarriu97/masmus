import 'dart:math';

import '../models/card.dart';
import '../models/game_action.dart';
import '../models/game_config.dart';
import '../models/player.dart';
import 'hand_evaluator.dart';
import 'mus_game.dart';

class AiLogic {
  static final Random _random = Random();

  /// Decide si quiere mus.
  /// Lógica solicitada:
  /// - Cortar siempre si tiene Juego (31, 32, 40).
  /// - Cortar siempre si tiene Medias o Duples.
  /// - Cortar siempre si es "La Mano" y tiene al menos una pareja de Reyes.
  static bool shouldAcceptMus(
    Player player,
    HandEvaluationResult ev, {
    bool isMano = false,
  }) {
    if (player.aiProfile == null) {
      return true; // Fallback
    }

    // 1. Cualquier "Juego" (31, 32, 40)
    if (ev.hasJuego) {
      if (ev.pointSum == 31 || ev.pointSum == 32 || ev.pointSum == 40) {
        return false; // Corta Mus
      }
    }

    // 2. Cualquier combinación de "Medias" o "Duples"
    if (ev.paresType == ParesType.medias || ev.paresType == ParesType.duples) {
      return false; // Corta Mus
    }

    // 3. Si es "La Mano" y tiene al menos una pareja de Reyes (12 en efectivo)
    if (isMano) {
      final counts = <int, int>{};
      for (final r in ev.sortedRanks) {
        counts[r] = (counts[r] ?? 0) + 1;
      }
      if (counts[12] != null && counts[12]! >= 2) {
        return false; // Corta Mus
      }
    }

    // En general, si no se cumple lo anterior, tiende a querer mus para mejorar
    return true;
  }

  /// Decide qué cartas descartar.
  /// Lógica solicitada:
  /// - Si tiene 3 cartas de una jugada potente (3 Reyes o 3 Ases), descartar la cuarta siempre.
  static List<MusCard> getCardsToDiscard(
    Player player,
    HandEvaluationResult ev,
  ) {
    final List<MusCard> hand = player.hand;

    // Contar reyes y ases efectivos
    final List<int> reyesIndices = [];
    final List<int> asesIndices = [];

    for (int i = 0; i < hand.length; i++) {
      // Usamos una config por defecto para el rango efectivo (8 reyes suele ser el estándar si no se pasa)
      final int rank = HandEvaluator.getEffectiveRank(
        hand[i],
        const GameConfig(eightKings: true),
      );
      if (rank == 12) {
        reyesIndices.add(i);
      }
      if (rank == 1) {
        asesIndices.add(i);
      }
    }

    // Si tiene 3 Reyes, descartar la otra
    if (reyesIndices.length == 3) {
      for (int i = 0; i < hand.length; i++) {
        if (!reyesIndices.contains(i)) {
          return [hand[i]];
        }
      }
    }

    // Si tiene 3 Ases, descartar la otra
    if (asesIndices.length == 3) {
      for (int i = 0; i < hand.length; i++) {
        if (!asesIndices.contains(i)) {
          return [hand[i]];
        }
      }
    }

    // Lógica por defecto (mantener reyes y ases)
    final List<MusCard> toDiscard = [];
    for (int i = 0; i < hand.length; i++) {
      final int rank = HandEvaluator.getEffectiveRank(
        hand[i],
        const GameConfig(eightKings: true),
      );
      if (rank != 12 && rank != 1) {
        toDiscard.add(hand[i]);
      }
    }

    // Si no descarta nada (vaya por dios), descartar la más baja al azar
    if (toDiscard.isEmpty && hand.isNotEmpty) {
      // Si tenemos 4 reyes o 4 ases, no descartamos nada (ya tenemos duples/medias máximas)
      if (reyesIndices.length == 4 || asesIndices.length == 4) {
        return [];
      }

      // Si no es el caso, descartamos la de menor rank que no sea Rey/As (ya cubierto arriba)
      // Pero si llegamos aquí es que no hay ni reyes ni ases? No, que todas lo son.
      return [];
    }

    return toDiscard;
  }

  /// Decide acción de apuesta
  static BettingDecision makeBettingDecision({
    required Player player,
    required HandEvaluationResult ev,
    required GamePhase phase,
    required int currentBet,
    required bool isPartnerWinning,
    required bool isMano, // Si somos los primeros en hablar
    required bool isPostre, // Si somos los últimos
    required List<GameAction> history,
  }) {
    if (player.aiProfile == null) {
      return BettingDecision.pass;
    }
    final profile = player.aiProfile!;

    double score = _calculateHandStrength(ev, phase);

    // 1. Memoria de Mesa y Lectura de Rivales
    score = _adjustScoreByHistory(score, phase, history, player);

    // 2. Posición en la Mesa
    if (isMano && currentBet == 0) {
      // La Mano debe abrir más aunque sea mediocre
      score += 0.15;
    }

    // 3. Sinergia de Pareja
    if (isPartnerWinning && score < 0.95) {
      // Si la pareja ya ha envidado y el rival solo ha querido o pasado, ser conservador.
      // No pisar a menos que tengamos la jugada máxima (>0.95).
      if (currentBet > 0) {
        return BettingDecision.quiero; // Apoyar pero no subir
      }
      return BettingDecision.pass;
    }

    // 4. Decisiones por Perfil
    if (currentBet == 0) {
      // ABRIR
      // El Farolero: Envidará a Grande o Chica el 80% de las veces si es el primero
      if (profile.name == 'El Farolero' &&
          (phase == GamePhase.grande || phase == GamePhase.chica) &&
          isMano) {
        if (_random.nextDouble() < 0.8) {
          return const BettingDecision(type: BettingType.envido, amount: 2);
        }
      }

      // El Postre intenta robar si todos han pasado
      if (isPostre && _random.nextDouble() < profile.bluffing) {
        return const BettingDecision(type: BettingType.envido, amount: 2);
      }

      if (score > 0.7) {
        return const BettingDecision(type: BettingType.envido, amount: 2);
      }
      if (score > 0.9 && profile.boldness > 0.7) {
        return const BettingDecision(type: BettingType.ordago);
      }

      return BettingDecision.pass;
    } else {
      // RESPONDER
      double threshold = 0.6;

      // Comportamiento por perfiles (Presets)
      if (profile.name == 'El Prudente') {
        threshold = 0.8; // Solo acepta si > 0.8
      } else if (profile.name == 'La Temeraria') {
        threshold = 0.4; // Umbral muy bajo
        // 30% de probabilidad de responder con Órdago
        if (_random.nextDouble() < 0.3) {
          return const BettingDecision(type: BettingType.ordago);
        }
      }

      if (score > threshold) {
        // Posibilidad de reenvidar
        if (score > threshold + 0.15 && profile.boldness > 0.5) {
          return BettingDecision(
            type: BettingType.envido,
            amount: currentBet + 2,
          );
        }
        return BettingDecision.quiero;
      }

      return BettingDecision.noQuiero;
    }
  }

  static double _calculateHandStrength(
    HandEvaluationResult ev,
    GamePhase phase,
  ) {
    switch (phase) {
      case GamePhase.grande:
        // Prioridad absoluta a Reyes (12) y Treses (12). 3 Reyes = 0.95
        final int kings = ev.sortedRanks.where((r) => r == 12).length;
        if (kings >= 4) {
          return 1;
        }
        if (kings == 3) {
          return 0.95;
        }
        final int sum = ev.sortedRanks.fold(0, (p, c) => p + c);
        return sum / 48;
      case GamePhase.chica:
        // Prioridad a Ases (1) y Doses (1). 3 Ases = 0.9
        final int aces = ev.sortedRanks.where((r) => r == 1).length;
        if (aces >= 4) {
          return 1;
        }
        if (aces == 3) {
          return 0.9;
        }
        final int sum = ev.sortedRanks.fold(0, (p, c) => p + c);
        return 1 - (sum / 48);
      case GamePhase.pares:
        // Duples > 0.9
        if (ev.paresType == ParesType.duples) {
          return 0.9 + (ev.paresValue / 120);
        }
        if (ev.paresType == ParesType.medias) {
          return 0.7 + (ev.paresValue / 120);
        }
        if (ev.paresType == ParesType.par) {
          return 0.4 + (ev.paresValue / 120);
        }
        return 0;
      case GamePhase.juego:
        if (!ev.hasJuego) {
          return 0;
        }
        if (ev.pointSum == 31) {
          return 1;
        }
        if (ev.pointSum == 32) {
          return 0.95;
        }
        if (ev.pointSum == 40) {
          return 0.9;
        }
        return 0.6;
      case GamePhase.punto:
        return ev.pointSum / 30;
      default:
        return 0;
    }
  }

  static double _adjustScoreByHistory(
    double score,
    GamePhase phase,
    List<GameAction> history,
    Player self,
  ) {
    // Si un rival NO cortó el mus pero apuesta fuerte en Pares o Juego -> Farol probable

    // Detect if mus was accepted by all (discard phase happened)
    final bool discardHappened = history.any(
      (a) => a.phase == GamePhase.discard,
    );

    if (discardHappened &&
        (phase == GamePhase.pares || phase == GamePhase.juego)) {
      // If they apostaron fuerte (>2)
      final strongBets = history
          .where(
            (a) =>
                (a.phase == phase) &&
                a.type == ActionType.envido &&
                a.amount > 2,
          )
          .toList();
      if (strongBets.isNotEmpty) {
        // Aumenta probabilidad de farol = disminuimos la fuerza percibida del rival (ergo, somos más valientes)
        // Pero el score es NUESTRA fuerza. Si creemos que es farol, nuestro score "vale más".
        score += 0.2;
      }
    }

    return score.clamp(0.0, 1.0);
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
