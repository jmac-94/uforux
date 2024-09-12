# uforuxpi3

A new Flutter project for PI3 (DEMO MODE FINALIST - UNIVERSIDAD DE INGENIERIA Y TECNOLOGIA)

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Software

- Flutter y dart.
- Emulador de un móvil para correr la aplicación.
- VSC, android studio o xcode.

## División de carpetas
...


## Buenas prácticas

### Idioma

Escribir todo el código en inglés, excepto los comentarios que van en español.

### Imports

Esta es la división que deben tener los imports, ordenados según su tipo de import. Notar que cada sección está separada por una linea vacía.

```dart
// Built-in dart libraries
import 'dart:io';
...

// External libraries
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_core/firebase_core.dart';
...

// Project libraries/files
import 'app/app.dart';
...
```

### Convenciones de nombres/Naming conventions

- Clases: PascalCase. Ej: `class MyClass`

- Funciones: camelCase. Ej: `void myFunction`

- Variables: camelCase. Ej: `int myVariable`

### Screens y widgets

Notar que una screen es una pantalla principal que contiene widgets entonces con el fin de hacer nuestro código escalable en el archivo del screen correspondiente deberá ir solo la lógica principal a la pantalla/clase correspondiente y todo lo demás deberá ir en widgets (archivos dentro de la carpeta widgets) que usará la pantalla principal.

### Pantallas/Screens con Widgets y Controllers

#### Widgets

Es importante entender que una pantalla (`screen`) es una entidad principal que contiene `widgets`. Para mantener nuestro código escalable y fácil de entender, debemos modularizarlo. Esto significa que en el archivo de la `screen` correspondiente, solo debería ir la lógica principal que pertenece a esa pantalla o clase.

Todo lo demás, como componentes pequeños de interfaz de usuario, subpantallas, widgets auxiliares, etc., deberán ir en la carpeta `widgets`. De esta manera, cada `screen` principal utilizará estos `widgets` para construir su interfaz y funcionalidad.

#### Controllers

Una `screen` deberá usar controllers para su lógica de backend. Cabe aclarar que es posible tener funciones dentro de la misma pantalla para facilitar la escritura esta conexión en el método build.

### Cantidad de líneas de un archivo

Si un archivo tiene más de 150 líneas aproximadamente revisar si alguna parte se puede separar en otros archivos (modularizar).
