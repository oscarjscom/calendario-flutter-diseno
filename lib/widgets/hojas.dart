import 'package:flutter/material.dart';

import '../estado/estado_calendario.dart';
import '../modelos/evento.dart';
import '../tema/colores.dart';
import '../utils/fechas.dart';
import 'pulsable.dart';

/// Muestra un aviso flotante en la parte inferior.
void mostrarMensaje(
  ScaffoldMessengerState messenger,
  String texto, {
  String? accion,
  VoidCallback? onAccion,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(texto),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColores.cieloAlto,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        duration: const Duration(seconds: 3),
        action: accion == null
            ? null
            : SnackBarAction(
                label: accion,
                textColor: AppColores.sol,
                onPressed: onAccion!,
              ),
      ),
    );
}

Future<void> _abrirHoja(BuildContext context, Widget contenido) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColores.cieloAlto.withValues(alpha: 0.45),
    builder: (_) => Padding(
      // Deja espacio para el teclado
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
        decoration: const BoxDecoration(
          color: AppColores.tarjeta,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Asa de la hoja
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColores.textoApagado,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              contenido,
            ],
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Detalle de un evento
// ---------------------------------------------------------------------------

void mostrarDetalleEvento(BuildContext context, Evento evento) {
  final estado = EstadoScope.leer(context);
  final messenger = ScaffoldMessenger.of(context);
  _abrirHoja(
    context,
    _DetalleEvento(
      evento: evento,
      onVer: () {
        Navigator.pop(context);
        estado.verEnCalendario(evento);
      },
      onEliminar: () {
        Navigator.pop(context);
        estado.eliminar(evento);
        mostrarMensaje(
          messenger,
          'Evento "${evento.titulo}" eliminado',
          accion: 'Deshacer',
          onAccion: () => estado.restaurar(evento),
        );
      },
    ),
  );
}

class _DetalleEvento extends StatelessWidget {
  final Evento evento;
  final VoidCallback onVer;
  final VoidCallback onEliminar;

  const _DetalleEvento({
    required this.evento,
    required this.onVer,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final estado = EstadoScope.of(context);
    final c = evento.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [c.withValues(alpha: 0.75), c],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(evento.icono, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evento.titulo,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: AppColores.textoFuerte,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _Chip(texto: evento.categoria.nombre, color: c),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _FilaDato(
          icono: Icons.calendar_today_rounded,
          texto: Fechas.fechaLarga(evento.fecha),
        ),
        _FilaDato(
          icono: Icons.schedule_rounded,
          texto: Fechas.hora(evento.hora),
        ),
        _FilaDato(
          icono: Icons.timelapse_rounded,
          texto: Fechas.relativo(evento.fecha, estado.hoy),
        ),
        const SizedBox(height: 6),
        // Recordatorio
        Container(
          padding: const EdgeInsets.only(left: 14, right: 6),
          decoration: BoxDecoration(
            color: AppColores.fondo,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.notifications_active_rounded,
                color: AppColores.acento,
                size: 20,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Recordatorio',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColores.textoFuerte,
                  ),
                ),
              ),
              Switch(
                value: evento.aviso,
                activeTrackColor: AppColores.acento,
                onChanged: (_) => estado.alternarAviso(evento),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _Boton(
                texto: 'Eliminar',
                icono: Icons.delete_outline_rounded,
                color: AppColores.rosa,
                contorno: true,
                onTap: onEliminar,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Boton(
                texto: 'Ver en calendario',
                icono: Icons.calendar_month_rounded,
                color: AppColores.acento,
                onTap: onVer,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Agregar un evento
// ---------------------------------------------------------------------------

void mostrarAgregarEvento(BuildContext context) {
  _abrirHoja(context, const _FormularioEvento());
}

class _FormularioEvento extends StatefulWidget {
  const _FormularioEvento();

  @override
  State<_FormularioEvento> createState() => _FormularioEventoState();
}

class _FormularioEventoState extends State<_FormularioEvento> {
  final _titulo = TextEditingController();
  TimeOfDay _hora = const TimeOfDay(hour: 9, minute: 0);
  Categoria _categoria = Categorias.trabajo;
  bool _error = false;

  @override
  void dispose() {
    _titulo.dispose();
    super.dispose();
  }

  Future<void> _elegirHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _hora,
      helpText: 'Elige la hora',
      cancelText: 'Cancelar',
      confirmText: 'Listo',
      hourLabelText: 'Hora',
      minuteLabelText: 'Minuto',
      errorInvalidText: 'Hora no válida',
    );
    if (hora != null) setState(() => _hora = hora);
  }

  void _guardar() {
    final texto = _titulo.text.trim();
    if (texto.isEmpty) {
      setState(() => _error = true);
      return;
    }
    final estado = EstadoScope.leer(context);
    final messenger = ScaffoldMessenger.of(context);
    estado.agregar(
      titulo: texto,
      fecha: estado.seleccionado,
      hora: _hora,
      categoria: _categoria,
    );
    Navigator.pop(context);
    mostrarMensaje(
      messenger,
      'Evento agregado el ${Fechas.fechaLarga(estado.seleccionado).toLowerCase()}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = EstadoScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nuevo evento',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: AppColores.textoFuerte,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.event_rounded, size: 15, color: AppColores.acento),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                Fechas.fechaLarga(estado.seleccionado),
                style: const TextStyle(
                  color: AppColores.textoSuave,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        // Título
        TextField(
          controller: _titulo,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) {
            if (_error) setState(() => _error = false);
          },
          onSubmitted: (_) => _guardar(),
          decoration: InputDecoration(
            hintText: 'Título del evento',
            errorText: _error ? 'Escribe un título' : null,
            prefixIcon: const Icon(
              Icons.edit_rounded,
              color: AppColores.acento,
            ),
            filled: true,
            fillColor: AppColores.fondo,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColores.acento,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Hora
        Pulsable(
          escalaHover: 1.01,
          onTap: _elegirHora,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColores.fondo,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, color: AppColores.acento),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    Fechas.hora(_hora),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColores.textoFuerte,
                    ),
                  ),
                ),
                const Text(
                  'Cambiar',
                  style: TextStyle(
                    color: AppColores.acento,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Categoría',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColores.textoFuerte,
          ),
        ),
        const SizedBox(height: 10),
        // Selector de categoría
        Row(
          children: [
            for (final c in Categorias.todas) ...[
              Expanded(
                child: Pulsable(
                  onTap: () => setState(() => _categoria = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _categoria == c
                          ? c.color
                          : c.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          c.icono,
                          size: 20,
                          color: _categoria == c ? Colors.white : c.color,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c.nombre,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: _categoria == c ? Colors.white : c.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (c != Categorias.todas.last) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 22),
        _Boton(
          texto: 'Guardar evento',
          icono: Icons.check_rounded,
          color: AppColores.acento,
          onTap: _guardar,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Piezas pequeñas reutilizadas
// ---------------------------------------------------------------------------

class _FilaDato extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _FilaDato({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icono, size: 19, color: AppColores.textoSuave),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 15.5,
                color: AppColores.textoFuerte,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String texto;
  final Color color;
  const _Chip({required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _Boton extends StatelessWidget {
  final String texto;
  final IconData icono;
  final Color color;
  final bool contorno;
  final VoidCallback onTap;

  const _Boton({
    required this.texto,
    required this.icono,
    required this.color,
    required this.onTap,
    this.contorno = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorTexto = contorno ? color : Colors.white;
    return Pulsable(
      escalaHover: 1.02,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: contorno
              ? null
              : LinearGradient(colors: [color.withValues(alpha: 0.8), color]),
          border: contorno ? Border.all(color: color, width: 1.5) : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: contorno
              ? null
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, color: colorTexto, size: 19),
              const SizedBox(width: 8),
              Text(
                texto,
                style: TextStyle(
                  color: colorTexto,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
