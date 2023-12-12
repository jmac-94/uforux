import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:forux/app/models/app_user.dart';
import 'package:forux/app/controllers/authentication_controller.dart';
import 'package:forux/core/theme_class.dart';
import 'package:forux/core/utils/const.dart';
import 'package:forux/app/screens/wrapper.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// StreamProvider se utiliza aquí para crear un flujo de datos reactivos en la aplicación.
    /// En este caso, estamos proporcionando un objeto AppUser (o null) en toda la aplicación.
    /// El StreamProvider escucha los cambios en el estado de autenticación del usuario a través
    /// tal que cuando el estado del usuario cambia StreamProvider actualiza automáticamente los widgets
    /// que dependen de esta información en la UI.
    return StreamProvider<AppUser?>.value(
      value: AuthenticationController().user,
      initialData: null,
      child: MaterialApp(
        title: Constants.appName,
        theme: ThemeClass.lightTheme,
        darkTheme: ThemeClass.darkTheme,
        themeMode: ThemeMode.light,
        home: const Wrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
