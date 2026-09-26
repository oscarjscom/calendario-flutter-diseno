import 'package:flutter/material.dart';

import '../tema/colores.dart';

/// Tipo de evento con su color e ícono.
class Categoria {
  final String nombre;
  final Color color;
  final IconData icono;

  const Categoria(this.nombre, this.color, this.icono);
}

class Categorias {
  static const trabajo = Categoria(
    'Trabajo',
    AppColores.azul,
    Icons.groups_rounded,
  );
  static const estudio = Categoria(
    'Estudio',
    AppColores.rosa,
    Icons.school_rounded,
  );
  static const personal = Categoria(
    'Personal',
    AppColores.naranja,
    Icons.favorite_rounded,
  );
  static const proyecto = Categoria(
    'Proyecto',
    AppColores.verde,
    Icons.insights_rounded,
  );

  static const todas = [trabajo, estudio, personal, proyecto];
}

/// Un evento del calendario.
class Evento {
  final int id;
  final String titulo;
  final DateTime fecha;
  final TimeOfDay hora;
  final Categoria categoria;
  bool aviso;

  Evento({
    required this.id,
    required this.titulo,
    required this.fecha,
    required this.hora,
    required this.categoria,
    this.aviso = true,
  });

  Color get color => categoria.color;
  IconData get icono => categoria.icono;
}
