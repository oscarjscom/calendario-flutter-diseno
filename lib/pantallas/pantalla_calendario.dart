import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../estado/estado_calendario.dart';
import '../utils/fechas.dart';
import '../widgets/calendario_mes.dart';
import '../widgets/encabezado.dart';
import '../widgets/lista_eventos.dart';
import 'pagina_base.dart';

/// Pantalla principal: encabezado, calendario, resumen y eventos.
class PantallaCalendario extends StatelessWidget {
  const PantallaCalendario({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = EstadoScope.of(context);

    // En el navegador, las flechas del teclado también cambian de mes
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): estado.mesAnterior,
        const SingleActivator(LogicalKeyboardKey.arrowRight):
            estado.mesSiguiente,
      },
      child: Focus(
        autofocus: true,
        child: PaginaBase(
          encabezado: Encabezado(
            titulo: Fechas.mesAnio(estado.mesVisible),
            subtitulo: estado.esMesActual
                ? 'Tu mes, tus planes'
                : 'Toca aquí para volver a hoy',
            iconoSubtitulo: estado.esMesActual
                ? Icons.wb_twilight_rounded
                : Icons.today_rounded,
            onAnterior: estado.mesAnterior,
            onSiguiente: estado.mesSiguiente,
            onTitulo: estado.irAHoy,
          ),
          children: const [
            CalendarioMes(),
            SizedBox(height: 18),
            ResumenMes(),
            SizedBox(height: 22),
            ListaEventos(),
          ],
        ),
      ),
    );
  }
}
