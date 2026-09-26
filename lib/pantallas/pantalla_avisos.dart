import 'package:flutter/material.dart';

import '../estado/estado_calendario.dart';
import '../tema/colores.dart';
import '../utils/fechas.dart';
import '../widgets/encabezado.dart';
import '../widgets/hojas.dart';
import '../widgets/lista_eventos.dart';
import '../widgets/pulsable.dart';
import '../widgets/vidrio.dart';
import 'pagina_base.dart';

/// Recordatorios de los próximos eventos.
class PantallaAvisos extends StatelessWidget {
  const PantallaAvisos({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = EstadoScope.of(context);
    final proximos = estado.proximos;
    final activos = proximos.where((e) => e.aviso).length;

    return PaginaBase(
      encabezado: Encabezado(
        titulo: 'Avisos',
        subtitulo: estado.notificaciones
            ? '$activos recordatorios activos'
            : 'Notificaciones en pausa',
        iconoSubtitulo: Icons.notifications_active_rounded,
      ),
      children: [
        // Interruptor general
        Vidrio(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          radio: BorderRadius.circular(22),
          sombra: [
            BoxShadow(
              color: AppColores.acento.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColores.acento.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  estado.notificaciones
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_rounded,
                  color: AppColores.acento,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notificaciones',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColores.textoFuerte,
                      ),
                    ),
                    Text(
                      'Recibir recordatorios de eventos',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColores.textoSuave,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: estado.notificaciones,
                activeTrackColor: AppColores.acento,
                onChanged: estado.cambiarNotificaciones,
              ),
            ],
          ),
        ),
        const TituloSeccion('Próximos eventos'),
        if (proximos.isEmpty)
          const EstadoVacio(
            icono: Icons.notifications_none_rounded,
            titulo: 'No hay eventos próximos',
            texto: 'Los eventos que agregues aparecerán aquí',
          ),
        for (final e in proximos)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: estado.notificaciones ? 1 : 0.5,
              child: Pulsable(
                escalaHover: 1.02,
                onTap: () => mostrarDetalleEvento(context, e),
                child: Vidrio(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                  radio: BorderRadius.circular(20),
                  colorBorde: usarVidrio
                      ? null
                      : e.color.withValues(alpha: 0.2),
                  anchoBorde: 1,
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: e.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(e.icono, color: e.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.titulo,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColores.textoFuerte,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${Fechas.relativo(e.fecha, estado.hoy)} · ${Fechas.hora(e.hora)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: e.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: e.aviso && estado.notificaciones,
                        activeTrackColor: e.color,
                        onChanged: estado.notificaciones
                            ? (_) => estado.alternarAviso(e)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
