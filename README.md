# Calendario Flutter – Diseño

Laboratorio de Flutter: diseño visual de un calendario construido principalmente con `Row` y `Column`.

Muestra **Septiembre 2026** con su cuadrícula, eventos de colores por categoría y el **día de hoy destacado**, con un estilo propio de tarjetas de vidrio (glassmorphism) sobre imágenes de fondo.

## Características

- **Mes y año** en un encabezado con imagen de fondo, flechas para cambiar de mes y saludo con foto de perfil.
- **Cuadrícula del mes** hecha con una `Column` de semanas y una `Row` de 7 días. Cada día es una baldosa con barritas de color, una por evento.
- **Día destacado (Hoy)** con degradado y la **semana actual resaltada**.
- **Eventos por categoría**: Trabajo, Estudio, Personal y Proyecto, cada una con su color e ícono.
- **Leyenda** que también funciona como filtro.
- **Tarjetas de resumen**: eventos del mes, avance y días que quedan.
- **4 pantallas**: Calendario, Mis eventos (con buscador), Avisos y Perfil.
- **Menú lateral**, formulario para **agregar eventos** y detalle de cada evento.
- Tipografía **Poppins**, paleta de colores propia y tarjetas de **vidrio esmerilado**.

## Cómo ejecutarlo

Requisitos: [Flutter](https://docs.flutter.dev/get-started/install) 3.35 o superior.

```bash
flutter pub get
flutter run -d chrome
```

> **Nota (Windows):** si la ruta del proyecto tiene caracteres como `ñ` o tildes, la compilación web puede fallar. Clona el repositorio en una carpeta con una ruta simple, por ejemplo `C:\proyectos\calendario-flutter-diseno`.

Pruebas:

```bash
flutter test
```

## Estructura

```
lib/
├── main.dart                 # App y marco de celular para el navegador
├── tema/colores.dart         # Paleta de colores
├── modelos/evento.dart       # Evento y categorías
├── utils/fechas.dart         # Nombres de meses/días y formato de hora en español
├── estado/                   # Estado compartido (mes visible, día seleccionado, eventos)
├── widgets/                  # Encabezado, calendario, tarjetas, vidrio, barra inferior...
└── pantallas/                # Calendario, Mis eventos, Avisos, Perfil y menú
assets/
├── fondo.jpg, fondo_degradado.jpg, perfil.jpg
└── fonts/                    # Poppins (licencia OFL)
```

## Créditos

- Tipografía [Poppins](https://fonts.google.com/specimen/Poppins), bajo la licencia SIL Open Font License.
