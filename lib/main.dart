import 'package:flutter/material.dart';

import 'estado/estado_calendario.dart';
import 'pantallas/pantalla_principal.dart';
import 'tema/colores.dart';

void main() {
  runApp(const CalendarioApp());
}

class CalendarioApp extends StatefulWidget {
  const CalendarioApp({super.key});

  @override
  State<CalendarioApp> createState() => _CalendarioAppState();
}

class _CalendarioAppState extends State<CalendarioApp> {
  final _estado = EstadoCalendario();

  @override
  void dispose() {
    _estado.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EstadoScope(
      estado: _estado,
      child: MaterialApp(
        title: 'Calendario - Mi agenda',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: AppColores.acento,
          scaffoldBackgroundColor: AppColores.fondo,
          // Tipografía propia para toda la app
          fontFamily: 'Poppins',
        ),
        // El marco envuelve al Navigator para que las hojas y diálogos
        // también aparezcan dentro del "celular".
        builder: (context, child) => MarcoTelefono(child: child!),
        home: const PantallaPrincipal(),
      ),
    );
  }
}

/// En pantallas anchas (navegador) muestra la app dentro de un marco de celular.
class MarcoTelefono extends StatelessWidget {
  final Widget child;
  const MarcoTelefono({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final tamano = MediaQuery.of(context).size;
    if (tamano.width < 500) return child;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEDE9FE), Color(0xFFFFE4E6)],
        ),
      ),
      child: Center(
        child: Container(
          width: 410,
          height: (tamano.height - 40).clamp(600.0, 900.0),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(52),
            boxShadow: [
              BoxShadow(
                color: AppColores.cieloAlto.withValues(alpha: 0.35),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(42),
            // Ajusta el tamaño de pantalla que ven los widgets internos al del marco
            child: LayoutBuilder(
              builder: (context, c) => MediaQuery(
                data: MediaQuery.of(context).copyWith(size: c.biggest),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
