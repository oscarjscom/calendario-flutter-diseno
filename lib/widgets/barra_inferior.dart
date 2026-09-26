import 'package:flutter/material.dart';

import '../estado/estado_calendario.dart';
import '../tema/colores.dart';
import 'hojas.dart';
import 'pulsable.dart';

/// Barra de navegación inferior entre las 4 pantallas.
class BarraInferior extends StatelessWidget {
  const BarraInferior({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = EstadoScope.of(context);
    final avisosPendientes = estado.notificaciones
        ? estado.proximos.where((e) => e.aviso).length
        : 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColores.cieloAlto,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColores.cieloAlto.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ItemBarra(
            icono: Icons.calendar_month_rounded,
            texto: 'Calendario',
            indice: 0,
          ),
          _ItemBarra(
            icono: Icons.event_note_rounded,
            texto: 'Eventos',
            indice: 1,
          ),
          Pulsable(
            tooltip: 'Nuevo evento',
            escalaHover: 1.1,
            onTap: () => mostrarAgregarEvento(context),
            child: const _BotonAgregar(),
          ),
          _ItemBarra(
            icono: Icons.notifications_none_rounded,
            texto: 'Avisos',
            indice: 2,
            insignia: avisosPendientes,
          ),
          _ItemBarra(
            icono: Icons.person_outline_rounded,
            texto: 'Perfil',
            indice: 3,
          ),
        ],
      ),
    );
  }
}

class _ItemBarra extends StatelessWidget {
  final IconData icono;
  final String texto;
  final int indice;
  final int insignia;

  const _ItemBarra({
    required this.icono,
    required this.texto,
    required this.indice,
    this.insignia = 0,
  });

  @override
  Widget build(BuildContext context) {
    final estado = EstadoScope.of(context);
    final activo = estado.pestana == indice;
    final color = activo ? Colors.white : Colors.white.withValues(alpha: 0.5);

    return Expanded(
      child: Pulsable(
        escalaHover: 1.08,
        onTap: () => estado.cambiarPestana(indice),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icono, color: color, size: 23),
                  // Contador de avisos pendientes
                  if (insignia > 0)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColores.cieloBajo,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColores.cieloAlto,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          '$insignia',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11.5,
                  color: color,
                  fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(texto),
              ),
              const SizedBox(height: 3),
              // Indicador del elemento activo
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: activo ? 16 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColores.sol,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotonAgregar extends StatelessWidget {
  const _BotonAgregar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColores.cieloBajo, AppColores.acento],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColores.cieloBajo.withValues(alpha: 0.5),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
    );
  }
}
