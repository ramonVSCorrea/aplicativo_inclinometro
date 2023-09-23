import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ConnectPage extends StatefulWidget{
  @override
  _ConnectPage createState() => _ConnectPage();
}

class _ConnectPage extends State<ConnectPage>{
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];

  @override
  void initState(){
    super.initState();
    _startScanning();
  }

  void _startScanning(){
    flutterBlue.scanResults.listen((scanResult){
      for(var result in scanResult){
        if(!devices.contains(result.device)){
          setState(() {
            devices.add(result.device);
          });
        }
      }
    });

    flutterBlue.startScan();
  }

  @override
  void dispose(){
    flutterBlue.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Conectar Sensores'),
        backgroundColor: const Color(0xFFF07300),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index){
          return ListTile(
            title: Text(devices[index].name ?? 'Dispositivo desconhecido'),
            subtitle: Text(devices[index].id.toString()),
            onTap: (){

            },
          );
        },
      ),
    );
  }
}