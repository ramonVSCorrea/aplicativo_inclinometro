import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/views/login_page.dart';
import 'package:aplicativo_inclinometro/views/signup_page.dart';
import 'package:aplicativo_inclinometro/views/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicativo Inclinometro',
      theme: ThemeData(),
      initialRoute: '/home',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => SignupPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
