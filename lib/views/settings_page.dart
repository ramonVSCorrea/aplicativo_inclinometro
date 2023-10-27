import 'package:aplicativo_inclinometro/views/calibratesensor.dart';
import 'package:aplicativo_inclinometro/views/connect_page.dart';
import 'package:aplicativo_inclinometro/views/events_page.dart';
import 'package:aplicativo_inclinometro/views/lockangle_page.dart';
import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/components/nav.dart';
import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPage createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
        backgroundColor: Color.fromARGB(255, 43, 43, 43),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Nav()));
            }),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.bluetooth, color: Color(0xFFF07300)),
            title: Text('Conectar Sensor'),
            subtitle: Text('Faça conexão de algum sensor via Bluetooth'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConnectPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.lock, color: Color(0xFFF07300)),
            title: Text('Ângulos de Bloqueio'),
            subtitle: Text('Ajuste dos ângulos de bloqueio'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LockAnglePage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.adjust, color: Color(0xFFF07300)),
            title: Text('Calibrar Sensor'),
            subtitle: Text('Calibre o sensor para melhor ajuste'),
            onTap: () async{
              // final statusConnect = await Permission.bluetoothConnect.request();
              // final statusScan = await Permission.bluetoothScan.request();
              // final statusBlue = await Permission.bluetooth.request();
              // final statusAdver = await Permission.bluetoothAdvertise.request();
              // final statusLocation = await Permission.location.request();

              //if(statusConnect.isGranted && statusScan.isGranted && statusBlue.isGranted && statusAdver.isGranted && statusLocation.isGranted)  {
                //print('permissões aceitas');
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CalibrateSensorPage()));
              //}
            },
          ),
          ListTile(
            leading: Icon(Icons.event, color: Color(0xFFF07300)),
            title: Text('Eventos'),
            subtitle: Text('Lista de eventos registrados'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => EventsPage()));
            },
          ),
        ],
      ),
    );
  }
}
