import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/game/event.dart';
import 'package:masmus/game/hand_state.dart';
import 'package:masmus/game/hand_value.dart';
import 'package:masmus/game/outcome.dart';
import 'package:masmus/l10n/app_localizations.dart';
import 'package:masmus/ui/table/table_texts.dart';
import 'package:masmus/ui/table/table_view.dart';

import '../../game/helpers.dart';
import '../../helpers/table.dart';

final l10n = lookupAppLocalizations(const Locale('es'));

TableView _view({int mano = 0}) => TableView.of(
  tableController(
    hands: const {0: 'R R C 1', 1: 'S S 7 6', 2: '4 5 6 7', 3: '4 5 1 7'},
    mano: mano,
  ).match,
  you: 0,
);

String? _status(StepView step, {TableView? view}) =>
    l10n.stepStatus(step, view ?? _view());

void main() {
  group('how each lance went', () {
    for (final (outcome, text) in [
      (const EnPaso(Lance.grande), 'en paso'),
      (const Querido(Lance.chica, stake: 5), 'querido 5'),
      (const NoQuerido(Lance.grande, team: 0, points: 1), 'Nosotros +1'),
      (const NoQuerido(Lance.pares, team: 1, points: 3), 'Ellos +3'),
      (const SinDisputa(Lance.juego, team: 1), 'de Ellos'),
      (const NotPlayed(Lance.pares), 'no se juega'),
      (const OrdagoQuerido(Lance.grande), 'órdago querido'),
    ]) {
      test(text, () {
        expect(
          _status(
            StepView(TableStep.grande, StepProgress.done, outcome: outcome),
          ),
          text,
        );
      });
    }
  });

  test('the lance being played: whose turn, or the bet', () {
    const current = StepView(TableStep.chica, StepProgress.current);
    expect(_status(current), 'te toca');
    expect(_status(current, view: _view(mano: 1)), isNull);
    expect(
      _status(
        const StepView(
          TableStep.chica,
          StepProgress.current,
          envite: Envite(
            bettor: 1,
            stake: 7,
            accepted: 2,
            ordago: false,
            responders: [0, 2],
          ),
        ),
      ),
      'envite 7',
    );
  });

  test('the mus: corrido, being cut, the discards', () {
    expect(
      _status(
        const StepView(TableStep.mus, StepProgress.current, corrido: true),
      ),
      'corrido',
    );
    expect(
      _status(
        const StepView(TableStep.mus, StepProgress.current, discarding: true),
      ),
      'descartes',
    );
    expect(
      _status(const StepView(TableStep.mus, StepProgress.done, cut: true)),
      'cortado',
    );
    expect(
      _status(const StepView(TableStep.pares, StepProgress.pending)),
      isNull,
    );
  });

  test('what players say', () {
    for (final (event, text) in [
      (const MusSaid(1), 'Mus'),
      (const NoHayMusSaid(1), 'No hay mus'),
      (const Discarded(1, count: 1), 'Pide una'),
      (const Discarded(1, count: 3), 'Pide 3'),
      (const Declared(1, lance: Lance.pares, has: true), 'Pares: sí'),
      (const Declared(1, lance: Lance.juego, has: false), 'Juego: no'),
      (const PasoSaid(1), 'Paso'),
      (const EnvidoSaid(1, amount: 2, stake: 2), 'Envido 2'),
      (const EnvidoSaid(1, amount: 5, stake: 7), '5 más'),
      (const QuieroSaid(1), 'Quiero'),
      (const NoQuieroSaid(1, partnerDecides: false), 'No quiero'),
      (const NoQuieroSaid(2, partnerDecides: true), 'Tú decides'),
      (const NoQuieroSaid(1, partnerDecides: true), 'Decide su compañero'),
      (const OrdagoSaid(1), '¡Órdago!'),
    ]) {
      expect(l10n.said(event, _view()), text);
    }
  });

  test('who each bot is to you', () {
    final view = _view();
    expect(l10n.seatRole(view, 2), 'compañero');
    expect(l10n.seatRole(view, 1), 'rival');
    expect(l10n.seatRole(view, 3), 'rival · postre');
    expect(l10n.seatRole(_view(mano: 1), 1), 'rival · mano');
  });

  test('what your hand is worth', () {
    List<String> help(String numbers) => l10n.handHelp(value(numbers));
    expect(help('R R C 1'), ['Par de reyes', 'Juego 31']);
    expect(help('S S S 6'), ['Medias de sotas', 'Juego 36']);
    expect(help('R R 7 7'), ['Duples de reyes y sietes', 'Juego 34']);
    expect(help('1 1 1 1'), ['Duples de ases', 'Punto 4']);
    expect(help('7 6 5 4'), ['Punto 22']);
    expect(value('7 6 5 4').pares, ParesKind.none);
  });
}
