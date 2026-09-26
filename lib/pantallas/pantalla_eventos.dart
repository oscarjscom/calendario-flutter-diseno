import 'package:flutter/material.dart';

import '../estado/estado_calendario.dart';
import '../modelos/evento.dart';
import '../tema/colores.dart';
import '../utils/fechas.dart';
import '../widgets/encabezado.dart';
import '../widgets/lista_eventos.dart';
import '../widgets/pulsable.dart';
import '../widgets/vidrio.dart';
import 'pagina_base.dart';

/// Todos los eventos, con búsqueda y filtro por categoría.
class PantallaEventos extends StatefulWidget {
  const PantallaEventos({super.key});

  @override
  State<PantallaEventos> createState() => _PantallaEventosState();
}

class _PantallaEventosState extends State<PantallaEventos> {
  String _busqueda = '';
  Categoria? _categoria;

  @override
  Widget build(BuildContext context) {
    final estado = EstadoScope.of(context);
    final eventos = estado.eventos
        .where((e) => _categoria == null || e.categoria == _categoria)
        .where((e) => e.titulo.toLowerCase().contains(_busqueda.toLowerCase()))
        .toList();

    // Agrupa por mes
    final grupos = <DateTime, List<Evento>>{};
    for (final e in eventos) {
      grupos
          .putIfAbsent(DateTime(e.fecha.year, e.fecha.month), () => [])
          .add(e);
    }

    return PaginaBase(
      encabezado: Encabezado(
        titulo: 'Mis eventos',
        subtitulo: '${estado.eventos.length} eventos guardados',
        iconoSubtitulo: Icons.event_note_rounded,
      ),
      children: [
        // Buscador
        Vidrio(
          radio: BorderRadius.circular(20),
          sombra: [
            BoxShadow(
              color: AppColores.acento.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
          child: TextField(
            onChanged: (v) => setState(() => _busqueda = v),
            decoration: const InputDecoration(
              hintText: 'Buscar evento...',
              prefixIcon: Icon(Icons.search_rounded, color: AppColores.acento),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Filtros por categoría
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _ChipFiltro(
                texto: 'Todos',
                color: AppColores.acento,
                activo: _categoria == null,
                onTap: () => setState(() => _categoria = null),
              ),
              for (final c in Categorias.todas)
                _ChipFiltro(
                  texto: c.nombre,
                  color: c.color,
                  icono: c.icono,
                  activo: _categoria == c,
                  onTap: () =>
                      setState(() => _categoria = _categoria == c ? null : c),
                ),
            ],
          ),
        ),
        if (eventos.isEmpty) ...[
          const SizedBox(height: 20),
          const EstadoVacio(
            icono: Icons.search_off_rounded,
            titulo: 'No se encontraron eventos',
            texto: 'Prueba con otra búsqueda o categoría',
          ),
        ],
        for (final grupo in grupos.entries) ...[
          TituloSeccion(Fechas.mesAnio(grupo.key)),
          for (final e in grupo.value)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TarjetaEvento(evento: e),
            ),
        ],
      ],
    );
  }
}

class _ChipFiltro extends StatelessWidget {
  final String texto;
  final Color color;
  final IconData? icono;
  final bool activo;
  final VoidCallback onTap;

  const _ChipFiltro({
    required this.texto,
    required this.color,
    required this.activo,
    required this.onTap,
    this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Pulsable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: activo ? color : AppColores.tarjeta,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: activo ? 1 : 0.3),
            ),
          ),
          child: Row(
            children: [
              if (icono != null) ...[
                Icon(icono, size: 15, color: activo ? Colors.white : color),
                const SizedBox(width: 6),
              ],
              Text(
                texto,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: activo ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
