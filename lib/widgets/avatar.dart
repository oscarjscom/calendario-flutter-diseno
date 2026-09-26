import 'package:flutter/material.dart';

import '../estado/estado_calendario.dart';
import '../tema/colores.dart';

/// true = usa assets/perfil.jpg; false = círculo con la inicial del nombre.
const usarFotoPerfil = true;

/// Círculo con la foto de perfil (o la inicial si no se usa foto).
class AvatarUsuario extends StatelessWidget {
  final double radio;
  final Color colorFondo;

  const AvatarUsuario({
    super.key,
    required this.radio,
    this.colorFondo = AppColores.cieloMedio,
  });

  @override
  Widget build(BuildContext context) {
    final estado = EstadoScope.of(context);

    return CircleAvatar(
      radius: radio,
      backgroundColor: colorFondo,
      backgroundImage: usarFotoPerfil
          ? const AssetImage('assets/perfil.jpg')
          : null,
      child: usarFotoPerfil
          ? null
          : Text(
              estado.nombre[0].toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: radio * 0.9,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}
