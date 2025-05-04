import 'dart:typed_data';

import 'package:aplicativo_inclinometro/components/create_custom_container.dart';
import 'package:aplicativo_inclinometro/components/custom_button.dart';
import 'package:aplicativo_inclinometro/components/nav.dart';
import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class LockAnglePage extends StatefulWidget {
  @override
  _LockAnglePageState createState() => _LockAnglePageState();
}

class _LockAnglePageState extends State<LockAnglePage> {
  final _lateralController = TextEditingController();
  final _frontalController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLateralExpanded = false;
  bool _isFrontalExpanded = false;

  @override
  void initState() {
    super.initState();
    sendingMSG = true;
    _lateralController.text = BloqueioLateral.toStringAsFixed(2);
    _frontalController.text = BloqueioFrontal.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _lateralController.dispose();
    _frontalController.dispose();
    sendingMSG = false;
    super.dispose();
  }

  double BloqueioLateral = bloqueioLateral;
  double BloqueioFrontal = bloqueioFrontal;

  void sendMessage() async {
    String msgBT =
        '{"configuracoesBLQ":{"bloqueioLateral": ${bloqueioLateral.toStringAsFixed(2)},"bloqueioFrontal": ${bloqueioFrontal.toStringAsFixed(2)}}}';

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

  void _updateLateralFromText(String text) {
    final value = double.tryParse(text);
    if (value != null && value >= 0 && value <= 8.0) {
      setState(() {
        BloqueioLateral = value;
      });
    }
  }

  void _updateFrontalFromText(String text) {
    final value = double.tryParse(text);
    if (value != null && value >= 0 && value <= 10.0) {
      setState(() {
        BloqueioFrontal = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Form(
        key: _formKey,
        child: SafeArea(
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
                      'Ângulo de Bloqueio',
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
                    children: <Widget>[
                      // Card do Bloqueio Lateral
                      _buildExpandableCard(
                        title: "Bloqueio Lateral",
                        subtitle: "Limite máximo para inclinação lateral",
                        value: BloqueioLateral,
                        isExpanded: _isLateralExpanded,
                        minValue: 0.0,
                        maxValue: 8.0,
                        icon: Icons.sync_alt,
                        controller: _lateralController,
                        onChanged: _updateLateralFromText,
                        onSliderChanged: (value) {
                          setState(() {
                            BloqueioLateral = value;
                            _lateralController.text = value.toStringAsFixed(2);
                          });
                        },
                        onExpansionChanged: (bool expanded) {
                          setState(() {
                            _isLateralExpanded = expanded;
                          });
                        },
                        truckImageIndex: 1,
                      ),

                      SizedBox(height: 16),

                      // Card do Bloqueio Frontal
                      _buildExpandableCard(
                        title: "Bloqueio Frontal",
                        subtitle: "Limite máximo para inclinação frontal",
                        value: BloqueioFrontal,
                        isExpanded: _isFrontalExpanded,
                        minValue: 0.0,
                        maxValue: 10.0,
                        icon: Icons.rotate_right,
                        controller: _frontalController,
                        onChanged: _updateFrontalFromText,
                        onSliderChanged: (value) {
                          setState(() {
                            BloqueioFrontal = value;
                            _frontalController.text = value.toStringAsFixed(2);
                          });
                        },
                        onExpansionChanged: (bool expanded) {
                          setState(() {
                            _isFrontalExpanded = expanded;
                          });
                        },
                        truckImageIndex: 2,
                      ),

                      SizedBox(height: 30),

                      // Botão de salvar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: CustomButton(
                          label: "Salvar Configurações",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              bloqueioLateral = BloqueioLateral;
                              bloqueioFrontal = BloqueioFrontal;
                              sendMessage();
                              _showSavedDialog();
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required String subtitle,
    required double value,
    required bool isExpanded,
    required double minValue,
    required double maxValue,
    required IconData icon,
    required TextEditingController controller,
    required Function(String) onChanged,
    required Function(double) onSliderChanged,
    required Function(bool) onExpansionChanged,
    required int truckImageIndex,
  }) {
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
                color: Color(0xFFFF4200).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${value.toStringAsFixed(2)}°",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF4200),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(),
              SizedBox(height: 8),

              // Limites mínimo e máximo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Limites: ${minValue.toStringAsFixed(1)}° - ${maxValue.toStringAsFixed(1)}°",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Campo de edição e valor
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Valor atual:",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Color(0xFFFF4200),
                      ),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(
                        suffix: Text('°'),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFFFF4200)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFFFF4200)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFFFF4200), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Obrigatório';
                        }
                        final num = double.tryParse(value);
                        if (num == null) {
                          return 'Valor inválido';
                        }
                        if (num < minValue || num > maxValue) {
                          return 'Entre $minValue e $maxValue°';
                        }
                        return null;
                      },
                      onChanged: onChanged,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Slider
              Slider(
                min: minValue,
                max: maxValue,
                activeColor: Color(0xFFFF4200),
                inactiveColor: Color(0xFFFF4200).withOpacity(0.3),
                value: value,
                divisions: (maxValue * 10).toInt(),
                label: value.toStringAsFixed(2) + '°',
                onChanged: onSliderChanged,
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

  void _showSavedDialog() {
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
                "Valores Salvos",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                    ),
                  ],
                  border: Border.all(
                    color: Color(0xFFFF4200).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.sync_alt, color: Color(0xFFFF4200)),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bloqueio Lateral",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "${bloqueioLateral.toStringAsFixed(2)}°",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF4200),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                    ),
                  ],
                  border: Border.all(
                    color: Color(0xFFFF4200).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.rotate_right, color: Color(0xFFFF4200)),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bloqueio Frontal",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "${bloqueioFrontal.toStringAsFixed(2)}°",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF4200),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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