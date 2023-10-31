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
