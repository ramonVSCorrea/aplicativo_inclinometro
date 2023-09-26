import 'package:aplicativo_inclinometro/views/settings_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  String _data = '';
  String _hora = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getDataHora());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _getDataHora() {
    final dataHora = DateTime.now();
    final data = "${dataHora.day}/${dataHora.month}/${dataHora.year}";
    final hora = "${dataHora.hour}:${dataHora.minute}:${dataHora.second}";

    setState(() {
      _data = 'Data: $data';
      _hora = 'Hora: $hora';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela de Eventos'),
        backgroundColor: Color.fromARGB(255, 43, 43, 43),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => SettingsPage()));
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Eventos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF07300),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _data,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            Text(
              _hora,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 200,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 240, 0, 0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Evento: BLOQUEIO',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: 200,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFF07300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Ângulo Lateral: 2,5°',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: 200,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFF07300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Ângulo Frontal: 8,2°',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
