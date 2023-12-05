import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:uforuxpi3/app/models/app_user.dart';
import 'package:uforuxpi3/app/controllers/authentication_controller.dart';
import 'package:uforuxpi3/core/theme_class.dart';
import 'package:uforuxpi3/core/utils/const.dart';
import 'package:uforuxpi3/app/screens/wrapper.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
