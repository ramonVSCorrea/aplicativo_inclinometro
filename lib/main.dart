import 'package:aplicativo_inclinometro/components/nav.dart';
import 'package:aplicativo_inclinometro/views/LockAngle_page.dart';
import 'package:aplicativo_inclinometro/views/calibratesensor.dart';
import 'package:aplicativo_inclinometro/views/connect_page.dart';
import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/views/login_page.dart';
import 'package:aplicativo_inclinometro/views/signup_page.dart';
import 'package:aplicativo_inclinometro/views/home_page.dart';
import 'package:aplicativo_inclinometro/views/settings_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicativo Inclinometro',
      theme: ThemeData(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => SignupPage(),
        '/home': (context) => HomePage(),
        '/settings': (context) => SettingsPage(),
        '/connect': (context) => ConnectPage(),
        '/nav': (context) => Nav(),
        '/lockangle':(context) => LockAnglePage(),
        '/calibratesensor':(context) => CalibrateSensorPage(),
      },
    );
  }
}
