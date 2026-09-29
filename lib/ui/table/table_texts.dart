import '../../game/event.dart';
import '../../game/hand_value.dart';
import '../../game/outcome.dart';
import '../../game/table.dart';
import '../../l10n/app_localizations.dart';
import 'table_view.dart';

/// What the table's model says, in words.
extension TableTexts on AppLocalizations {
  String stepLabel(StepView step) => stepName(step.step.name);

  /// Under a step: how it went, or what is going on in it.
  String? stepStatus(StepView step, TableView view) {
    String team(int team) => team == teamOf(view.you) ? 'us' : 'them';
    return switch (step) {
      StepView(state: StepProgress.pending) => null,
      StepView(step: TableStep.mus, state: StepProgress.done) => stepCut,
      StepView(step: TableStep.mus, discarding: true) => stepDiscards,
      StepView(step: TableStep.mus, corrido: true) => stepCorrido,
      StepView(state: StepProgress.done, :final outcome?) => switch (outcome) {
        EnPaso() => stepEnPaso,
        Querido(:final stake) => stepQuerido(stake),
        NoQuerido(team: final winner, :final points) => stepNoQuerido(
          team(winner),
          points,
        ),
        SinDisputa(team: final winner) => stepSinDisputa(team(winner)),
        NotPlayed() => stepNotPlayed,
        OrdagoQuerido() => stepOrdagoQuerido,
      },
      StepView(:final envite?) =>
        envite.ordago ? stepOrdago : stepEnvite(envite.stake),
      _ => view.yourTurn ? stepYourTurn : null,
    };
  }

  /// In the middle of the table: the step being played, or the lance that
  /// just closed while the table holds it.
  String center(TableView view) => switch (view.latest) {
    NoHayMusSaid() => stepName('mus'),
    LanceClosed(:final outcome) => stepName(outcome.lance.name),
    HandEnded() => centerHandOver,
    _ => switch (view.current) {
      final step? => stepLabel(step),
      null => '',
    },
  };

  /// Under it: how that lance went, what is bet, or what is going on.
  String centerValue(TableView view) {
    final current = view.current;
    return switch (view.latest) {
      NoHayMusSaid() => stepCut,
      LanceClosed(:final outcome) =>
        stepStatus(
              StepView(
                TableStep.values.byName(outcome.lance.name),
                StepProgress.done,
                outcome: outcome,
              ),
              view,
            ) ??
            '',
      HandEnded() => centerToCount,
      _ => switch (current) {
        null => '—',
        StepView(step: TableStep.mus, discarding: true) => stepDiscards,
        StepView(step: TableStep.mus, corrido: true) => stepCorrido,
        StepView(step: TableStep.mus) => centerMus,
        StepView(declaring: true, :final step) => centerDeclaring(step.name),
        StepView(envite: (ordago: true, stake: _)) => stepOrdago,
        StepView(envite: (:final stake, ordago: false)) => '$stake',
        _ => '—',
      },
    };
  }

  /// A bot's place at the table: partner or rival, and mano or postre.
  String seatRole(TableView view, int seat) => roleSeat(
    view.partnerOf(seat) ? 'partner' : 'rival',
    seat == view.mano
        ? 'mano'
        : seat == view.postre
        ? 'postre'
        : 'none',
  );

  String said(GameEvent event, TableView view) => switch (event) {
    MusSaid() => saidMus,
    NoHayMusSaid() => saidNoHayMus,
    Discarded(:final count) => saidDiscarded(count),
    Declared(:final lance, :final has) => saidDeclared(
      lance == Lance.pares ? 'pares' : 'juego',
      has ? 'yes' : 'no',
    ),
    PasoSaid() => saidPaso,
    EnvidoSaid(:final amount, :final stake) => saidEnvido(
      stake > amount ? 'yes' : 'no',
      amount,
    ),
    QuieroSaid() => saidQuiero,
    NoQuieroSaid(:final seat, partnerDecides: true) => saidPartnerDecides(
      view.partnerOf(seat) ? 'you' : 'other',
    ),
    NoQuieroSaid() => saidNoQuiero,
    OrdagoSaid() => saidOrdago,
    _ => throw ArgumentError.value(event, 'event', 'Nobody says it'),
  };

  /// Your pares, if any, and your juego or punto.
  List<String> handHelp(HandValue value) {
    final ranks = [for (final rank in value.paresRanks) rankPlural('$rank')];
    return [
      if (value.hasPares)
        helpPares(
          switch (value.pares) {
            ParesKind.duples when ranks[0] == ranks[1] => 'four',
            final kind => kind.name,
          },
          ranks.first,
          ranks.last,
        ),
      if (value.hasJuego) helpJuego(value.points) else helpPunto(value.points),
    ];
  }
}
