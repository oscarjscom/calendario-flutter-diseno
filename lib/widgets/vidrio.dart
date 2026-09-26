import 'dart:ui';

import 'package:flutter/material.dart';

import '../tema/colores.dart';

/// true = tarjetas con efecto de vidrio esmerilado (glassmorphism);
/// false = tarjetas blancas sólidas (diseño original).
const usarVidrio = true;

/// Tarjeta base de la app. Según [usarVidrio] se dibuja como vidrio
/// (blanco translúcido + desenfoque del fondo) o como tarjeta blanca.
class Vidrio extends StatelessWidget {
  final Widget child;
  final BorderRadius radio;
  final EdgeInsetsGeometry? padding;

  /// Borde propio de la tarjeta (si no se indica, en vidrio se usa un canto blanco).
  final Color? colorBorde;
  final double anchoBorde;
  final List<BoxShadow>? sombra;

  const Vidrio({
    super.key,
    required this.child,
    required this.radio,
    this.padding,
    this.colorBorde,
    this.anchoBorde = 1.2,
    this.sombra,
  });

  @override
  Widget build(BuildContext context) {
    if (!usarVidrio) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: padding,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColores.tarjeta,
          borderRadius: radio,
          border: colorBorde == null
              ? null
              : Border.all(color: colorBorde!, width: anchoBorde),
          boxShadow: sombra,
        ),
        child: child,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      // Sombra suave por fuera del vidrio
      decoration: BoxDecoration(
        borderRadius: radio,
        boxShadow: sombra
            ?.map(
              (s) => BoxShadow(
                color: s.color.withValues(alpha: s.color.a * 0.6),
                blurRadius: s.blurRadius,
                offset: s.offset,
              ),
            )
            .toList(),
      ),
      child: ClipRRect(
        borderRadius: radio,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radio,
              // Brillo diagonal: más blanco arriba a la izquierda
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.78),
                  Colors.white.withValues(alpha: 0.58),
                ],
              ),
              border: Border.all(
                color: colorBorde ?? Colors.white.withValues(alpha: 0.75),
                width: anchoBorde,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
