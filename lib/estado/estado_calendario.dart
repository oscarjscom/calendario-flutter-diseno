import 'package:flutter/material.dart';

import '../modelos/evento.dart';
import '../utils/fechas.dart';

/// Estado compartido de la app: mes visible, día seleccionado,
/// eventos, pestaña activa y preferencias.
class EstadoCalendario extends ChangeNotifier {
  EstadoCalendario() : hoy = Fechas.soloFecha(DateTime.now()) {
    mesVisible = DateTime(hoy.year, hoy.month);
    seleccionado = hoy;
    _cargarEventosIniciales();
  }

  final DateTime hoy;
  late DateTime mesVisible;
  late DateTime seleccionado;

  /// -1 = se fue al mes anterior, 1 = al siguiente (para la animación).
  int direccion = 0;

  int pestana = 0;
  Categoria? filtro;
  bool resaltarFinDeSemana = true;
  bool notificaciones = true;
  String nombre = 'Oscar';

  final List<Evento> _eventos = [];
  int _siguienteId = 1;

  // ---------- Consultas ----------

  List<Evento> get eventos =>
      List.of(_eventos)..sort((a, b) => _clave(a).compareTo(_clave(b)));

  List<Evento> eventosDelDia(DateTime dia) =>
      eventos.where((e) => Fechas.mismoDia(e.fecha, dia)).toList();

  List<Evento> eventosDelMes(DateTime mes, {bool conFiltro = true}) => eventos
      .where((e) => Fechas.mismoMes(e.fecha, mes))
      .where((e) => !conFiltro || filtro == null || e.categoria == filtro)
      .toList();

  List<Evento> get proximos =>
      eventos.where((e) => !e.fecha.isBefore(hoy)).toList();

  bool get esMesActual => Fechas.mismoMes(mesVisible, hoy);

  // ---------- Acciones ----------

  void mesAnterior() =>
      _irAMes(DateTime(mesVisible.year, mesVisible.month - 1), -1);

  void mesSiguiente() =>
      _irAMes(DateTime(mesVisible.year, mesVisible.month + 1), 1);

  void irAHoy() {
    seleccionado = hoy;
    pestana = 0;
    _irAMes(DateTime(hoy.year, hoy.month), mesVisible.isBefore(hoy) ? 1 : -1);
  }

  void seleccionar(DateTime dia) {
    seleccionado = Fechas.soloFecha(dia);
    if (!Fechas.mismoMes(dia, mesVisible)) {
      _irAMes(DateTime(dia.year, dia.month), dia.isAfter(mesVisible) ? 1 : -1);
    } else {
      notifyListeners();
    }
  }

  /// Muestra un evento en el calendario (cambia de pestaña y de mes).
  void verEnCalendario(Evento e) {
    pestana = 0;
    seleccionar(e.fecha);
    notifyListeners();
  }

  void cambiarPestana(int i) {
    if (pestana == i) return;
    pestana = i;
    notifyListeners();
  }

  void alternarFiltro(Categoria c) {
    filtro = filtro == c ? null : c;
    notifyListeners();
  }

  Evento agregar({
    required String titulo,
    required DateTime fecha,
    required TimeOfDay hora,
    required Categoria categoria,
  }) {
    final e = Evento(
      id: _siguienteId++,
      titulo: titulo,
      fecha: Fechas.soloFecha(fecha),
      hora: hora,
      categoria: categoria,
    );
    _eventos.add(e);
    notifyListeners();
    return e;
  }

  void eliminar(Evento e) {
    _eventos.remove(e);
    notifyListeners();
  }

  void restaurar(Evento e) {
    _eventos.add(e);
    notifyListeners();
  }

  void alternarAviso(Evento e) {
    e.aviso = !e.aviso;
    notifyListeners();
  }

  void cambiarResaltarFinDeSemana(bool v) {
    resaltarFinDeSemana = v;
    notifyListeners();
  }

  void cambiarNotificaciones(bool v) {
    notificaciones = v;
    notifyListeners();
  }

  void cambiarNombre(String v) {
    if (v.trim().isEmpty) return;
    nombre = v.trim();
    notifyListeners();
  }

  // ---------- Internos ----------

  void _irAMes(DateTime mes, int dir) {
    direccion = dir;
    mesVisible = mes;
    notifyListeners();
  }

  int _clave(Evento e) =>
      e.fecha.millisecondsSinceEpoch ~/ 60000 +
      e.hora.hour * 60 +
      e.hora.minute;

  void _cargarEventosIniciales() {
    void nuevo(String t, int d, int h, int m, Categoria c) => _eventos.add(
      Evento(
        id: _siguienteId++,
        titulo: t,
        fecha: DateTime(2026, 9, d),
        hora: TimeOfDay(hour: h, minute: m),
        categoria: c,
      ),
    );

    nuevo('Entrega del laboratorio Flutter', 3, 8, 0, Categorias.estudio);
    nuevo('Partido de fútbol', 9, 16, 0, Categorias.personal);
    nuevo('Reunión con el grupo de tesis', 16, 11, 30, Categorias.trabajo);
    nuevo('Estudiar para el parcial', 16, 18, 0, Categorias.estudio);
    nuevo('Hackathon universitario', 24, 9, 0, Categorias.proyecto);
    nuevo('Cena familiar', 28, 19, 30, Categorias.personal);
  }
}

/// Hace disponible el estado a todos los widgets de abajo.
class EstadoScope extends InheritedNotifier<EstadoCalendario> {
  const EstadoScope({
    super.key,
    required EstadoCalendario estado,
    required super.child,
  }) : super(notifier: estado);

  static EstadoCalendario of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EstadoScope>()!.notifier!;

  /// Lee el estado sin volver a construir el widget al cambiar (para callbacks).
  static EstadoCalendario leer(BuildContext context) =>
      context.getInheritedWidgetOfExactType<EstadoScope>()!.notifier!;
}
