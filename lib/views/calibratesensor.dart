// ignore_for_file: unused_local_variable

import 'package:aplicativo_inclinometro/components/create_custom_container.dart';
import 'package:aplicativo_inclinometro/components/custom_button.dart';
import 'package:aplicativo_inclinometro/components/nav.dart';
import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:typed_data';

class CalibrateSensorPage extends StatefulWidget {
  @override
  _CalibrateSensorPage createState() => _CalibrateSensorPage();
}

class _CalibrateSensorPage extends State<CalibrateSensorPage> {
  bool _isLateralExpanded = true;
  bool _isFrontalExpanded = true;

  @override
  void initState() {
    super.initState();
    sendingMSG = true;
  }

  @override
  void dispose() {
    sendingMSG = false;
    super.dispose();
  }

  void sendMessage(int cmd) async {
    String msgBT = '{"configuraCalib": $cmd}';

    if (connection == null) {
      print('Conexão Bluetooth não estabelecida!');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra superior personalizada
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Color(0xFFFF4200), size: 28),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Calibrar Sensor',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(width: 28),
                ],
              ),
            ),

            // Conteúdo principal
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Card de Calibração Lateral
                    _buildCalibrationCard(
                      title: "Calibração Lateral",
                      subtitle: "Ajuste a calibração do sensor lateral",
                      value: calibracaoLateral,
                      isExpanded: _isLateralExpanded,
                      icon: Icons.sync_alt,
                      truckImageIndex: 1,
                      onExpansionChanged: (bool expanded) {
                        setState(() {
                          _isLateralExpanded = expanded;
                        });
                      },
                    ),

                    SizedBox(height: 16),

                    // Card de Calibração Frontal
                    _buildCalibrationCard(
                      title: "Calibração Frontal",
                      subtitle: "Ajuste a calibração do sensor frontal",
                      value: calibracaoFrontal,
                      isExpanded: _isFrontalExpanded,
                      icon: Icons.rotate_right,
                      truckImageIndex: 2,
                      onExpansionChanged: (bool expanded) {
                        setState(() {
                          _isFrontalExpanded = expanded;
                        });
                      },
                    ),

                    SizedBox(height: 30),

                    // Botões de ação
                    // Modifique os botões de ação assim:
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _buildActionButton(
                              label: "Calibrar Sensor",
                              icon: Icons.settings_outlined,
                              color: Color(0xFF0055AA),
                              onPressed: () {
                                _showConfirmationDialog(
                                  "Calibrar Sensor",
                                  "Esta ação irá definir o ângulo atual do dispositivo como ponto zero de referência. Todos os ângulos serão medidos a partir desta posição.",
                                      () {
                                    sendMessage(1);
                                    calibracaoLateral = anguloLateral;
                                    calibracaoFrontal = anguloFrontal;
                                    _showSuccessDialog("Sensor Calibrado",
                                        "O sensor foi calibrado com sucesso com os valores atuais.");
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: _buildActionButton(
                              label: "Zerar Sensor",
                              icon: Icons.refresh,
                              color: Color(0xFFFF4200),
                              onPressed: () {
                                _showConfirmationDialog(
                                  "Zerar Sensor",
                                  "Esta ação irá restaurar a calibração do sensor para os valores padrão de fábrica. Todos os ajustes personalizados serão perdidos.",
                                      () {
                                    sendMessage(0);
                                    calibracaoLateral = 0;
                                    calibracaoFrontal = 0;
                                    setState(() {});
                                    _showSuccessDialog("Sensor Zerado",
                                        "Os valores de calibração foram restaurados para zero.");
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationCard({
    required String title,
    required String subtitle,
    required double value,
    required bool isExpanded,
    required IconData icon,
    required int truckImageIndex,
    required Function(bool) onExpansionChanged,
  }) {
    // Determina a cor baseada no valor do ângulo
    Color angleColor = Colors.green;
    double absValue = value.abs();
    if (absValue < 1) angleColor = Colors.green;
    else if (absValue < 3) angleColor = Colors.green[700]!;
    else if (absValue < 5) angleColor = Colors.orange;
    else angleColor = Colors.red;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Poppins',
            color: Colors.black54,
          ),
        ),
        leading: Icon(icon, color: Color(0xFFFF4200)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: angleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${value.toStringAsFixed(2)}°",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: angleColor,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.grey,
            ),
          ],
        ),
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpansionChanged,
        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Column(
            children: [
              Divider(),
              SizedBox(height: 16),

              // Valor do ângulo em destaque
              Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: angleColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      "Valor atual",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: angleColor,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "${value.toStringAsFixed(2)}°",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Imagem do caminhão
              Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(80),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: Color(0xFFFF4200),
                      width: 4.0,
                    ),
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: value * (pi / 180),
                      child: Image.asset(
                        'assets/truck$truckImageIndex.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child:
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.help_outline, color: Color(0xFF0055AA)),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontFamily: 'Poppins',
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "CANCELAR",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "CONFIRMAR",
                style: TextStyle(
                  color: Color(0xFFFF4200),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontFamily: 'Poppins',
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "FECHAR",
                style: TextStyle(
                  color: Color(0xFFFF4200),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}