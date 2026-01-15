import 'package:flutter/foundation.dart';

/// Palos de la baraja española
enum Suit { oros, copas, espadas, bastos }

/// Carta de Mus con su valor facial y valor de juego
@immutable
class MusCard {
  const MusCard({required this.suit, required this.faceValue});

  final Suit suit;
  final int faceValue;

  /// Valor para el juego (Juego/Punto)
  /// 1, 2, 3, 4, 5, 6, 7 valen su número
  /// 10, 11, 12 valen 10
  int get gameValue {
    if (faceValue >= 10) {
      return 10;
    }
    return faceValue;
  }

  /// Valor para ordenación (Grande/Chica/Pares)
  /// En Mus, el 3 es un Rey (12) y el 2 es un As (1) en casi todas partes,
  /// pero para la lógica base, usaremos los valores normalizados.
  /// La normalización de 3->12 y 2->1 se hará en la lógica de evaluación
  /// si la variante de 8 reyes está activa, o si se trata de 3 y 2 naturales.
  ///
  /// Por simplicidad en el modelo base, mantenemos el faceValue.
  /// La lógica de "ranking" se delegará al evaluador de manos.

  @override
  String toString() => '$faceValue de ${suit.name}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusCard &&
          runtimeType == other.runtimeType &&
          suit == other.suit &&
          faceValue == other.faceValue;

  @override
  int get hashCode => suit.hashCode ^ faceValue.hashCode;
}
