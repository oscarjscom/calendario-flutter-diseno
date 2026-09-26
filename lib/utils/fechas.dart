import 'package:flutter/material.dart';

/// Utilidades para mostrar fechas y horas en español.
class Fechas {
  static const meses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  static const mesesCortos = [
    'ENE',
    'FEB',
    'MAR',
    'ABR',
    'MAY',
    'JUN',
    'JUL',
    'AGO',
    'SEP',
    'OCT',
    'NOV',
    'DIC',
  ];

  static const diasSemana = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  static const diasSemanaLargos = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  /// Quita la hora de una fecha.
  static DateTime soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool mismoMes(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  static int diasDelMes(int anio, int mes) => DateTime(anio, mes + 1, 0).day;

  /// Ej.: "Septiembre 2026"
  static String mesAnio(DateTime d) => '${meses[d.month - 1]} ${d.year}';

  /// Ej.: "Sábado 26 de septiembre"
  static String fechaLarga(DateTime d) =>
      '${diasSemanaLargos[d.weekday - 1]} ${d.day} de ${meses[d.month - 1].toLowerCase()}';

  /// Ej.: "10:00 a.m."
  static String hora(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final periodo = t.period == DayPeriod.am ? 'a.m.' : 'p.m.';
    return '$h:$m $periodo';
  }

  /// Texto relativo: "Hoy", "Mañana", "En 3 días", "Hace 2 días".
  static String relativo(DateTime fecha, DateTime hoy) {
    final dias = soloFecha(fecha).difference(soloFecha(hoy)).inDays;
    if (dias == 0) return 'Hoy';
    if (dias == 1) return 'Mañana';
    if (dias == -1) return 'Ayer';
    if (dias > 1) return 'En $dias días';
    return 'Hace ${-dias} días';
  }
}
