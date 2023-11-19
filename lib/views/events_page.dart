import 'package:aplicativo_inclinometro/views/settings_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:influxdb_client/api.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {

    // void fetchData() async{
    //   var client = InfluxDBClient(
    //     url: 'https://us-east-1-1.aws.cloud2.influxdata.com',
    //     token: 'X0zO3ujnfr20JXsm3HnCaatkWWW0xtf_VG9XRuj33as8Kb-zG1CGRPpfczL0xyNwmXZ2UaS2m65PITWf1ePskA==',
    //     org: '9f389c7f82a02efa',
    //     bucket: 'IncliMax',
    //   );
    //
    //   var queryService = client.getQueryService();
    //   //var fluxQuery = 'from(bucket: "IncliMax") |> range(start: -30d) |> filter(fn: (r) => r["_measurement"] == "Angulos" and (r["AnguloFrontal"] != null or r["AnguloLateral"] != null) and r["device"] == "ESP32")';
    //   var fluxQuery = '''
    //         from(bucket: "IncliMax")
    //           |> range(start: -30d)
    //           |> filter(fn: (r) => r["_measurement"] == "Angulos" and (r["_field"] == "AnguloFrontal" or r["_field"] == "AnguloLateral"))
    //           |> filter(fn: (r) => r["device"] == "ESP32")
    //         ''';
    //
    //   print('\n\n---------------------------------- Query ---------------------------------\n');
    //   var recordStream = await queryService.query(fluxQuery);
    //
    //   print('\n\n------------------------------ Query result ------------------------------\n');
    //
    //   await recordStream.forEach((record) {
    //     if (record['_field'] == 'AnguloLateral') {
    //       print('AnguloLateral: ${record['_value']}');
    //     } else if (record['_field'] == 'AnguloFrontal') {
    //       print('AnguloFrontal: ${record['_value']}');
    //     }
    //   });
    //   client.close();
    // }

  Map<DateTime, Map<String, dynamic>> data = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    var client = InfluxDBClient(
      url: 'https://us-east-1-1.aws.cloud2.influxdata.com',
      token: 'X0zO3ujnfr20JXsm3HnCaatkWWW0xtf_VG9XRuj33as8Kb-zG1CGRPpfczL0xyNwmXZ2UaS2m65PITWf1ePskA==',
      org: '9f389c7f82a02efa',
      bucket: 'IncliMax',
    );

    var queryService = client.getQueryService();
    var fluxQuery = '''
      from(bucket: "IncliMax")
        |> range(start: -30d)
        |> filter(fn: (r) => r["_measurement"] == "Angulos" and (r["_field"] == "AnguloFrontal" or r["_field"] == "AnguloLateral"))
        |> filter(fn: (r) => r["device"] == "ESP32")
      ''';

    var recordStream = await queryService.query(fluxQuery);

    await recordStream.forEach((record) {
      var time = DateTime.parse(record['_time']);
      var field = record['_field'];
      var value = record['_value'];

      if (data[time] == null) {
        data[time] = {};
      }

      data[time]?[field] = value;
    });

    setState(() {});

    client.close();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Angulos'),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          var time = data.keys.elementAt(index);
          var values = data[time];
          return ListTile(
            title: Text('Time: $time'),
            subtitle: Text('AnguloLateral: ${values?['AnguloLateral']}, AnguloFrontal: ${values?['AnguloFrontal']}'),
          );
        },
      ),
    );
  }

  // String _data = '';
  // String _hora = '';
  // Timer? _timer;
  //
  // @override
  // void initState() {
  //   super.initState();
  //   fetchData();
  //   _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getDataHora());
  // }
  //
  // @override
  // void dispose() {
  //   _timer?.cancel();
  //   super.dispose();
  // }
  //
  // void _getDataHora() {
  //   final dataHora = DateTime.now();
  //   final data = "${dataHora.day}/${dataHora.month}/${dataHora.year}";
  //   final hora = "${dataHora.hour}:${dataHora.minute}:${dataHora.second}";
  //
  //   setState(() {
  //     _data = 'Data: $data';
  //     _hora = 'Hora: $hora';
  //   });
  // }
  //
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Tela de Eventos'),
  //       backgroundColor: Color.fromARGB(255, 43, 43, 43),
  //       leading: IconButton(
  //         icon: Icon(Icons.arrow_back),
  //         onPressed: () {
  //           Navigator.pushReplacement(context,
  //               MaterialPageRoute(builder: (context) => SettingsPage()));
  //         },
  //       ),
  //     ),
  //     body: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           Text(
  //             'Eventos',
  //             style: TextStyle(
  //               fontSize: 24,
  //               fontWeight: FontWeight.bold,
  //               color: Color(0xFFF07300),
  //             ),
  //           ),
  //           SizedBox(height: 20),
  //           Text(
  //             _data,
  //             style: TextStyle(
  //               fontSize: 18,
  //               color: Colors.black,
  //             ),
  //           ),
  //           Text(
  //             _hora,
  //             style: TextStyle(
  //               fontSize: 18,
  //               color: Colors.black,
  //             ),
  //           ),
  //           SizedBox(height: 20),
  //           Container(
  //             width: 200,
  //             padding: EdgeInsets.all(10),
  //             decoration: BoxDecoration(
  //               color: Color.fromARGB(255, 240, 0, 0),
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //             child: Text(
  //               'Evento: BLOQUEIO',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 color: Colors.white,
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //           ),
  //           SizedBox(height: 10),
  //           Container(
  //             width: 200,
  //             padding: EdgeInsets.all(10),
  //             decoration: BoxDecoration(
  //               color: Color(0xFFF07300),
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //             child: Text(
  //               'Ângulo Lateral: 2,5°',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 color: Colors.white,
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //           ),
  //           SizedBox(height: 10),
  //           Container(
  //             width: 200,
  //             padding: EdgeInsets.all(10),
  //             decoration: BoxDecoration(
  //               color: Color(0xFFF07300),
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //             child: Text(
  //               'Ângulo Frontal: 8,2°',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 color: Colors.white,
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //           ),
  //           SizedBox(height: 20),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
