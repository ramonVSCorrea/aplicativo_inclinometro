import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:aplicativo_inclinometro/views/settings_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:influxdb_client/api.dart';
import 'package:intl/intl.dart';

import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  void initState(){
    super.initState();
    getEvents();
    const duration = Duration(milliseconds: 1);
    Timer.periodic(duration, (Timer timer) {
      setState(() {});
    });
  }

  void sendMessage() async {
    String msgBT;

    msgBT = '{"totalEventos": 1}';

    if(connection == null){
      print('Conexão Bluetooth não estabelecida');
      return;
    }

    try {
      connection!.output.add(Uint8List.fromList(msgBT.codeUnits));
      await connection!.output.allSent;
      print('Mensagem enviada: $msgBT');
    } catch (ex) {
      print('Erro ao enviar mensagem: $ex');
    }
  }

  void sendMessageLerEvento(int numEvento) async {
    String msgBT;

    msgBT = '{"numEvento": $numEvento}\n';

    if(connection == null){
      print('Conexão Bluetooth não estabelecida');
      return;
    }

    try {
      connection!.output.add(Uint8List.fromList(msgBT.codeUnits));
      await connection!.output.allSent;
      print('Mensagem enviada: $msgBT');
    } catch (ex) {
      print('Erro ao enviar mensagem: $ex');
    }

  }

  void lerEvento(int numEvento) async{
    int tentativas = 0;
    bool flagMsg = true;
    int cont = 0;

    while(flagMsg && tentativas < 500){
      sendMessageLerEvento(numEvento);
      while(true){
        if(requestLerEvento){
          flagMsg = false;
          requestLerEvento = false;
          break;
        }
        await Future.delayed(Duration(milliseconds: 100));
        cont++;
        if(cont == 300){
          cont = 0;
          break;
        }
      }
      tentativas++;
    }
  }


  void getEvents() async{
      int tentativas = 0;
      bool flagMsg = true;
      int cont = 0;
      requestLeitura = false;

      while(flagMsg && tentativas < 500){
        sendMessage();
        while(true){
          if(requestTotalEventos){
            flagMsg = false;
            requestTotalEventos = false;
            break;
          }
          await Future.delayed(Duration(milliseconds: 100));
          cont++;
          if(cont == 300){
            cont = 0;
            break;
          }
        }
        tentativas++;
      }
      print('Total eventos: $totalEventos');


      for(int i = totalEventos - eventos.length; i > 1; i--){
        if(i == 0)
          break;
        print('Enviando evt $i');
        lerEvento(i);
        await Future.delayed(Duration(milliseconds: 500));
      }

      //print('Total eventos: $totalEventos');

      requestLeitura = true;
  }

  Future<void> salvarEventosEmCSV() async {
    String csvContent = 'Data,Hora,TipoEvento,AngLat,AngFront\n';

    for (Evento evento in eventos) {
      csvContent +=
      '${evento.data},${evento.hora},${evento.tipoEvento},${evento.angLat},${evento.angFront}\n';
    }

    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath != null) {
      final Directory directory = Directory(directoryPath);
      final String fileName = 'eventos.csv';
      final String filePath = '${directory.path}/$fileName';

      File file = File(filePath);
      await file.writeAsString(csvContent);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eventos salvos em $filePath'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nenhum diretório selecionado'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos'),
        backgroundColor: Color.fromARGB(255, 43, 43, 43),
      ),
      body: ListView.builder(
        itemCount: eventos.length,
        itemBuilder: (context, index){
          return ListTile(
            title: Text(eventos[index].tipoEvento),
            subtitle: Text(
              'Data: ${eventos[index].data}\nHora: ${eventos[index].hora}\nÂngulo Lateral: ${eventos[index].angLat}\nÂngulo Frontal: ${eventos[index].angFront}',
            ),
          );
        },
        // Seu conteúdo ListView aqui
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          salvarEventosEmCSV();
        },
        tooltip: 'Salvar Eventos em CSV',
        child: Icon(Icons.download),
        backgroundColor: const Color(0xFFF07300),
      ),
    );
  }
}
