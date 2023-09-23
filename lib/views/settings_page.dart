import 'package:aplicativo_inclinometro/views/home_page.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget{
  @override
  _SettingsPage createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage>{


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
        backgroundColor: const Color(0xFFF07300),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.bluetooth, color: Color(0xFFF07300)),
            title: Text('Conectar Sensor'),
            subtitle: Text('Faça conexão de algum sensor via Bluetooth'),
            onTap: (){
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => HomePage()),
              // );
            },
          ),

          ListTile(
            leading: Icon(Icons.lock, color: Color(0xFFF07300)),
            title: Text('Ângulos de Bloqueio'),
            subtitle: Text('Ajuste dos ângulos de bloqueio'),
            onTap: (){

            },
          ),

          ListTile(
            leading: Icon(Icons.adjust, color: Color(0xFFF07300)),
            title: Text('Calibrar Sensor'),
            subtitle: Text('Calibre o sensor para melhor ajuste'),
            onTap: (){

            },
          ),

          ListTile(
            leading: Icon(Icons.event, color: Color(0xFFF07300)),
            title: Text('Eventos'),
            subtitle: Text('Lista de eventos registrados'),
            onTap: (){

            },
          ),
        ],
      )
    );
  }
}
