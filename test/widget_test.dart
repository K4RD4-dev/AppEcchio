import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appecchio_mockup/main.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const AppEcchioApp());
    await tester.pumpAndSettle();
  }

  Future<void> loginAsResident(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Accedi'));
    await tester.tap(find.text('Accedi'));
    await tester.pumpAndSettle();
  }

  Future<void> loginAsTourist(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Turisti'));
    await tester.tap(find.text('Turisti'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Accedi'));
    await tester.tap(find.text('Accedi'));
    await tester.pumpAndSettle();
  }

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.explore_rounded));
    await tester.pump(const Duration(milliseconds: 800));
  }

  testWidgets('renders the profile login screen', (WidgetTester tester) async {
    await pumpApp(tester);

    expect(find.text('APPecchio'), findsOneWidget);
    expect(find.text('Email o codice utente'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Residenti'), findsOneWidget);
    expect(find.text('Turisti'), findsOneWidget);
    expect(find.text('Accedi'), findsOneWidget);
  });

  testWidgets('welcomes a resident user on the home screen', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await loginAsResident(tester);

    expect(find.text('Ciao, Giulia'), findsOneWidget);
    expect(find.text('Cittadino residente'), findsOneWidget);
    expect(find.text('Esplora'), findsAtLeastNWidgets(1));
    expect(find.text('Oggi'), findsOneWidget);
    expect(find.text('Aperti ora'), findsOneWidget);
    expect(find.text('Vicino a me'), findsOneWidget);
  });

  testWidgets('opens the radial menu on a phone portrait viewport', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester);
    await loginAsResident(tester);
    await openMenu(tester);

    expect(find.text('Eventi'), findsOneWidget);
    expect(find.text('Cibo e Drink'), findsOneWidget);
    expect(find.text('myApecchio'), findsOneWidget);
    expect(find.text('Impostazioni'), findsNothing);
  });

  testWidgets('uses the compact menu on a short landscape viewport', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(720, 390));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester);
    await loginAsTourist(tester);
    await openMenu(tester);

    expect(find.text('Eventi'), findsOneWidget);
    expect(find.text('Sport'), findsOneWidget);
    expect(find.text('myApecchio'), findsNothing);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });

  testWidgets('opens settings and profile pages from the home header', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await loginAsResident(tester);

    await tester.tap(find.byTooltip('Impostazioni'));
    await tester.pumpAndSettle();

    expect(find.text('Profilo'), findsOneWidget);
    expect(find.text('Preferenze'), findsOneWidget);
    expect(find.text('Permessi app'), findsOneWidget);

    await tester.tap(find.text('Permessi app'));
    await tester.pumpAndSettle();

    expect(find.text('Posizione'), findsOneWidget);
    expect(find.text('Statistiche anonime'), findsOneWidget);
    expect(find.text('Stato privacy'), findsOneWidget);
  });

  testWidgets('opens trails from the sport menu tree', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(720, 390));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester);
    await loginAsTourist(tester);
    await openMenu(tester);

    await tester.tap(find.text('Sport'));
    await tester.pump(const Duration(milliseconds: 650));
    await tester.tap(find.text('Sentieri e percorsi naturalistici'));
    await tester.pump(const Duration(milliseconds: 650));
    await tester.tap(find.text('Mappa sentieri'));
    await tester.pumpAndSettle();

    expect(find.text('Sentieri e percorsi naturalistici'), findsOneWidget);
    expect(find.text("Mappa reale online"), findsOneWidget);
    expect(find.text('Apecchio - Bivio Sentiero Italia'), findsWidgets);
  });

  testWidgets('selecting a trail opens its full-screen map', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: TrailsScreen()));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey("trail-map-button-sentiero_39")),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sentiero 39'), findsOneWidget);
    expect(find.text('Apecchio -> Bivio Sentiero Italia'), findsOneWidget);
    expect(find.text('Apri scheda sentiero'), findsOneWidget);
  });

  testWidgets('trails screen filters and opens a trail detail', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: TrailsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Tutti'), findsOneWidget);
    expect(find.text('Famiglie'), findsOneWidget);
    expect(find.textContaining('Sentiero Italia'), findsWidgets);

    await tester.tap(find.text('EE'));
    await tester.pumpAndSettle();
    expect(find.text('Piobbico - Monte Nerone'), findsWidgets);

    await tester.ensureVisible(find.text('Apri scheda sentiero'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apri scheda sentiero'));
    await tester.pumpAndSettle();

    expect(find.text('Sentiero 1'), findsOneWidget);
    expect(find.text('Difficolta EE'), findsOneWidget);
    expect(find.text('Quota massima'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Scarica GPX'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Scarica GPX'), findsOneWidget);
  });

  testWidgets('opens sport booking from the sport menu tree', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(720, 390));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester);
    await loginAsResident(tester);
    await openMenu(tester);

    await tester.tap(find.text('Sport'));
    await tester.pump(const Duration(milliseconds: 650));
    await tester.tap(find.text('Prenota impianti'));
    await tester.pump(const Duration(milliseconds: 650));
    await tester.tap(find.text('Campo da tennis'));
    await tester.pumpAndSettle();

    expect(find.text('Prenota impianti'), findsOneWidget);
    expect(find.text('Tennis outdoor'), findsWidgets);
    await tester.binding.setSurfaceSize(const Size(720, 1100));
    await tester.pumpAndSettle();
    expect(find.text('Lun'), findsOneWidget);
    expect(find.text('Mar'), findsOneWidget);
  });

  testWidgets('opens sport rules and outdoor services screens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SportRulesScreen(initialSectionId: 'tariffe')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Regolamenti e tariffe'), findsOneWidget);
    expect(find.text('Campi outdoor'), findsOneWidget);
    expect(find.text('Agevolazioni'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: OutdoorServicesScreen(initialServiceId: 'noleggio_ebike'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Servizi outdoor'), findsOneWidget);
    expect(find.text('Noleggio bici elettriche'), findsWidgets);
    await tester.drag(find.byType(ListView).last, const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Richiedi disponibilita'), findsOneWidget);
  });

  testWidgets('renders final info pages on a phone viewport', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: FinalInfoPageScreen(
          key: ValueKey('farmacia-page'),
          initialPageId: 'farmacia',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Servizi utili'), findsOneWidget);
    expect(find.text('Farmacie'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Cosa puoi fare'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Cosa puoi fare'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Chiama farmacia'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Chiama farmacia'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: FinalInfoPageScreen(
          key: ValueKey('segnalazioni-page'),
          initialPageId: 'segnalazioni',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('myApecchio'), findsOneWidget);
    expect(find.text('Segnalazioni al Comune'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Invia segnalazione'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Invia segnalazione'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: FinalInfoPageScreen(
          key: ValueKey('monte-nerone-page'),
          initialPageId: 'monte_nerone',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Territorio'), findsOneWidget);
    expect(find.text('Monte Nerone'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Apri mappa'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Apri mappa'), findsOneWidget);
  });

  testWidgets('opens a final services page from the radial menu', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(720, 390));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester);
    await loginAsResident(tester);
    await openMenu(tester);

    await tester.ensureVisible(find.text('Servizi'));
    await tester.tap(find.text('Servizi'));
    await tester.pump(const Duration(milliseconds: 650));
    await tester.ensureVisible(find.text('Farmacie'));
    await tester.tap(find.text('Farmacie'));
    await tester.pumpAndSettle();

    expect(find.text('Servizi utili'), findsOneWidget);
    expect(find.text('Farmacie'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Chiama farmacia'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Chiama farmacia'), findsOneWidget);
  });

  testWidgets('renders notices archive, calendar, detail and report flow', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: NoticesArchiveScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Archivio avvisi'), findsOneWidget);
    expect(find.text('Avvisi e segnalazioni'), findsOneWidget);
    expect(find.text('Viabilita modificata in centro'), findsWidgets);

    await tester.tap(find.byTooltip('Apri calendario avvisi'));
    await tester.pumpAndSettle();

    expect(find.text('Calendario avvisi'), findsOneWidget);
    expect(find.text('Lun'), findsOneWidget);
    expect(find.text('Mar'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Viabilita modificata in centro').first);
    await tester.pumpAndSettle();

    expect(find.text('Dettaglio avviso'), findsOneWidget);
    expect(find.text('Descrizione'), findsOneWidget);
    expect(find.text('Comune di Apecchio'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nuova segnalazione'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Lampione spento');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Segnalazione test dal mockup.',
    );
    await tester.ensureVisible(find.text('Salva segnalazione'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salva segnalazione'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Lampione spento'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Lampione spento'), findsOneWidget);
  });
}
