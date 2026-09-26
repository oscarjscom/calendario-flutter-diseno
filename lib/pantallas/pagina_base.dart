import 'package:flutter/material.dart';

import '../tema/colores.dart';
import '../widgets/encabezado.dart';

/// Estructura común de cada pantalla: paisaje arriba y
/// contenido que sube un poco sobre él.
class PaginaBase extends StatelessWidget {
  final Encabezado encabezado;
  final List<Widget> children;

  const PaginaBase({
    super.key,
    required this.encabezado,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 110),
      child: Column(
        children: [
          encabezado,
          Transform.translate(
            offset: const Offset(0, -40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Título de sección usado en varias pantallas.
class TituloSeccion extends StatelessWidget {
  final String texto;
  const TituloSeccion(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w800,
          color: AppColores.textoFuerte,
        ),
      ),
    );
  }
}
