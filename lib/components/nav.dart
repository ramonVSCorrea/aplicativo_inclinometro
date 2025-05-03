import 'package:aplicativo_inclinometro/views/admindashboard_page.dart';
import 'package:aplicativo_inclinometro/views/dashboards_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aplicativo_inclinometro/views/profile_page.dart';
import 'package:aplicativo_inclinometro/views/home_page.dart';
import 'package:aplicativo_inclinometro/views/settings_page.dart';
import 'package:aplicativo_inclinometro/views/lockangle_page.dart';

class Nav extends StatefulWidget {
  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> {
  int? userId;
  int _indiceAtual = 0;
  final List<Widget> _telas = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    _setupScreens();
  }

  void _setupScreens() {
    setState(() {
      _telas.addAll([
        AdminDashboard(),
        DashboardsPage(),
        SettingsPage()
      ]);
    });
  }

  void onTabTapped(int index) {
    setState(() {
      _indiceAtual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _telas.isNotEmpty
          ? (_indiceAtual < _telas.length ? _telas[_indiceAtual] : _telas[0])
          : Container(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAtual,
        selectedItemColor: const Color(0xFFFF4200),
        //backgroundColor: Color.fromARGB(255, 43, 43, 43),
        unselectedItemColor: Colors.black,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Inicio"
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: "Dashboards"
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Configurações",
          ),
        ],
      ),
    );
  }
}
