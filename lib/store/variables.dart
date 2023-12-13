import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

double anguloLateral = 0;
double anguloFrontal = 0;

double bloqueioLateral = 0;
double bloqueioFrontal = 0;

double calibracaoLateral = 0;
double calibracaoFrontal = 0;

bool sendingMSG = false;
bool connected = false;

BluetoothConnection? connection;
BluetoothConnection? activeConnections;

bool requestLeitura = false;
bool requestTotalEventos = false;

int totalEventos = 0;

bool requestLerEvento = false;
bool requestMovimentaBascula = false;
bool flagParaLeitura = false;


class Evento {
  String data;
  String hora;
  String tipoEvento;
  String angLat;
  String angFront;

  Evento({
    required this.data,
    required this.hora,
    required this.tipoEvento,
    required this.angLat,
    required this.angFront,
  });
}

List<Evento> eventos = [];

String? errorSignUp;

