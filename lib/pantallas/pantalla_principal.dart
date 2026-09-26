import 'dart:ui';

import 'package:flutter/material.dart';

import '../estado/estado_calendario.dart';
import '../tema/colores.dart';
import '../widgets/avatar.dart';
import '../widgets/barra_inferior.dart';
import '../widgets/encabezado.dart' show usarImagenDeFondo;
import '../widgets/hojas.dart';
import '../widgets/vidrio.dart' show usarVidrio;
import 'pantalla_avisos.dart';
import 'pantalla_calendario.dart';
import 'pantalla_eventos.dart';
import 'pantalla_perfil.dart';

/// Contenedor con menú lateral, barra inferior y cambio animado de pantalla.
class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  static const _pantallas = [
    PantallaCalendario(),
    PantallaEventos(),
    PantallaAvisos(),
    PantallaPerfil(),
  ];

  @override
  Widget build(BuildContext context) {
    final estado = EstadoScope.of(context);

    return Scaffold(
      extendBody: true,
      drawer: const _MenuLateral(),
      body: Stack(
        // Ocupa toda la pantalla aunque el contenido sea corto
        fit: StackFit.expand,
        children: [
          if (usarFondoDegradado)
            const Positioned.fill(child: _FondoDegradado()),
          _contenido(estado),
        ],
      ),
      bottomNavigationBar: const BarraInferior(),
    );
  }

  Widget _contenido(EstadoCalendario estado) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      // La pantalla anterior desaparece al instante para no mezclarse
      switchOutCurve: const Threshold(0.999),
      // Cada pantalla ocupa todo el alto (sin centrarse si es corta)
      layoutBuilder: (actual, anteriores) =>
          Stack(fit: StackFit.expand, children: [...anteriores, ?actual]),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey(estado.pestana),
        child: _pantallas[estado.pestana],
      ),
    );
  }
}

/// true = imagen de nebulosa detrás del contenido; false = color lila liso.
const usarFondoDegradado = true;

/// Imagen de fondo con una capa clara encima para que los textos oscuros se lean.
class _FondoDegradado extends StatelessWidget {
  const _FondoDegradado();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/fondo_degradado.jpg',
          fit: BoxFit.cover,
          alignment: const Alignment(0, 0.4),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColores.fondo.withValues(alpha: 0.80),
                AppColores.fondo.withValues(alpha: 0.62),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuLateral extends StatelessWidget {
  const _MenuLateral();

  @override
  Widget build(BuildContext context) {
    final estado = EstadoScope.of(context);

    void ir(int pestana) {
      Navigator.pop(context);
      estado.cambiarPestana(pestana);
    }

    const radio = BorderRadius.horizontal(right: Radius.circular(28));

    return Drawer(
      backgroundColor: usarVidrio ? Colors.transparent : AppColores.tarjeta,
      elevation: 0,
      width: 280,
      shape: const RoundedRectangleBorder(borderRadius: radio),
      clipBehavior: Clip.antiAlias,
      child: _CuerpoMenu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera del menú: misma imagen que el encabezado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 50, 22, 22),
              decoration: BoxDecoration(
                image: usarImagenDeFondo
                    ? DecorationImage(
                        image: const AssetImage('assets/fondo.jpg'),
                        fit: BoxFit.cover,
                        alignment: const Alignment(0, -0.1),
                        // Capa oscura para que el texto blanco se lea bien
                        colorFilter: ColorFilter.mode(
                          AppColores.cieloAlto.withValues(alpha: 0.45),
                          BlendMode.srcATop,
                        ),
                      )
                    : null,
                gradient: usarImagenDeFondo
                    ? null
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColores.cieloAlto,
                          AppColores.cieloMedio,
                          AppColores.cieloBajo,
                        ],
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColores.sol, AppColores.cieloBajo],
                      ),
                    ),
                    child: const AvatarUsuario(radio: 26),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    estado.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${estado.eventos.length} eventos en tu agenda',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _OpcionMenu(
              Icons.calendar_month_rounded,
              'Calendario',
              estado.pestana == 0,
              () => ir(0),
            ),
            _OpcionMenu(
              Icons.event_note_rounded,
              'Mis eventos',
              estado.pestana == 1,
              () => ir(1),
            ),
            _OpcionMenu(
              Icons.notifications_rounded,
              'Avisos',
              estado.pestana == 2,
              () => ir(2),
            ),
            _OpcionMenu(
              Icons.person_rounded,
              'Perfil',
              estado.pestana == 3,
              () => ir(3),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: Divider(),
            ),
            _OpcionMenu(Icons.today_rounded, 'Ir a hoy', false, () {
              Navigator.pop(context);
              estado.irAHoy();
            }),
            _OpcionMenu(
              Icons.add_circle_outline_rounded,
              'Nuevo evento',
              false,
              () {
                Navigator.pop(context);
                mostrarAgregarEvento(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Fondo del menú: vidrio esmerilado (o blanco si [usarVidrio] es false).
class _CuerpoMenu extends StatelessWidget {
  final Widget child;
  const _CuerpoMenu({required this.child});

  @override
  Widget build(BuildContext context) {
    if (!usarVidrio) return child;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.80),
              Colors.white.withValues(alpha: 0.62),
            ],
          ),
          border: Border(
            right: BorderSide(
              color: Colors.white.withValues(alpha: 0.75),
              width: 1.2,
            ),
          ),
        ),
        child: SizedBox.expand(child: child),
      ),
    );
  }
}

class _OpcionMenu extends StatelessWidget {
  final IconData icono;
  final String texto;
  final bool activo;
  final VoidCallback onTap;

  const _OpcionMenu(this.icono, this.texto, this.activo, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        onTap: onTap,
        selected: activo,
        selectedTileColor: AppColores.acento.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(
          icono,
          color: activo ? AppColores.acento : AppColores.textoSuave,
        ),
        title: Text(
          texto,
          style: TextStyle(
            fontWeight: activo ? FontWeight.w800 : FontWeight.w600,
            color: activo ? AppColores.acento : AppColores.textoFuerte,
          ),
        ),
      ),
    );
  }
}
