import 'dart:math';

import '../models/card.dart';
import '../models/game_config.dart';

enum ParesType {
  none, // No pares
  par, // Un par
  medias, // Trio
  duples, // Dos pares (o cuatro iguales)
}

class HandEvaluationResult {
  const HandEvaluationResult({
    required this.sortedRanks,
    required this.paresType,
    required this.paresValue,
    required this.hasJuego,
    required this.pointSum,
  });

  final List<int> sortedRanks; // Para Grande/Chica comparacion
  final ParesType paresType;
  final int paresValue; // Valor representativo para desempate en pares
  final bool hasJuego;
  final int pointSum;
}

class HandEvaluator {
  /// Devuelve el valor efectivo de la carta según la configuración (8 reyes).
  /// En 8 reyes: 3 -> 12, 2 -> 1
  static int getEffectiveRank(MusCard card, GameConfig config) {
    if (config.eightKings) {
      if (card.faceValue == 3) {
        return 12; // 3 es Rey
      }
      if (card.faceValue == 2) {
        return 1; // 2 es As
      }
    }
    return card.faceValue;
  }

  /// Evalúa una mano completa y retorna todos los metadatos necesarios.
  static HandEvaluationResult evaluate(List<MusCard> hand, GameConfig config) {
    final ranks = hand.map((c) => getEffectiveRank(c, config)).toList();

    // Sort descending for easier processing
    ranks.sort((a, b) => b.compareTo(a));

    // Calculate Points (Juego)
    int sum = 0;
    for (final rank in ranks) {
      // Valor de juego: Figuras (10, 11, 12, y 3 en 8 reyes) valen 10.
      // El resto vale su número.
      // CUIDADO: La carta 3 en 8 reyes tiene rank efectivo 12 -> vale 10.
      // La carta 3 en 4 reyes tiene rank efectivo 3 -> vale 3.
      if (rank >= 10) {
        sum += 10;
      } else {
        sum += rank;
      }
    }

    final hasJuego = sum > 30;

    // Evaluate Pares
    ParesType pType = ParesType.none;
    int pValue = 0;

    // Count frequencies
    final counts = <int, int>{};
    for (final r in ranks) {
      counts[r] = (counts[r] ?? 0) + 1;
    }

    // Determine Pares Type
    // 4 cartas:
    // 4 iguales -> Duples (mayor rango)
    // 3 iguales -> Medias
    // 2 iguales + 2 iguales -> Duples
    // 2 iguales + 1 + 1 -> Par
    // Todo distinto -> None

    if (counts.containsValue(4)) {
      pType = ParesType.duples;
      pValue = counts.keys.first;
    } else if (counts.containsValue(3)) {
      pType = ParesType.medias;
      // El valor clave es el del trio
      pValue = counts.entries.firstWhere((e) => e.value == 3).key;
    } else {
      final pairs = counts.entries.where((e) => e.value == 2).toList();
      if (pairs.length == 2) {
        pType = ParesType.duples;
        // Ordenamos pares para saber cual es el mayor.
        // Aunque ranks ya estaba ordenado, ensure higher pair first for comparison logic if needed
        // En duples, gana el que tenga el par más alto. Si empate, el segundo par.
        // Pero pValue simple aquí podría no bastar para comparación completa de duples.
        // Simplificación: pValue representará el par más alto.
        // La comparación real necesita mirar ambos pares si hay empate.
        // Ajustaremos la lógica de comparePares para usar raw ranks.
        pValue = pairs.map((e) => e.key).reduce(max);
      } else if (pairs.length == 1) {
        pType = ParesType.par;
        pValue = pairs.first.key;
      }
    }

    return HandEvaluationResult(
      sortedRanks: ranks,
      paresType: pType,
      paresValue:
          pValue, // Nota: esto es una simplificación, la comparación real usará sortedRanks
      hasJuego: hasJuego,
      pointSum: sum,
    );
  }

  /// Compara dos manos para "Grande".
  /// Retorna >0 si handA gana, <0 si handB gana, 0 si empate (misma mano).
  /// Gana quien tenga cartas más altas (orden lexicográfico descendente).
  static int compareGrande(List<int> ranksA, List<int> ranksB) {
    for (int i = 0; i < 4; i++) {
      if (ranksA[i] != ranksB[i]) {
        return ranksA[i] - ranksB[i];
      }
    }
    return 0;
  }

  /// Compara dos manos para "Chica".
  /// Retorna >0 si handA gana, <0 si handB gana (gana la más baja).
  /// El orden es lexicográfico ascendente (o simplemente inverso a grande).
  /// Pero atención: En chica gana el que tiene las cartas más bajas.
  /// Ej: 1,1,1,1 gana a 4,1,1,1.
  /// CompareGrande(1..., 4...) daría negativo (4 gana a 1 en grande).
  /// Aquí queremos que 1 gane a 4.
  static int compareChica(List<int> ranksA, List<int> ranksB) {
    // Usamos los mismos ranks (ordenados descendente: K, K, 7, 4)
    // Pero la comparación se invierte en el primer punto de diferencia.
    // Si A tiene K,7... y B tiene K,6...
    // Grande: 7 vs 6 -> A gana.
    // Chica: 7 vs 6 -> B gana (6 es menor que 7).

    // Ojo: en reglas de mus, Chica se mira "empezando por la más baja"?
    // No, se mira igual: "Por las cartas de mayor valor" pero buscando la más baja?
    // REGLA OFICIAL: "Gana quien tiene las cartas más bajas".
    // 5 4 1 1 vs 5 4 2 1.
    // Grande: 5=5, 4=4, 2>1 -> Gana B.
    // Chica: 5=5, 4=4, 1<2 -> Gana A.
    // Es exactamente la inversa de Grande.
    return compareGrande(ranksB, ranksA);
  }

  /// Compara pares.
  /// Asume que ambas manos TIENEN pares y del MISMO tipo (Par, Medias, Duples).
  /// Si tipos distintos, gana el tipo superior (Duples > Medias > Par).
  static int compareParesLogic(
    List<int> ranksA,
    List<int> ranksB,
    ParesType type,
  ) {
    // En pares siempre gana la carta más alta que forma el par/medias/duples.
    // Si empate, se mira la siguiente (en duples).

    if (type == ParesType.par) {
      // Buscar el valor del par en A y B
      final parA = _findPairValue(ranksA);
      final parB = _findPairValue(ranksB);
      if (parA != parB) {
        return parA - parB;
      }
      // Empate en el par: no se mira el resto ('kicker' no importa en mus para ganar la fase,
      // solo importa el par. Si mismo par -> empate de posición decide mano).
      return 0;
    }

    if (type == ParesType.medias) {
      final mediaA = _findTrioValue(ranksA);
      final mediaB = _findTrioValue(ranksB);
      return mediaA - mediaB;
    }

    if (type == ParesType.duples) {
      // Comparar par mayor, luego par menor.
      final duplesA = _findDupleValues(ranksA);
      final duplesB = _findDupleValues(ranksB);

      // Mayor vs Mayor
      if (duplesA[0] != duplesB[0]) {
        return duplesA[0] - duplesB[0];
      }
      // Menor vs Menor
      return duplesA[1] - duplesB[1];
    }

    return 0;
  }

  static int _findPairValue(List<int> ranks) {
    // ranks sorted desc.
    // pairs are adjacent
    for (int i = 0; i < ranks.length - 1; i++) {
      if (ranks[i] == ranks[i + 1]) {
        return ranks[i];
      }
    }
    return 0;
  }

  static int _findTrioValue(List<int> ranks) {
    for (int i = 0; i < ranks.length - 2; i++) {
      if (ranks[i] == ranks[i + 1] && ranks[i] == ranks[i + 2]) {
        return ranks[i];
      }
    }
    return 0;
  }

  static List<int> _findDupleValues(List<int> ranks) {
    // 4 iguales
    if (ranks[0] == ranks[3]) {
      return [ranks[0], ranks[0]];
    }

    // 2 y 2 (ordenado desc: a,a,b,b)
    if (ranks[0] == ranks[1] && ranks[2] == ranks[3]) {
      // Como está ordenado, ranks[0] >= ranks[2]
      return [ranks[0], ranks[2]];
    }
    // No puede haber a,a,b,c o a,b,b,c si son duples.
    // Solo puede ser 3,1 (medias, no duples) o 2,2 o 4.
    return [0, 0];
  }

  /// Compara Juego.
  /// Orden: 31 > 32 > 40 > 37 > 36 > 35 > 34 > 33.
  /// Si ambos tienen juego, gana el mejor juego.
  /// Retorna >0 si A gana.
  static int compareJuego(int sumA, int sumB, GameConfig config) {
    // Caso especial 31 Real (si implementado, requeriría chequear si hay Jota o 7o?)
    // "La '31 Real' gana a la 31 normal".
    // Para simplificar, asumiremos por ahora comparacion estandar numérica con la lógica particular del mus.
    // Escala de valor de juego:
    // 31 -> Mejor (Ranking 1)
    // 32 -> Ranking 2
    // 40 -> Ranking 3
    // 37...33 -> Ranking 4...

    final rankA = _getJuegoRank(sumA);
    final rankB = _getJuegoRank(sumB);

    // Mayor rank es mejor (porque asignamos 100 a la 31, 90 a la 32..)
    if (rankA != rankB) {
      return rankA - rankB;
    }
    return 0;
  }

  static int comparePunto(int sumA, int sumB) {
    // Punto: 30 > 29 > ... > 4
    // Mayor suma gana.
    return sumA - sumB;
  }

  static int _getJuegoRank(int sum) {
    if (sum == 31) {
      return 100;
    }
    if (sum == 32) {
      return 90;
    }
    if (sum == 40) {
      return 80;
    }
    if (sum >= 33 && sum <= 37) {
      return sum; // 37 > 33.
    }
    // Espera, el orden es 31, 32, 40, 37, 36, 35, 34, 33.
    // Asignemos valores numéricos que crezcan con la fuerza.

    // Mapeo explicito de fuerza
    switch (sum) {
      case 31:
        return 100;
      case 32:
        return 90;
      case 40:
        return 80;
      case 37:
        return 70;
      case 36:
        return 60;
      case 35:
        return 50;
      case 34:
        return 40;
      case 33:
        return 30;
      default:
        return 0; // No juego
    }
  }
}
