# Proyecto_TDA
Proyecto del Curso DAM 2º
lib/
│
├── BaseDeDatos/
│   ├── DatabaseHelper.dart
│   └── record_model.dart
│
├── BotonesExtrax/
│   ├── Favoritos.dart
│   └── RecordsMenuScreen.dart
│
├── Game/
│   ├── Juego1.dart
│   ├── Juego2.dart
│   ├── Juego3.dart
│   ├── Juego4.dart
│   ├── Juego5.dart
│   ├── Juego6.dart
│   └── Juego7.dart
│
├── Menus/
│   ├── games_menu_screen.dart
│   └── main_menu_screen.dart
│
├── widgets/
│   └── game_icon_widget.dart
│
└── main.dart


Descripción de Módulos:
BaseDeDatos

Este módulo gestiona toda la lógica relacionada con el almacenamiento y recuperación de datos.

DatabaseHelper.dart
Encargado de la conexión con la base de datos y operaciones CRUD (crear, leer, actualizar, eliminar).
record_model.dart
Define la estructura del modelo de datos utilizado para almacenar los registros.

BotonesExtrax

Contiene funcionalidades adicionales enfocadas en la experiencia del usuario.

Favoritos.dart
Gestiona la funcionalidad de elementos favoritos dentro de la aplicación.
RecordsMenuScreen.dart
Pantalla dedicada a mostrar los récords del usuario.

Game

Este módulo contiene la lógica principal de los juegos.

Cada archivo (Juego1.dart a Juego7.dart) representa un juego independiente, encapsulando su propia lógica y UI.

Menus

Define las pantallas principales de navegación de la aplicación.

main_menu_screen.dart
Pantalla principal desde donde el usuario accede a las distintas funcionalidades.
games_menu_screen.dart
Pantalla que permite seleccionar entre los diferentes juegos disponibles.

widgets

Contiene componentes reutilizables de la interfaz de usuario.

game_icon_widget.dart
Widget personalizado utilizado para representar visualmente los juegos.


main.dart

Punto de entrada de la aplicación.

Inicializa la app.
Configura rutas y navegación.
Define el tema global.
Establece la pantalla inicial.

Pasos necesarios para el funcionamiento de la app. 

-Descargar Android Studio
-Pluggin necesarios: Fluuter y Dart
-Descargar el pluggin de flutter para el pc: https://docs.flutter.dev/packages-and-plugins/developing-packages
-Colocar el archivo descargado en el disco local /C
-Crear un proyecto flutter en Android Studio
-Sustituir la carperta 'lib' y 'pubspec.yaml' del proyecto recien creado.
-Abrir el proyecto en Android Studio y pulsar 'Pub get' 
-Una vez terminado, usar el dispositivo simulado dentro de Android Studio. 