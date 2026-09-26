import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calendario_diseno/main.dart';
import 'package:calendario_diseno/widgets/encabezado.dart';

void main() {
  testWidgets('En Avisos el encabezado queda arriba y el fondo cubre todo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const CalendarioApp());

    await tester.tap(find.text('Avisos'));
    await tester.pumpAndSettle();

    final scaffold = tester.getRect(find.byType(Scaffold).first);
    final encabezado = tester.getRect(find.byType(Encabezado));
    final fondo = tester.getRect(
      find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName == 'assets/fondo_degradado.jpg',
      ),
    );

    expect(encabezado.top, scaffold.top);
    expect(fondo.height, scaffold.height);
  });
}
