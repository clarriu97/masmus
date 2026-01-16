class GameConfig {
  const GameConfig({
    this.maxPoints = 30,
    this.eightKings = false,
    this.real31 = false,
    this.autoOrdago = false,
  });

  /// Puntos para ganar (30, 40)
  final int maxPoints;

  /// ¿8 reyes? (Los 3 valen como Reyes y los 2 como Ases)
  final bool eightKings;

  /// ¿31 Real? (La 31 con la Jota/Sota gana a la 31 normal)
  final bool real31;

  /// Si es true, la partida se acaba al aceptar el primer órdago
  final bool autoOrdago;
}
