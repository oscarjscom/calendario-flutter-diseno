import 'package:flutter/material.dart';

/// Hace tocable cualquier widget con cursor de mano,
/// un leve aumento al pasar el mouse y un "hundimiento" al presionar.
class Pulsable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double escalaHover;
  final String? tooltip;

  const Pulsable({
    super.key,
    required this.child,
    this.onTap,
    this.escalaHover = 1.04,
    this.tooltip,
  });

  @override
  State<Pulsable> createState() => _PulsableState();
}

class _PulsableState extends State<Pulsable> {
  bool _hover = false;
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    final activo = widget.onTap != null;
    final escala = !activo
        ? 1.0
        : _presionado
        ? 0.93
        : _hover
        ? widget.escalaHover
        : 1.0;

    Widget resultado = MouseRegion(
      cursor: activo ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: activo ? (_) => setState(() => _presionado = true) : null,
        onTapUp: activo ? (_) => setState(() => _presionado = false) : null,
        onTapCancel: activo ? () => setState(() => _presionado = false) : null,
        child: AnimatedScale(
          scale: escala,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );

    if (widget.tooltip != null) {
      resultado = Tooltip(message: widget.tooltip!, child: resultado);
    }
    return resultado;
  }
}
