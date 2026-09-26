import 'package:flutter/material.dart';

import '../estado/estado_calendario.dart';
import '../tema/colores.dart';
import 'avatar.dart';
import 'pulsable.dart';

/// true = usa assets/fondo.jpg; false = paisaje dibujado con CustomPaint.
const usarImagenDeFondo = true;

/// Encabezado con paisaje de atardecer y título.
/// Si recibe [onAnterior]/[onSiguiente] muestra las flechas de navegación.
class Encabezado extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData iconoSubtitulo;
  final VoidCallback? onAnterior;
  final VoidCallback? onSiguiente;
  final VoidCallback? onTitulo;

  const Encabezado({
    super.key,
    required this.titulo,
    required this.subtitulo,
    this.iconoSubtitulo = Icons.wb_twilight_rounded,
    this.onAnterior,
    this.onSiguiente,
    this.onTitulo,
  });

  @override
  Widget build(BuildContext context) {
    final estado = EstadoScope.of(context);

    return SizedBox(
      height: 270,
      child: Stack(
        children: [
          // Fondo: imagen o paisaje dibujado (cambiar [usarImagenDeFondo] para alternar)
          if (usarImagenDeFondo) ...[
            Positioned.fill(
              child: Image.asset(
                'assets/fondo.jpg',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.1),
              ),
            ),
            // Capa oscura para que el texto blanco se lea bien
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColores.cieloAlto.withValues(alpha: 0.65),
                      AppColores.cieloAlto.withValues(alpha: 0.25),
                      AppColores.cieloAlto.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
            ),
          ] else
            const Positioned.fill(
              child: CustomPaint(painter: _PaisajePainter()),
            ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  // Fila superior: menú + saludo + avatar
                  Row(
                    children: [
                      _BotonVidrio(
                        icono: Icons.menu_rounded,
                        tooltip: 'Menú',
                        onTap: () => Scaffold.of(context).openDrawer(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola, ${estado.nombre}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 14,
                              ),
                            ),
                            const Text(
                              'Mi agenda',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Pulsable(
                        tooltip: 'Mi perfil',
                        escalaHover: 1.08,
                        onTap: () => estado.cambiarPestana(3),
                        child: const _Avatar(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  // Fila del título: flecha + título + flecha
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      onAnterior != null
                          ? _BotonVidrio(
                              icono: Icons.chevron_left_rounded,
                              tooltip: 'Mes anterior',
                              onTap: onAnterior,
                            )
                          : const SizedBox(width: 42),
                      Expanded(
                        child: Pulsable(
                          onTap: onTitulo,
                          escalaHover: 1.02,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Column(
                                key: ValueKey('$titulo|$subtitulo'),
                                children: [
                                  Text(
                                    titulo,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        iconoSubtitulo,
                                        size: 15,
                                        color: AppColores.sol.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        subtitulo,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      onSiguiente != null
                          ? _BotonVidrio(
                              icono: Icons.chevron_right_rounded,
                              tooltip: 'Mes siguiente',
                              onTap: onSiguiente,
                            )
                          : const SizedBox(width: 42),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón redondo semitransparente (efecto vidrio).
class _BotonVidrio extends StatelessWidget {
  final IconData icono;
  final String tooltip;
  final VoidCallback? onTap;

  const _BotonVidrio({required this.icono, required this.tooltip, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pulsable(
      tooltip: tooltip,
      escalaHover: 1.08,
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Icon(icono, color: Colors.white, size: 24),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColores.sol, AppColores.cieloBajo],
        ),
      ),
      child: const AvatarUsuario(radio: 19),
    );
  }
}

/// Dibuja el paisaje del encabezado.
class _PaisajePainter extends CustomPainter {
  const _PaisajePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Cielo degradado
    final cielo = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColores.cieloAlto,
          AppColores.cieloMedio,
          AppColores.cieloBajo,
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, cielo);

    // Estrellas
    final estrella = Paint()..color = Colors.white.withValues(alpha: 0.7);
    const puntos = [
      Offset(0.08, 0.10),
      Offset(0.22, 0.30),
      Offset(0.35, 0.08),
      Offset(0.52, 0.22),
      Offset(0.66, 0.06),
      Offset(0.78, 0.28),
      Offset(0.92, 0.14),
      Offset(0.14, 0.45),
      Offset(0.86, 0.42),
    ];
    for (final p in puntos) {
      canvas.drawCircle(Offset(p.dx * w, p.dy * h), 1.3, estrella);
    }

    // Sol con halo
    final centroSol = Offset(w * 0.74, h * 0.60);
    canvas.drawCircle(
      centroSol,
      60,
      Paint()..color = AppColores.sol.withValues(alpha: 0.18),
    );
    canvas.drawCircle(centroSol, 28, Paint()..color = AppColores.sol);

    // Tres capas de montañas
    _montana(canvas, size, AppColores.montanaLejana.withValues(alpha: 0.75), [
      0.0,
      0.62,
      0.15,
      0.48,
      0.32,
      0.66,
      0.5,
      0.52,
      0.7,
      0.70,
      0.88,
      0.50,
      1.0,
      0.64,
    ]);
    _montana(canvas, size, AppColores.montanaMedia, [
      0.0,
      0.72,
      0.2,
      0.60,
      0.38,
      0.80,
      0.58,
      0.64,
      0.8,
      0.82,
      1.0,
      0.66,
    ]);
    _montana(canvas, size, AppColores.montanaCercana, [
      0.0,
      0.84,
      0.25,
      0.76,
      0.5,
      0.88,
      0.75,
      0.78,
      1.0,
      0.86,
    ]);
  }

  /// [picos] es una lista plana de pares (x, y) relativos al tamaño.
  void _montana(Canvas canvas, Size size, Color color, List<double> picos) {
    final path = Path()..moveTo(0, size.height);
    for (var i = 0; i < picos.length; i += 2) {
      path.lineTo(picos[i] * size.width, picos[i + 1] * size.height);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
