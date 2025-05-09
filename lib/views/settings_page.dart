import 'package:aplicativo_inclinometro/components/adminsidebar.dart';
import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:aplicativo_inclinometro/views/calibratesensor.dart';
import 'package:aplicativo_inclinometro/views/connect_page.dart';
import 'package:aplicativo_inclinometro/views/events_page.dart';
import 'package:aplicativo_inclinometro/views/lockangle_page.dart';
import 'package:aplicativo_inclinometro/views/remote_config_page.dart';
import 'package:aplicativo_inclinometro/views/wifi_config_page.dart';
import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/components/nav.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

import '../components/sideBar.dart';
import 'home_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPage createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  Future<void> requestBluetoothPermissions() async {
    final Map<Permission, PermissionStatus> status = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise
    ].request();

    if (status[Permission.bluetooth]!.isGranted) {
      print('bluetooth permitido');
      if (status[Permission.bluetoothConnect]!.isGranted) {
        print('bluetoothConnect permitido');
        if (status[Permission.bluetoothScan]!.isGranted) {
          print('bluetoothScan permitido');
          if (status[Permission.bluetoothAdvertise]!.isGranted) {
            print('bluetoothAdvertise permitido');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usando o BluetoothProvider para verificar se há dispositivo conectado
    final bool isDeviceConnected = connected;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: SideBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Barra de título personalizada sem botão de voltar
            // Barra superior com logo e menu
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, color: Color(0xFFFF4200), size: 28),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Configurações',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  // Espaço vazio para equilibrar o layout
                  SizedBox(width: 48),
                ],
              ),
            ),

            // Conteúdo da página
            Expanded(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Configurações do Dispositivo",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),
                        // Adicione este novo item na lista de configurações em settings_page.dart
                        _buildSettingCard(
                          icon: Icons.cloud_sync,
                          title: 'Configuração Remota',
                          subtitle: 'Configure seus dispositivos de forma remota',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RemoteConfigPage()),
                            );
                          },
                          isEnabled: true,
                        ),
                        _buildSettingCard(
                          icon: Icons.bluetooth,
                          title: 'Conectar Sensor',
                          subtitle: 'Faça conexão de algum sensor via Bluetooth',
                          onTap: () {
                            requestBluetoothPermissions();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ConnectPage()),
                            );
                          },
                          isEnabled: true,
                        ),
                        _buildSettingCard(
                          icon: Icons.lock,
                          title: 'Ângulos de Bloqueio',
                          subtitle: isDeviceConnected
                              ? 'Ajuste dos ângulos de bloqueio'
                              : 'Conecte um dispositivo para acessar',
                          onTap: () {
                            if (isDeviceConnected) {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => LockAnglePage()));
                            } else {
                              _showConnectDeviceDialog(context);
                            }
                          },
                          isEnabled: isDeviceConnected,
                        ),
                        _buildSettingCard(
                          icon: Icons.adjust,
                          title: 'Calibrar Sensor',
                          subtitle: isDeviceConnected
                              ? 'Calibre o sensor para melhor ajuste'
                              : 'Conecte um dispositivo para acessar',
                          onTap: () {
                            if (isDeviceConnected) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CalibrateSensorPage()));
                            } else {
                              _showConnectDeviceDialog(context);
                            }
                          },
                          isEnabled: isDeviceConnected,
                        ),

                        _buildSettingCard(
                          icon: Icons.wifi,
                          title: 'Rede Wi-Fi',
                          subtitle: isDeviceConnected
                              ? 'Altere a rede Wi-Fi do seu inclinômetro'
                              : 'Conecte um dispositivo para acessar',
                          onTap: () {
                            if (isDeviceConnected) {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => WiFiConfigPage()));
                            } else {
                              _showConnectDeviceDialog(context);
                            }
                          },
                          isEnabled: isDeviceConnected,
                        ),

                        _buildSettingCard(
                          icon: Icons.construction,  // Ícone de ferramentas/construção
                          title: 'Comandar Inclinômetro',
                          subtitle: isDeviceConnected
                              ? 'Faça os comandos de operador em um dispositivo'
                              : 'Conecte um dispositivo para acessar',
                          onTap: () {
                            if (isDeviceConnected) {
                              // Navegue para a tela de comando quando estiver implementada
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => ControlPage()));
                              // Por enquanto, exibe um diálogo informando que está em desenvolvimento
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomePage(isAdminMode: true))
                              );
                            } else {
                              _showConnectDeviceDialog(context);
                            }
                          },
                          isEnabled: isDeviceConnected,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog para mostrar quando não há dispositivo conectado
  void _showConnectDeviceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Dispositivo não conectado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Color(0xFFFF4200),
            ),
          ),
          content: Text(
            'É necessário conectar um sensor antes de acessar esta função.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                requestBluetoothPermissions();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConnectPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF4200),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Conectar',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 8),
          titlePadding: EdgeInsets.fromLTRB(24, 16, 24, 8),
          backgroundColor: Colors.white,
          elevation: 10,
        );
      },
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, 3),
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
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Opacity(
              opacity: isEnabled ? 1.0 : 0.5,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFFFF4200).withOpacity(isEnabled ? 0.1 : 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Color(0xFFFF4200),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFFFF4200),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}