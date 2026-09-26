import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calendario_diseno/main.dart';
import 'package:calendario_diseno/utils/fechas.dart';

void main() {
  Future<void> iniciar(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const CalendarioApp());
  }

  testWidgets('Muestra el mes actual y el día de hoy', (tester) async {
    await iniciar(tester);
    expect(find.text(Fechas.mesAnio(DateTime.now())), findsOneWidget);
    expect(find.text('HOY'), findsOneWidget);
  });

  testWidgets('Las flechas cambian de mes', (tester) async {
    await iniciar(tester);
    final ahora = DateTime.now();
    await tester.tap(find.byTooltip('Mes siguiente'));
    await tester.pumpAndSettle();
    expect(
      find.text(Fechas.mesAnio(DateTime(ahora.year, ahora.month + 1))),
      findsOneWidget,
    );
  });

  testWidgets('La barra inferior cambia de pantalla', (tester) async {
    await iniciar(tester);
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Mi perfil'), findsOneWidget);
  });

  testWidgets('Se puede agregar un evento', (tester) async {
    await iniciar(tester);
    await tester.tap(find.byTooltip('Nuevo evento'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Estudiar Flutter');
    await tester.tap(find.text('Guardar evento'));
    await tester.pumpAndSettle();
    expect(find.text('Estudiar Flutter'), findsOneWidget);
  });
}
