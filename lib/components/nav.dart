import 'package:aplicativo_inclinometro/views/connect_page.dart';
import 'package:aplicativo_inclinometro/views/home_page.dart';
import 'package:aplicativo_inclinometro/views/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/bottom_navigation_bar.dart';

class Nav extends StatefulWidget{
  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav>{
  int _indiceAtual = 0;
  final List<Widget> _telas = [
    HomePage(),
    ConnectPage(), //Alterar para profilePage quando estiver pronto
    SettingsPage()
  ];

  void onTabTapped(int index){
    setState(() {
      _indiceAtual = index;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: _telas[_indiceAtual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAtual,
        selectedItemColor: const Color(0xFFF07300),
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings")
        ],
      ),
    );
  }
}
