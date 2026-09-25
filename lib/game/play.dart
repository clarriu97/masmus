import 'cards.dart';
import 'deck.dart';
import 'event.dart';
import 'hand_state.dart';
import 'hand_value.dart';
import 'move.dart';
import 'outcome.dart';
import 'table.dart';

/// The kinds of move [seat] may make now; empty when it is not their turn.
/// An envido needs at least [minEnvido]; a discard, 1 to 4 of their cards.
Set<MoveKind> legalMoves(HandState state, int seat) {
  if (state.turn != seat) {
    return const {};
  }
  return switch (state.phase) {
    MusTurn() => const {MoveKind.mus, MoveKind.noHayMus},
    DiscardTurn() => const {MoveKind.discard},
    LanceTurn(envite: null) => const {
      MoveKind.paso,
      MoveKind.envido,
      MoveKind.ordago,
    },
    LanceTurn(envite: Envite(ordago: true)) => const {
      MoveKind.quiero,
      MoveKind.noQuiero,
    },
    LanceTurn() => const {
      MoveKind.quiero,
      MoveKind.noQuiero,
      MoveKind.envido,
      MoveKind.ordago,
    },
    HandOver() => const {},
  };
}

bool isLegal(HandState state, int seat, Move move) {
  if (!legalMoves(state, seat).contains(move.kind)) {
    return false;
  }
  return switch (move) {
    Discard(:final cards) =>
      cards.isNotEmpty &&
          cards.length <= 4 &&
          cards.toSet().length == cards.length &&
          cards.every(state.hands[seat].contains),
    Envido(:final amount) => amount >= minEnvido,
    _ => true,
  };
}

/// The state after [seat] makes [move]. An illegal move is a programming
/// error: callers only offer what [legalMoves] allows.
HandState play(HandState state, int seat, Move move) {
  if (!isLegal(state, seat, move)) {
    throw StateError('Seat $seat cannot $move now (${state.phase.toJson()})');
  }
  return switch ((state.phase, move)) {
    (final MusTurn phase, Mus()) => _mus(state, phase),
    (MusTurn(), NoHayMus()) => _cutMus(state, seat),
    (final DiscardTurn phase, final Discard discard) => _discard(
      state,
      phase,
      discard.cards,
    ),
    (final LanceTurn phase, _) => _speak(state, phase, move),
    _ => throw StateError('Unhandled $move in ${state.phase.toJson()}'),
  };
}

HandState _mus(HandState state, MusTurn phase) {
  final log = [...state.log, MusSaid(phase.seat)];
  if (phase.said == 3) {
    return state.copyWith(
      phase: DiscardTurn(state.mano, chosen: const {}),
      log: log,
    );
  }
  return state.copyWith(
    phase: MusTurn(nextSeat(phase.seat), said: phase.said + 1),
    log: log,
  );
}

HandState _cutMus(HandState state, int seat) {
  var next = state.copyWith(log: [...state.log, NoHayMusSaid(seat)]);
  if (state.musCorrido && seat != state.mano) {
    next = next.copyWith(mano: seat, log: [...next.log, ManoMoved(seat)]);
  }
  return _startLance(next, Lance.grande);
}

HandState _discard(
  HandState state,
  DiscardTurn phase,
  List<PlayingCard> cards,
) {
  final chosen = {
    ...phase.chosen,
    phase.seat: List<PlayingCard>.unmodifiable(cards),
  };
  final log = [...state.log, Discarded(phase.seat, count: cards.length)];
  if (chosen.length < 4) {
    return state.copyWith(
      phase: DiscardTurn(nextSeat(phase.seat), chosen: chosen),
      log: log,
    );
  }
  final order = speakingOrder(state.mano);
  final hands = [
    for (final seat in seats)
      [
        for (final card in state.hands[seat])
          if (!chosen[seat]!.contains(card)) card,
      ],
  ];
  var stock = state.stock;
  var discards = [
    ...state.discards,
    for (final seat in order) ...chosen[seat]!,
  ];
  var random = state.random;
  for (final seat in order) {
    final count = 4 - hands[seat].length;
    if (count > stock.length) {
      log.add(const Reshuffled());
    }
    final served = serve(
      count,
      stock: stock,
      discards: discards,
      random: random,
    );
    hands[seat] = [...hands[seat], ...served.cards];
    stock = served.stock;
    discards = served.discards;
    random = served.random;
  }
  var mano = state.mano;
  if (state.musCorrido) {
    mano = nextSeat(mano);
    log.add(ManoMoved(mano));
  }
  return state.copyWith(
    mano: mano,
    hands: hands,
    stock: stock,
    discards: discards,
    random: random,
    phase: MusTurn(mano, said: 0),
    log: log,
  );
}

/// Opens [lance], or records it straight away when it can't be bet on
/// (R-DEC-2, R-DEC-3) and moves on.
HandState _startLance(HandState state, Lance lance) {
  final order = speakingOrder(state.mano);
  final log = [...state.log];
  var eligible = order;
  if (lance == Lance.pares || lance == Lance.juego) {
    bool has(int seat) => lance == Lance.pares
        ? state.valueOf(seat).hasPares
        : state.valueOf(seat).hasJuego;
    for (final seat in order) {
      log.add(Declared(seat, lance: lance, has: has(seat)));
    }
    eligible = [
      for (final seat in order)
        if (has(seat)) seat,
    ];
    if (eligible.isEmpty) {
      final declared = state.copyWith(log: log);
      return lance == Lance.pares
          ? _close(declared, const NotPlayed(Lance.pares))
          : _startLance(declared, Lance.punto);
    }
    final teams = {for (final seat in eligible) teamOf(seat)};
    if (teams.length == 1) {
      return _close(
        state.copyWith(log: log),
        SinDisputa(lance, team: teams.single),
      );
    }
  }
  return state.copyWith(
    phase: LanceTurn(lance, seat: eligible.first, eligible: eligible),
    log: [
      ...log,
      LanceStarted(lance, seats: eligible),
    ],
  );
}

HandState _speak(HandState state, LanceTurn phase, Move move) {
  final seat = phase.seat;
  final envite = phase.envite;
  return switch ((move, envite)) {
    (Paso(), _) => _paso(state, phase),
    (Envido(:final amount), null) => _bet(
      state,
      phase,
      EnvidoSaid(seat, amount: amount, stake: amount),
      stake: amount,
      accepted: 0,
      ordago: false,
    ),
    (Envido(:final amount), final Envite envite) => _bet(
      state,
      phase,
      EnvidoSaid(seat, amount: amount, stake: envite.stake + amount),
      stake: envite.stake + amount,
      accepted: envite.stake,
      ordago: false,
    ),
    (Ordago(), _) => _bet(
      state,
      phase,
      OrdagoSaid(seat),
      stake: envite?.stake ?? 0,
      accepted: envite?.stake ?? 0,
      ordago: true,
    ),
    (Quiero(), final Envite envite) => _close(
      state.copyWith(log: [...state.log, QuieroSaid(seat)]),
      envite.ordago
          ? OrdagoQuerido(phase.lance)
          : Querido(phase.lance, stake: envite.stake),
    ),
    (NoQuiero(), final Envite envite) => _noQuiero(state, phase, envite),
    _ => throw StateError('Unhandled $move in ${phase.toJson()}'),
  };
}

HandState _paso(HandState state, LanceTurn phase) {
  final log = [...state.log, PasoSaid(phase.seat)];
  final index = phase.eligible.indexOf(phase.seat);
  if (index == phase.eligible.length - 1) {
    return _close(state.copyWith(log: log), EnPaso(phase.lance));
  }
  return state.copyWith(
    phase: LanceTurn(
      phase.lance,
      seat: phase.eligible[index + 1],
      eligible: phase.eligible,
    ),
    log: log,
  );
}

/// An envite, a raise or an órdago: the other pair answers, starting with
/// the first of them who speaks after the bettor (R-ENV-3, R-ENV-4).
HandState _bet(
  HandState state,
  LanceTurn phase,
  GameEvent said, {
  required int stake,
  required int accepted,
  required bool ordago,
}) {
  final bettor = phase.seat;
  final responders = [
    for (var i = 1; i < 4; i++) (bettor + i) % 4,
  ].where((s) => teamOf(s) != teamOf(bettor) && phase.eligible.contains(s));
  final envite = Envite(
    bettor: bettor,
    stake: stake,
    accepted: accepted,
    ordago: ordago,
    responders: List.unmodifiable(responders),
  );
  return state.copyWith(
    phase: LanceTurn(
      phase.lance,
      seat: envite.responders.first,
      eligible: phase.eligible,
      envite: envite,
    ),
    log: [...state.log, said],
  );
}

HandState _noQuiero(HandState state, LanceTurn phase, Envite envite) {
  final rest = envite.responders.skip(1).toList();
  final said = NoQuieroSaid(phase.seat, partnerDecides: rest.isNotEmpty);
  final log = [...state.log, said];
  if (rest.isNotEmpty) {
    return state.copyWith(
      phase: LanceTurn(
        phase.lance,
        seat: rest.first,
        eligible: phase.eligible,
        envite: Envite(
          bettor: envite.bettor,
          stake: envite.stake,
          accepted: envite.accepted,
          ordago: envite.ordago,
          responders: List.unmodifiable(rest),
        ),
      ),
      log: log,
    );
  }
  return _close(
    state.copyWith(log: log),
    NoQuerido(
      phase.lance,
      team: teamOf(envite.bettor),
      points: envite.noQuieroPoints,
    ),
  );
}

HandState _close(HandState state, LanceOutcome outcome) {
  final closed = state.copyWith(
    outcomes: [...state.outcomes, outcome],
    log: [...state.log, LanceClosed(outcome)],
  );
  final next = switch (outcome) {
    OrdagoQuerido() => null,
    _ => switch (outcome.lance) {
      Lance.grande => Lance.chica,
      Lance.chica => Lance.pares,
      Lance.pares => Lance.juego,
      Lance.juego || Lance.punto => null,
    },
  };
  if (next == null) {
    return closed.copyWith(
      phase: const HandOver(),
      log: [...closed.log, const HandEnded()],
    );
  }
  return _startLance(closed, next);
}
