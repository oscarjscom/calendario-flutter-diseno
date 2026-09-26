import 'package:flutter/material.dart';

import '../estado/estado_calendario.dart';
import '../modelos/evento.dart';
import '../tema/colores.dart';
import '../widgets/avatar.dart';
import '../widgets/encabezado.dart';
import '../widgets/pulsable.dart';
import '../widgets/vidrio.dart';
import 'pagina_base.dart';

/// Perfil del usuario: estadísticas y preferencias.
class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key});

  Future<void> _editarNombre(
    BuildContext context,
    EstadoCalendario estado,
  ) async {
    final controlador = TextEditingController(text: estado.nombre);
    final nuevo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Tu nombre'),
        content: TextField(
          controller: controlador,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (v) => Navigator.pop(ctx, v),
          decoration: const InputDecoration(hintText: 'Escribe tu nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controlador.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (nuevo != null) estado.cambiarNombre(nuevo);
  }

  @override
  Widget build(BuildContext context) {
    final estado = EstadoScope.of(context);
    final eventos = estado.eventos;
    final conAviso = eventos.where((e) => e.aviso).length;
    final maximo = Categorias.todas
        .map((c) => eventos.where((e) => e.categoria == c).length)
        .fold<int>(1, (a, b) => a > b ? a : b);

    return PaginaBase(
      encabezado: const Encabezado(
        titulo: 'Mi perfil',
        subtitulo: 'Tus datos y preferencias',
        iconoSubtitulo: Icons.person_rounded,
      ),
      children: [
        // Tarjeta de usuario
        _Tarjeta(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColores.sol, AppColores.cieloBajo],
                      ),
                    ),
                    child: const AvatarUsuario(radio: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          estado.nombre,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: AppColores.textoFuerte,
                          ),
                        ),
                        const Text(
                          'Estudiante · Laboratorio Flutter',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColores.textoSuave,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Pulsable(
                    tooltip: 'Editar nombre',
                    escalaHover: 1.1,
                    onTap: () => _editarNombre(context, estado),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColores.acento.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: AppColores.acento,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _Dato(valor: '${eventos.length}', etiqueta: 'Eventos'),
                  _Dato(
                    valor: '${estado.proximos.length}',
                    etiqueta: 'Próximos',
                  ),
                  _Dato(valor: '$conAviso', etiqueta: 'Con aviso'),
                ],
              ),
            ],
          ),
        ),
        const TituloSeccion('Eventos por categoría'),
        _Tarjeta(
          child: Column(
            children: [
              for (final c in Categorias.todas)
                _BarraCategoria(
                  categoria: c,
                  cantidad: eventos.where((e) => e.categoria == c).length,
                  maximo: maximo,
                ),
            ],
          ),
        ),
        const TituloSeccion('Preferencias'),
        _Tarjeta(
          child: Column(
            children: [
              _Opcion(
                icono: Icons.weekend_rounded,
                texto: 'Resaltar fines de semana',
                valor: estado.resaltarFinDeSemana,
                onChanged: estado.cambiarResaltarFinDeSemana,
              ),
              _Opcion(
                icono: Icons.notifications_rounded,
                texto: 'Notificaciones',
                valor: estado.notificaciones,
                onChanged: estado.cambiarNotificaciones,
              ),
              Pulsable(
                escalaHover: 1.01,
                onTap: estado.irAHoy,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.today_rounded,
                        color: AppColores.acento,
                        size: 21,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ir al día de hoy',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColores.textoFuerte,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColores.textoSuave,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tarjeta extends StatelessWidget {
  final Widget child;
  const _Tarjeta({required this.child});

  @override
  Widget build(BuildContext context) {
    return Vidrio(
      padding: const EdgeInsets.all(18),
      radio: BorderRadius.circular(24),
      sombra: [
        BoxShadow(
          color: AppColores.acento.withValues(alpha: 0.10),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
      child: child,
    );
  }
}

class _Dato extends StatelessWidget {
  final String valor;
  final String etiqueta;
  const _Dato({required this.valor, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColores.fondo,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              valor,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppColores.acento,
              ),
            ),
            Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 12,
                color: AppColores.textoSuave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarraCategoria extends StatelessWidget {
  final Categoria categoria;
  final int cantidad;
  final int maximo;

  const _BarraCategoria({
    required this.categoria,
    required this.cantidad,
    required this.maximo,
  });

  @override
  Widget build(BuildContext context) {
    final c = categoria.color;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(categoria.icono, size: 19, color: c),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(
              categoria.nombre,
              style: const TextStyle(
                fontSize: 14,
                color: AppColores.textoFuerte,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: cantidad / maximo),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (_, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 9,
                  color: c,
                  backgroundColor: c.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$cantidad',
            style: TextStyle(fontWeight: FontWeight.w800, color: c),
          ),
        ],
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  final IconData icono;
  final String texto;
  final bool valor;
  final ValueChanged<bool> onChanged;

  const _Opcion({
    required this.icono,
    required this.texto,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: AppColores.acento, size: 21),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColores.textoFuerte,
            ),
          ),
        ),
        Switch(
          value: valor,
          activeTrackColor: AppColores.acento,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
