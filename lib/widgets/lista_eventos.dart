import 'package:flutter/material.dart';

import '../estado/estado_calendario.dart';
import '../modelos/evento.dart';
import '../tema/colores.dart';
import '../utils/fechas.dart';
import 'hojas.dart';
import 'pulsable.dart';
import 'vidrio.dart';

/// Resumen del mes visible: tres tarjetas pequeñas en una fila.
class ResumenMes extends StatelessWidget {
  const ResumenMes({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = EstadoScope.of(context);
    final mes = estado.mesVisible;
    final total = Fechas.diasDelMes(mes.year, mes.month);

    // Avance y días que quedan según si el mes ya pasó, es el actual o es futuro
    int transcurridos;
    if (estado.esMesActual) {
      transcurridos = estado.hoy.day;
    } else if (mes.isBefore(estado.hoy)) {
      transcurridos = total;
    } else {
      transcurridos = 0;
    }
    final avance = (transcurridos * 100 / total).round();

    return Row(
      children: [
        Expanded(
          child: _TarjetaResumen(
            icono: Icons.event_available_rounded,
            valor: '${estado.eventosDelMes(mes, conFiltro: false).length}',
            etiqueta: 'Eventos',
            color: AppColores.acento,
            onTap: () => estado.cambiarPestana(1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TarjetaResumen(
            icono: Icons.donut_large_rounded,
            valor: '$avance%',
            etiqueta: 'Avance',
            color: AppColores.verde,
            onTap: estado.irAHoy,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TarjetaResumen(
            icono: Icons.hourglass_bottom_rounded,
            valor: '${total - transcurridos}',
            etiqueta: 'Quedan',
            color: AppColores.naranja,
            onTap: () => estado.cambiarPestana(2),
          ),
        ),
      ],
    );
  }
}

class _TarjetaResumen extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String etiqueta;
  final Color color;
  final VoidCallback onTap;

  const _TarjetaResumen({
    required this.icono,
    required this.valor,
    required this.etiqueta,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pulsable(
      onTap: onTap,
      child: Vidrio(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        radio: BorderRadius.circular(18),
        colorBorde: usarVidrio ? null : color.withValues(alpha: 0.15),
        anchoBorde: 1,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icono, color: color, size: 18),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      valor,
                      key: ValueKey(valor),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppColores.textoFuerte,
                      ),
                    ),
                  ),
                  // Se achica un poco en pantallas angostas en vez de cortarse
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      etiqueta,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColores.textoSuave,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lista de eventos del mes visible (respeta el filtro de categoría).
class ListaEventos extends StatelessWidget {
  const ListaEventos({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = EstadoScope.of(context);
    final eventos = estado.eventosDelMes(estado.mesVisible);
    final titulo = estado.filtro == null
        ? 'Eventos del mes'
        : 'Eventos · ${estado.filtro!.nombre}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                titulo,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: AppColores.textoFuerte,
                ),
              ),
            ),
            Pulsable(
              onTap: () => estado.cambiarPestana(1),
              child: const Row(
                children: [
                  Text(
                    'Ver todos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColores.acento,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColores.acento,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (eventos.isEmpty)
          EstadoVacio(
            icono: Icons.event_busy_rounded,
            titulo: estado.filtro == null
                ? 'Sin eventos este mes'
                : 'Sin eventos de ${estado.filtro!.nombre.toLowerCase()}',
            texto: 'Elige un día y toca + para agregar uno',
          )
        else
          for (final evento in eventos)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TarjetaEvento(
                evento: evento,
                resaltado: Fechas.mismoDia(evento.fecha, estado.seleccionado),
              ),
            ),
      ],
    );
  }
}

/// Tarjeta de un evento. Al tocarla abre su detalle.
class TarjetaEvento extends StatelessWidget {
  final Evento evento;
  final bool resaltado;
  final Widget? accion;

  const TarjetaEvento({
    super.key,
    required this.evento,
    this.resaltado = false,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    final c = evento.color;
    return Pulsable(
      escalaHover: 1.02,
      onTap: () => mostrarDetalleEvento(context, evento),
      child: Vidrio(
        radio: BorderRadius.circular(20),
        colorBorde: resaltado
            ? c.withValues(alpha: 0.6)
            : (usarVidrio ? null : Colors.transparent),
        anchoBorde: 1.5,
        sombra: [
          BoxShadow(
            color: c.withValues(alpha: resaltado ? 0.25 : 0.10),
            blurRadius: resaltado ? 22 : 18,
            offset: const Offset(0, 6),
          ),
        ],
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra lateral de color
              Container(width: 5, color: c),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Caja de fecha
                      Container(
                        width: 54,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: c.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${evento.fecha.day}',
                              style: TextStyle(
                                fontSize: 24,
                                height: 1.1,
                                fontWeight: FontWeight.w800,
                                color: c,
                              ),
                            ),
                            Text(
                              Fechas.mesesCortos[evento.fecha.month - 1],
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w700,
                                color: c,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Información del evento
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              evento.titulo,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: AppColores.textoFuerte,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.schedule_rounded,
                                  size: 14,
                                  color: AppColores.textoSuave,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    Fechas.hora(evento.hora),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColores.textoSuave,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: c.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      evento.categoria.nombre,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: c,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Acción personalizada o ícono del evento
                      accion ??
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [c.withValues(alpha: 0.75), c],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              evento.icono,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mensaje amigable cuando no hay nada que mostrar.
class EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String texto;

  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Vidrio(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        radio: BorderRadius.circular(20),
        colorBorde: usarVidrio
            ? null
            : AppColores.acento.withValues(alpha: 0.12),
        anchoBorde: 1,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColores.acento.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, color: AppColores.acento, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColores.textoFuerte,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColores.textoSuave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
