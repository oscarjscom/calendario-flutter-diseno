import 'package:flutter/material.dart';

import '../estado/estado_calendario.dart';
import '../modelos/evento.dart';
import '../tema/colores.dart';
import '../utils/fechas.dart';
import 'pulsable.dart';
import 'vidrio.dart';

/// Tarjeta con los días de la semana y la cuadrícula del mes,
/// construida con Column (semanas) y Row (días).
class CalendarioMes extends StatelessWidget {
  const CalendarioMes({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = EstadoScope.of(context);

    return Vidrio(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
      radio: BorderRadius.circular(28),
      sombra: [
        BoxShadow(
          color: AppColores.acento.withValues(alpha: 0.12),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
      ],
      child: Column(
        children: [
          _filaDiasSemana(estado),
          const SizedBox(height: 10),
          // Deslizar a los lados también cambia de mes
          GestureDetector(
            onHorizontalDragEnd: (d) {
              final v = d.primaryVelocity ?? 0;
              if (v > 250) estado.mesAnterior();
              if (v < -250) estado.mesSiguiente();
            },
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) {
                  final entrando = child.key == ValueKey(estado.mesVisible);
                  final desde = entrando
                      ? 0.25 * estado.direccion
                      : -0.25 * estado.direccion;
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween(
                        begin: Offset(desde, 0),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  );
                },
                layoutBuilder: (actual, anteriores) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...anteriores, if (actual != null) actual],
                ),
                child: Column(
                  key: ValueKey(estado.mesVisible),
                  children: _semanas(estado),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            color: AppColores.textoApagado.withValues(alpha: 0.4),
            height: 1,
          ),
          const SizedBox(height: 12),
          _leyenda(estado),
        ],
      ),
    );
  }

  /// Días de la semana dentro de una franja redondeada.
  Widget _filaDiasSemana(EstadoCalendario estado) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: AppColores.acento.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Center(
                child: Text(
                  Fechas.diasSemana[i].toUpperCase(),
                  style: TextStyle(
                    fontSize: 11.5,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800,
                    color: i >= 5 && estado.resaltarFinDeSemana
                        ? AppColores.finDeSemana
                        : AppColores.acento.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Genera las filas (semanas) del mes visible.
  List<Widget> _semanas(EstadoCalendario estado) {
    final mes = estado.mesVisible;
    final primero = DateTime(mes.year, mes.month, 1);
    final previos = primero.weekday - 1; // lunes = 1
    final total = Fechas.diasDelMes(mes.year, mes.month);
    final celdas = ((previos + total) / 7).ceil() * 7;

    // La semana que contiene el día de hoy lleva una franja de color detrás
    bool esSemanaActual(int s) {
      final inicio = DateTime(mes.year, mes.month, s - previos + 1);
      final diferencia = estado.hoy.difference(inicio).inDays;
      return diferencia >= 0 && diferencia < 7;
    }

    return [
      for (var s = 0; s < celdas; s += 7)
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: esSemanaActual(s)
                ? AppColores.acento.withValues(alpha: 0.07)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(
                  child: _CeldaDia(
                    // DateTime normaliza días fuera de rango (ej. día 0 = último del mes anterior)
                    fecha: DateTime(mes.year, mes.month, s + c - previos + 1),
                    finDeSemana: c >= 5,
                  ),
                ),
            ],
          ),
        ),
    ];
  }

  Widget _leyenda(EstadoCalendario estado) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        children: [
          _ItemLeyenda(
            color: AppColores.acento,
            texto: 'Hoy',
            relleno: true,
            tooltip: 'Ir a hoy',
            onTap: estado.irAHoy,
          ),
          for (final c in Categorias.todas) ...[
            const SizedBox(width: 14),
            _ItemLeyenda(
              color: c.color,
              texto: c.nombre,
              activo: estado.filtro == c,
              atenuado: estado.filtro != null && estado.filtro != c,
              tooltip: estado.filtro == c
                  ? 'Quitar filtro'
                  : 'Filtrar por ${c.nombre}',
              onTap: () => estado.alternarFiltro(c),
            ),
          ],
        ],
      ),
    );
  }
}

/// Una celda del calendario con su estilo según el tipo de día.
class _CeldaDia extends StatelessWidget {
  final DateTime fecha;
  final bool finDeSemana;

  const _CeldaDia({required this.fecha, required this.finDeSemana});

  @override
  Widget build(BuildContext context) {
    final estado = EstadoScope.of(context);
    final fueraDelMes = !Fechas.mismoMes(fecha, estado.mesVisible);
    final esHoy = Fechas.mismoDia(fecha, estado.hoy);
    final esSeleccionado =
        Fechas.mismoDia(fecha, estado.seleccionado) && !fueraDelMes;
    final eventos = fueraDelMes
        ? const <Evento>[]
        : estado
              .eventosDelDia(fecha)
              .where(
                (e) => estado.filtro == null || e.categoria == estado.filtro,
              )
              .toList();
    final color = eventos.isEmpty ? null : eventos.first.color;
    final radio = BorderRadius.circular(12);

    // Estilo por defecto: baldosa translúcida
    Color colorTexto = finDeSemana && estado.resaltarFinDeSemana
        ? AppColores.finDeSemana
        : AppColores.textoFuerte;
    Color colorBarra = color ?? Colors.transparent;
    BoxDecoration decoracion = BoxDecoration(
      color: Colors.white.withValues(alpha: 0.55),
      borderRadius: radio,
      border: Border.all(color: Colors.transparent, width: 1.5),
    );

    if (fueraDelMes) {
      colorTexto = AppColores.textoApagado;
      decoracion = BoxDecoration(
        borderRadius: radio,
        border: Border.all(color: Colors.transparent, width: 1.5),
      );
    } else if (esHoy) {
      colorTexto = Colors.white;
      colorBarra = Colors.white;
      decoracion = BoxDecoration(
        borderRadius: radio,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColores.cieloBajo, AppColores.acento],
        ),
        border: Border.all(
          color: esSeleccionado
              ? Colors.white.withValues(alpha: 0.8)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColores.acento.withValues(alpha: 0.45),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      );
    } else if (esSeleccionado) {
      colorTexto = AppColores.acento;
      decoracion = BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: radio,
        border: Border.all(color: AppColores.acento, width: 1.5),
      );
    } else if (color != null) {
      decoracion = BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: radio,
        border: Border.all(color: Colors.transparent, width: 1.5),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5),
      child: Pulsable(
        escalaHover: 1.08,
        onTap: () => estado.seleccionar(fecha),
        child: AspectRatio(
          // Baldosa un poco más alta que ancha
          aspectRatio: 0.86,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.fromLTRB(6, 5, 6, 6),
            decoration: decoracion,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Número arriba a la izquierda (se achica si no cabe)
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${fecha.day}',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.1,
                              fontWeight:
                                  (esHoy || color != null || esSeleccionado)
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: colorTexto,
                            ),
                          ),
                          if (esHoy)
                            const Text(
                              'HOY',
                              style: TextStyle(
                                fontSize: 8,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Una barrita por evento (máx. 3), abajo de la baldosa
                Row(
                  children: [
                    for (final e in eventos.take(3)) ...[
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: esHoy ? colorBarra : e.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      if (e != eventos.take(3).last) const SizedBox(width: 2),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemLeyenda extends StatelessWidget {
  final Color color;
  final String texto;
  final bool relleno;
  final bool activo;
  final bool atenuado;
  final String tooltip;
  final VoidCallback onTap;

  const _ItemLeyenda({
    required this.color,
    required this.texto,
    required this.tooltip,
    required this.onTap,
    this.relleno = false,
    this.activo = false,
    this.atenuado = false,
  });

  @override
  Widget build(BuildContext context) {
    return Pulsable(
      tooltip: tooltip,
      escalaHover: 1.08,
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: atenuado ? 0.35 : 1,
        child: Row(
          children: [
            // "Hoy" es un cuadrito; las categorías, una barrita como en las baldosas
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: relleno ? 9 : (activo ? 16 : 12),
              height: relleno ? 9 : 4,
              decoration: BoxDecoration(
                color: color,
                gradient: relleno
                    ? const LinearGradient(
                        colors: [AppColores.cieloBajo, AppColores.acento],
                      )
                    : null,
                borderRadius: BorderRadius.circular(relleno ? 3 : 2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              texto,
              style: TextStyle(
                fontSize: 12,
                color: activo ? color : AppColores.textoSuave,
                fontWeight: activo ? FontWeight.w800 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
