import 'package:aplicativo_inclinometro/components/nav.dart';
import 'package:aplicativo_inclinometro/database/db.dart';
import 'package:aplicativo_inclinometro/views/LockAngle_page.dart';
import 'package:aplicativo_inclinometro/views/calibratesensor.dart';
import 'package:aplicativo_inclinometro/views/connect_page.dart';
import 'package:aplicativo_inclinometro/views/forget_password_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/views/login_page.dart';
import 'package:aplicativo_inclinometro/views/signup_page.dart';
import 'package:aplicativo_inclinometro/views/home_page.dart';
import 'package:aplicativo_inclinometro/views/settings_page.dart';
// import 'package:aplicativo_inclinometro/views/allusers_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyB_nQb49r7Z-U1rFXwVXs5_MB1AdeSP3L8",
      appId: "1:102427336976:android:b6afa5ac92a3f0a8df4595",
      messagingSenderId: "102427336976",
      projectId: "inclimax-55c91",
    ),
  );

  await DB.instance.database;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
        '/lockangle': (context) => LockAnglePage(),
        '/calibratesensor': (context) => CalibrateSensorPage(),
        '/resetPassword': (context) => ForgetPasswordPage(),
        // '/alluser': (context) => AllUsersPage(),
      },
    );
  }
}
