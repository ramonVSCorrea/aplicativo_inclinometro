// ignore_for_file: unused_import

import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';

import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplicativo_inclinometro/components/bluetooth_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConnectPage extends StatefulWidget {
  @override
  _ConnectPage createState() => _ConnectPage();
}

class _ConnectPage extends State<ConnectPage> {

  @override
  void initState() {
    super.initState();
    _getBondedDevices();
    //loadConnectedDevice();
  }

  Future<void> _getBondedDevices() async {
    List<BluetoothDevice> bondedDevices =
        await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {
      discoveryResults = bondedDevices.map((device) {
        return BluetoothDiscoveryResult(
          device: device,
          rssi: -55,
        );
      }).toList();
    });
  }

  @override
  void dispose() {
    // Garante que a descoberta é cancelada quando o widget é descartado
    if (isDiscovering) {
      FlutterBluetoothSerial.instance.cancelDiscovery();
    }
    super.dispose();
  }

  Future<void> _startDiscovery() async {
    setState(() {
      isDiscovering = true;
      discoveryResults = [];
    });

    // Inicia a descoberta e armazena o fluxo de resultados
    final discovery = FlutterBluetoothSerial.instance.startDiscovery();

    // Escuta os resultados da descoberta
    discovery.listen((result) {
      setState(() {
        // Adiciona apenas se o dispositivo ainda não estiver na lista
        if (!discoveryResults.any((r) => r.device.address == result.device.address)) {
          discoveryResults.add(result);
        }
      });
    }, onDone: () {
      // Quando a descoberta terminar naturalmente
      setState(() {
        isDiscovering = false;
      });
    }, onError: (error) {
      print("Erro na descoberta: $error");
      setState(() {
        isDiscovering = false;
      });
    });

    // Configura um timer para encerrar a descoberta após 30 segundos
    await Future.delayed(Duration(seconds: 30));

    if (isDiscovering) {
      // Se ainda estiver descobrindo após 30 segundos, cancela a descoberta
      FlutterBluetoothSerial.instance.cancelDiscovery();

      setState(() {
        isDiscovering = false;
      });
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    // Verificar se o usuário atual é um operador ou administrador
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Mostrar diálogo de progresso enquanto verifica o tipo de usuário
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Verificando permissões..."),
              ],
            ),
          );
        },
      );

      try {
        // Obter o documento do usuário no Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        // Fecha o diálogo de verificação
        Navigator.of(context).pop();

        // Se o documento não existe ou não tem o campo userType, não autoriza
        if (!userDoc.exists || !userDoc.data().toString().contains('userType')) {
          showAccessDeniedDialog("Perfil de usuário não configurado corretamente");
          return;
        }

        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String userType = userData['userType'] ?? 'operator';

        // Se o usuário é um operador, verificar o nome do dispositivo
        if (userType == 'operator') {
          // Verifica se o nome do dispositivo segue o padrão "IncliMax - XXXX"
          RegExp incliMaxPattern = RegExp(r'^IncliMax - (\d{4})$');
          final match = device.name != null ? incliMaxPattern.firstMatch(device.name!) : null;

          if (match == null) {
            showAccessDeniedDialog("Você só pode se conectar a dispositivos IncliMax (IncliMax - XXXX)");
            return;
          }

          String sensorId = match.group(1)!;

          // Verificar se o sensor está na lista de sensores autorizados do operador
          bool isAuthorized = false;

          // Verificar se o ID está no campo 'sensorId'
          if (userData.containsKey('sensorId')) {
            var sensorIds = userData['sensorId'];

            if (sensorIds is List) {
              isAuthorized = sensorIds.contains(sensorId);
            } else if (sensorIds is Map) {
              isAuthorized = sensorIds.containsKey(sensorId);
            }
          }

          // Se não estiver autorizado, verificar também no campo 'sensors' (caso exista)
          if (!isAuthorized && userData.containsKey('sensors')) {
            var sensors = userData['sensors'];

            if (sensors is List) {
              isAuthorized = sensors.contains(sensorId);
            } else if (sensors is Map) {
              isAuthorized = sensors.containsKey(sensorId);
            }
          }

          if (!isAuthorized) {
            showAccessDeniedDialog("O sensor $sensorId não está associado à sua conta");
            return;
          }
        }
        // Para administradores, não há verificação adicional - podem conectar a qualquer dispositivo

        // Prosseguir com a conexão
        connectBluetoothDevice(device);

      } catch (e) {
        // Fecha o diálogo de verificação se ainda estiver aberto
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        showAccessDeniedDialog("Erro ao verificar permissões: ${e.toString()}");
        print("Erro ao verificar permissões: $e");
        return;
      }
    } else {
      // Usuário não está autenticado
      showAccessDeniedDialog("Você precisa estar logado para conectar dispositivos");
      return;
    }
  }

  void showAccessDeniedDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.block,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              SizedBox(height: 15),
              Text(
                "Acesso negado",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.red[700],
                ),
              ),
              SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFF07300),
                  minimumSize: Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

  void connectBluetoothDevice(BluetoothDevice device) async {
    // Mostrar diálogo de progresso de conexão
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Conectando a ${device.name ?? 'dispositivo'}..."),
            ],
          ),
        );
      },
    );

    try {
      // Tentativa de conexão
      connection = await BluetoothConnection.toAddress(device.address);

      // Fechar o diálogo de progresso
      Navigator.of(context).pop();

      // Se chegou aqui, a conexão foi bem-sucedida
      setState(() {
        connectedDevice = device;
        connected = true;
      });

      // Salvar dispositivo e iniciar comunicação
      isRunning = true;
      comunicBluetooth();
      saveConnectedDevice(device);

      // Mostrar diálogo de sucesso
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 40,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "Conectado",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.green[700],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Conectado com sucesso a ${device.name ?? 'dispositivo'}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFF07300),
                    minimumSize: Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          );
        },
      );
    } catch (error) {
      // Fechar o diálogo de progresso
      Navigator.of(context).pop();

      // Mostrar diálogo de erro
      showDialog(
        context: context,
        builder: (BuildContext context) {
          String errorMessage = error.toString();
          String simplifiedMessage;

          if (errorMessage.contains('timed out')) {
            simplifiedMessage = "Tempo esgotado ao tentar conectar";
          } else if (errorMessage.contains('rejected')) {
            simplifiedMessage = "Conexão rejeitada pelo dispositivo";
          } else {
            simplifiedMessage = "Não foi possível conectar ao dispositivo";
          }

          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "Erro",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.red[700],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  simplifiedMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFF07300),
                    minimumSize: Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          );
        },
      );

      print('Erro de conexão: $error');
    }
  }

  void saveConnectedDevice(BluetoothDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('connectedDeviceName', device.name ?? '');
    prefs.setString('connectedDeviceAddress', device.address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Definindo cor de fundo do Scaffold
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar personalizada com título centralizado
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Colors.white, // Mantendo a cor de fundo branca
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão de voltar
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Color(0xFFFF4200), size: 28),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  // Título centralizado
                  Text(
                    'Conectar Sensor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Color(0xFFFF4200),
                    ),
                  ),
                  // Espaço vazio para manter o título centralizado
                  SizedBox(width: 28),
                ],
              ),
            ),

            // Resto do conteúdo da página
            Expanded(
              child: Container(
                color: Colors.white, // Mantendo consistente com o Scaffold
                child: Column(
                  children: <Widget>[
                    _buildStatusCard(),
                    _buildSearchButton(),
                    Expanded(
                      child: _buildDevicesList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Status da Conexão",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: connectedDevice != null ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  connectedDevice != null
                      ? "Conectado a: ${connectedDevice!.name ?? 'Dispositivo'}"
                      : "Nenhum dispositivo conectado",
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: isDiscovering ? null : _startDiscovery,
        icon: isDiscovering
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Icon(Icons.search, color: Colors.white),
        label: Text(
          isDiscovering ? 'Buscando...' : 'Buscar Dispositivos',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDiscovering ? Colors.grey : const Color(0xFFFF4200),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildDevicesList() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dispositivos Disponíveis",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          discoveryResults.isEmpty
              ? _buildEmptyDevicesList()
              : Expanded(
            child: ListView.builder(
              itemCount: discoveryResults.length,
              itemBuilder: (context, index) {
                final result = discoveryResults[index];
                final device = result.device;
                return _buildDeviceCard(device);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDevicesList() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_disabled,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "Nenhum dispositivo encontrado",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Toque em 'Buscar Dispositivos' para iniciar",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(BluetoothDevice device) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, 3), // Sombra apenas para baixo
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _connectToDevice(device);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Ícone de Bluetooth
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4200).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                      Icons.bluetooth,
                      color: const Color(0xFFFF4200)
                  ),
                ),
                SizedBox(width: 16),
                // Informações do dispositivo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name ?? 'Dispositivo sem nome',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        device.address,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: device.isBonded
                              ? const Color(0xFF0055AA).withOpacity(0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          device.isBonded ? "Pareado" : "Disponível",
                          style: TextStyle(
                            fontSize: 10,
                            color: device.isBonded ? const Color(0xFF0055AA) : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Ícone de seta
                Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: const Color(0xFFFF4200)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
