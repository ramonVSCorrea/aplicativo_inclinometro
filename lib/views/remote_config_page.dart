import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RemoteConfigPage extends StatefulWidget {
  @override
  _RemoteConfigPageState createState() => _RemoteConfigPageState();
}

class _RemoteConfigPageState extends State<RemoteConfigPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para os inputs
  final _lateralController = TextEditingController();
  final _frontalController = TextEditingController();
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variáveis de controle de expansão
  bool _isLateralExpanded = false;
  bool _isFrontalExpanded = false;
  bool _isWiFiExpanded = false;
  bool _obscurePassword = true;

  // Variáveis de valores
  double bloqueioLateral = 4.0;
  double bloqueioFrontal = 4.0;

  // Lista de sensores e seleção
  List<String> sensoresDisponiveis = [];
  Map<String, bool> sensoresSelecionados = {};
  bool selecionarTodos = false;
  bool isLoading = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    _lateralController.text = bloqueioLateral.toStringAsFixed(2);
    _frontalController.text = bloqueioFrontal.toStringAsFixed(2);
    _ssidController.text = ssid;
    _passwordController.text = password;
    _carregarSensores();
  }

  @override
  void dispose() {
    _lateralController.dispose();
    _frontalController.dispose();
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _carregarSensores() async {
    try {
      setState(() {
        isLoading = true;
        erro = null;
      });

      List<String> sensores = await buscarSensoresUnicos();

      setState(() {
        sensoresDisponiveis = sensores;
        // Inicializa o Map de seleção com todos os sensores como não selecionados
        for (var sensor in sensores) {
          sensoresSelecionados[sensor] = false;
        }
        isLoading = false;
      });

      print("Sensores carregados com sucesso: ${sensoresDisponiveis.length}");
    } catch (e) {
      setState(() {
        erro = e.toString();
        isLoading = false;
      });
      print("Erro ao carregar sensores: $e");
      _showErrorDialog("Erro ao carregar sensores: $e");
    }
  }

  Future<List<String>> buscarSensoresUnicos() async {
    // Usamos um Set para garantir que não teremos valores duplicados
    Set<String> sensoresUnicos = {};

    try {
      // Obter o ID do administrador atual
      String adminUid = FirebaseAuth.instance.currentUser!.uid;

      // Obter a empresa do administrador
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(adminUid)
          .get();

      if (!adminDoc.exists) {
        throw Exception("Dados do administrador não encontrados");
      }

      String company = adminDoc.get('company') ?? '';
      print("Empresa do administrador: $company");

      // Buscar todos os operadores desta empresa
      QuerySnapshot operadoresSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('company', isEqualTo: company)
          .where('userType', isEqualTo: 'operator')
          .get();

      print("Total de operadores encontrados: ${operadoresSnapshot.docs.length}");

      // Para cada operador, recuperar seus sensores e adicionar ao Set
      for (var doc in operadoresSnapshot.docs) {
        List<dynamic> sensoresRaw = doc.get('sensorId') ?? [];
        List<String> sensores = sensoresRaw.map((item) => item.toString()).toList();

        // Adicionar ao debug
        print("Operador: ${doc.get('userName')} - Sensores: $sensores");

        // Adicionamos cada sensor ao Set (duplicatas serão ignoradas automaticamente)
        sensoresUnicos.addAll(sensores);
      }

      // Verificação de debug - imprima os sensores encontrados
      print("Sensores únicos encontrados: $sensoresUnicos");
      print("Total de sensores únicos encontrados: ${sensoresUnicos.length}");

      // Convertemos o Set de volta para uma List para retornar
      return sensoresUnicos.toList();
    } catch (e) {
      print("Erro ao buscar sensores únicos: $e");
      throw e;
    }
  }

  void _updateLateralFromText(String text) {
    final value = double.tryParse(text);
    if (value != null && value >= 0 && value <= 8.0) {
      setState(() {
        bloqueioLateral = value;
      });
    }
  }

  void _updateFrontalFromText(String text) {
    final value = double.tryParse(text);
    if (value != null && value >= 0 && value <= 10.0) {
      setState(() {
        bloqueioFrontal = value;
      });
    }
  }

  // Função para selecionar/desselecionar todos os sensores
  void _selecionarTodos(bool? value) {
    if (value == null) return;

    setState(() {
      selecionarTodos = value;
      for (var sensor in sensoresDisponiveis) {
        sensoresSelecionados[sensor] = value;
      }
    });
  }

  // Função para enviar configurações para os sensores selecionados
  Future<void> _enviarConfiguracoesRemotamente() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Verificar se pelo menos um sensor foi selecionado
    bool peloMenosUmSensorSelecionado = sensoresSelecionados.values.contains(true);
    if (!peloMenosUmSensorSelecionado) {
      _showErrorDialog("Selecione pelo menos um sensor para enviar as configurações.");
      return;
    }

    // Lista de sensores selecionados
    List<String> sensoresSelecionadosList = sensoresDisponiveis
        .where((sensor) => sensoresSelecionados[sensor] == true)
        .toList();

    // Mostrar diálogo de progresso
    List<Map<String, dynamic>> resultados = [];

    // Mostrar diálogo de progresso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _buildProgressDialog(
            sensoresSelecionadosList,
            resultados,
            onComplete: () {
              Navigator.pop(context);
              _showResultsDialog(resultados);
            }
        );
      },
    );
  }

  Widget _buildProgressDialog(
      List<String> sensoresSelecionados,
      List<Map<String, dynamic>> resultados,
      {required Function onComplete}
      ) {
    // Stream controller para controlar o progresso
    StreamController<int> progressController = StreamController<int>();
    int total = sensoresSelecionados.length;
    int completed = 0;

    // Criar o payload base das configurações
    Map<String, dynamic> configsMetadata = {
      "configurations": {
        "blockLateralAngle": double.parse(_lateralController.text),
        "blockFrontalAngle": double.parse(_frontalController.text)
      },
      "wifiConfigs": {
        "SSID": _ssidController.text,
        "password": _passwordController.text
      }
    };

    // Iniciar processo de envio em background
    () async {
      try {
        for (int i = 0; i < sensoresSelecionados.length; i++) {
          String sensorId = sensoresSelecionados[i];

          // Criar payload para este sensor específico
          Map<String, dynamic> payload = {
            "variable": "updateDeviceConfigurations",
            "value": "updateDeviceConfigurations",
            "metadata": configsMetadata,
            "group": sensorId
          };

          // Chamar a API
          try {
            final response = await http.post(
              Uri.parse('http://api.tago.io/data'),
              headers: {
                'Content-Type': 'application/json',
                'device-token': '55156222-043d-4058-8ed1-bae50449a22a'
              },
              body: jsonEncode(payload),
            );

            // Adicionar o resultado a lista de resultados
            resultados.add({
              'sensorId': sensorId,
              'success': response.statusCode == 200 ||
                  response.statusCode == 201 ||
                  response.statusCode == 202,
              'statusCode': response.statusCode,
              'response': response.body
            });
          } catch (e) {
            resultados.add({
              'sensorId': sensorId,
              'success': false,
              'error': e.toString()
            });
          }

          // Atualizar progresso
          completed++;
          progressController.add(completed);
        }

        // Dar um pequeno delay para garantir que o usuário veja 100% antes de fechar
        await Future.delayed(Duration(milliseconds: 500));

        onComplete();
        progressController.close();
      } catch (e) {
        progressController.addError(e);
        progressController.close();
        onComplete();
      }
    }();

    return StreamBuilder<int>(
      stream: progressController.stream,
      initialData: 0,
      builder: (context, snapshot) {
        int progress = snapshot.data ?? 0;
        double percentage = total > 0 ? (progress / total) * 100 : 0;

        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4200)),
                ),
              ),
              SizedBox(width: 16),
              Text(
                "Enviando...",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Progresso: $progress de $total sensores",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 16),
              LinearProgressIndicator(
                value: total > 0 ? progress / total : 0,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4200)),
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "${percentage.toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF4200),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // Lista dos últimos sensores processados (mostra os 3 últimos)
              if (progress > 0)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.only(top: 8),
                  height: 80,
                  child: ListView.builder(
                    shrinkWrap: true,
                    reverse: true,
                    itemCount: resultados.length > 3 ? 3 : resultados.length,
                    itemBuilder: (context, index) {
                      // Mostra os itens em ordem inversa (mais recentes primeiro)
                      int reverseIndex = resultados.length - 1 - index;
                      if (reverseIndex < 0) return SizedBox();

                      final result = resultados[reverseIndex];
                      return Row(
                        children: [
                          Icon(
                            result['success'] ? Icons.check_circle : Icons.error,
                            color: result['success'] ? Colors.green : Colors.red,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Sensor: ${result['sensorId']}",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: progress == total ? () {
                Navigator.pop(context);
                _showResultsDialog(resultados);
              } : null,
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFFFF4200),
                disabledForegroundColor: Colors.grey,
              ),
              child: Text(
                "CONCLUIR",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showResultsDialog(List<Map<String, dynamic>> resultados) {
    int sucessos = resultados.where((r) => r['success'] == true).length;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(
                sucessos == resultados.length ? Icons.check_circle : Icons.info,
                color: sucessos == resultados.length ? Colors.green : Colors.orange,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Configurações Enviadas",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            constraints: BoxConstraints(maxHeight: 300),
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Enviado para $sucessos de ${resultados.length} sensores",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: resultados.length,
                    itemBuilder: (context, index) {
                      final resultado = resultados[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: resultado['success']
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: resultado['success']
                                ? Colors.green.withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              resultado['success'] ? Icons.check_circle : Icons.error,
                              color: resultado['success'] ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Sensor: ${resultado['sensorId']}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  Text(
                                    resultado['success'] ? "Enviado com sucesso" : "Falha no envio",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: resultado['success'] ? Colors.green[700] : Colors.red[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15),
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
              const SizedBox(height: 15),
              Text(
                "Erro",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFFF4200),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Configuração Remota",
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFFF4200)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Configure seus dispositivos remotamente",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 16),

              // Seção de sensores
              _buildSensoresSection(),

              SizedBox(height: 16),

              // Configurações de bloqueio lateral
              _buildExpandableCard(
                title: "Bloqueio Lateral",
                subtitle: "Limite máximo para inclinação lateral",
                isExpanded: _isLateralExpanded,
                minValue: 0.0,
                maxValue: 8.0,
                controller: _lateralController,
                value: bloqueioLateral,
                icon: Icons.sync_alt,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _isLateralExpanded = expanded;
                  });
                },
                onChanged: _updateLateralFromText,
                onSliderChanged: (value) {
                  setState(() {
                    bloqueioLateral = value;
                    _lateralController.text = value.toStringAsFixed(2);
                  });
                },
              ),

              SizedBox(height: 16),

              // Configurações de bloqueio frontal
              _buildExpandableCard(
                title: "Bloqueio Frontal",
                subtitle: "Limite máximo para inclinação frontal",
                isExpanded: _isFrontalExpanded,
                minValue: 0.0,
                maxValue: 10.0,
                controller: _frontalController,
                value: bloqueioFrontal,
                icon: Icons.rotate_right,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _isFrontalExpanded = expanded;
                  });
                },
                onChanged: _updateFrontalFromText,
                onSliderChanged: (value) {
                  setState(() {
                    bloqueioFrontal = value;
                    _frontalController.text = value.toStringAsFixed(2);
                  });
                },
              ),

              SizedBox(height: 16),

              // Configurações de Wi-Fi
              _buildWifiExpandableCard(),

              SizedBox(height: 16),

              // Card informativo
              Card(
                elevation: 0,
                color: Colors.blue.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "As configurações serão aplicadas remotamente nos sensores selecionados na próxima vez que estiverem online.",
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Botão de enviar
              ElevatedButton(
                onPressed: _enviarConfiguracoesRemotamente,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF4200),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  "ENVIAR CONFIGURAÇÕES",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),

              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required String subtitle,
    required bool isExpanded,
    required double minValue,
    required double maxValue,
    required TextEditingController controller,
    required double value,
    required IconData icon,
    required Function(bool) onExpansionChanged,
    required Function(String) onChanged,
    required Function(double) onSliderChanged,
  }) {
    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: Colors.white,
    child: ExpansionTile(
    title: Text(
    title,
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: 'Poppins',
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
          ],
        ),
      ],
    ),
    );
  }

  Widget _buildWifiExpandableCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ExpansionTile(
        title: Text(
          "Wi-Fi",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        subtitle: Text(
          "Configuração de rede Wi-Fi",
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Poppins',
            color: Colors.black54,
          ),
        ),
        leading: Icon(Icons.wifi, color: Color(0xFFFF4200)),
        trailing: Icon(
          _isWiFiExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: Colors.grey,
        ),
        initiallyExpanded: _isWiFiExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _isWiFiExpanded = expanded;
          });
        },
        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(),
              SizedBox(height: 16),

              // Campo SSID
              Text(
                "Nome da Rede (SSID)",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _ssidController,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.network_wifi, color: Color(0xFFFF4200)),
                  hintText: "Nome da rede Wi-Fi",
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFFF4200), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nome da rede é obrigatório';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Campo Senha
              Text(
                "Senha da Rede",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Color(0xFFFF4200)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  hintText: "Senha da rede Wi-Fi",
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFFF4200), width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensoresSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sensors, color: Color(0xFFFF4200)),
                SizedBox(width: 12),
                Text(
                  "Sensores Disponíveis",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 8),

            // Checkbox para selecionar todos
            Row(
              children: [
                Checkbox(
                  value: selecionarTodos,
                  activeColor: Color(0xFFFF4200),
                  onChanged: _selecionarTodos,
                ),
                Text(
                  "Selecionar todos",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            // Lista de sensores
            isLoading
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: Color(0xFFFF4200)),
              ),
            )
                : erro != null
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Erro ao carregar sensores: $erro",
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'Poppins',
                ),
              ),
            )
                : sensoresDisponiveis.isEmpty
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Nenhum sensor cadastrado",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                ),
              ),
            )
                : Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: BoxConstraints(
                maxHeight: 200,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: sensoresDisponiveis.length,
                itemBuilder: (context, index) {
                  final sensor = sensoresDisponiveis[index];
                  return CheckboxListTile(
                    title: Text(
                      sensor,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                    ),
                    value: sensoresSelecionados[sensor] ?? false,
                    activeColor: Color(0xFFFF4200),
                    onChanged: (bool? value) {
                      if (value != null) {
                        setState(() {
                          sensoresSelecionados[sensor] = value;
                          // Verificar se todos estão selecionados
                          selecionarTodos = sensoresSelecionados.values.every((v) => v);
                        });
                      }
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorsListCard() {
    // Definindo quantos sensores mostrar na visualização compacta
    final int minDisplayCount = 3;
    bool isExpanded = false;

    return StatefulBuilder(
        builder: (context, setState) {
          // Lista de sensores a exibir (todos ou apenas os primeiros)
          List<String> displayedSensors = isExpanded
              ? sensoresDisponiveis
              : sensoresDisponiveis.length > minDisplayCount
              ? sensoresDisponiveis.sublist(0, minDisplayCount)
              : sensoresDisponiveis;

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho do card
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF4200).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.sensors, color: Color(0xFFFF4200)),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sensores Disponíveis",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              "Selecione os sensores para configuração",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Contador de sensores
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF4200).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${sensoresDisponiveis.length}",
                          style: TextStyle(
                            color: Color(0xFFFF4200),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Linha para selecionar todos
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Checkbox(
                        value: selecionarTodos,
                        activeColor: Color(0xFFFF4200),
                        onChanged: (val) {
                          setState(() {
                            selecionarTodos = val ?? false;
                            sensoresSelecionados.forEach((key, value) {
                              sensoresSelecionados[key] = selecionarTodos;
                            });
                          });
                        },
                      ),
                      Text(
                        "Selecionar todos",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(),

                // Lista de sensores
                sensoresDisponiveis.isEmpty
                    ? Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      "Nenhum sensor disponível",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                )
                    : Container(
                  constraints: BoxConstraints(
                    maxHeight: isExpanded ? 250 : 180,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    itemCount: displayedSensors.length,
                    itemBuilder: (context, index) {
                      final sensor = displayedSensors[index];
                      return ListTile(
                        dense: true,
                        leading: Checkbox(
                          value: sensoresSelecionados[sensor] ?? false,
                          activeColor: Color(0xFFFF4200),
                          onChanged: (val) {
                            setState(() {
                              sensoresSelecionados[sensor] = val ?? false;

                              // Verificar se todos estão selecionados
                              bool todosChecados = sensoresSelecionados.values
                                  .every((isChecked) => isChecked);
                              selecionarTodos = todosChecados;
                            });
                          },
                        ),
                        title: Text(
                          sensor,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(
                          Icons.bluetooth_connected,
                          color: Color(0xFFFF4200),
                          size: 20,
                        ),
                      );
                    },
                  ),
                ),

                // Botão Expandir/Recolher se houver mais de 3 sensores
                if (sensoresDisponiveis.length > minDisplayCount)
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        icon: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Color(0xFFFF4200),
                        ),
                        label: Text(
                          isExpanded ? "Ver menos" : "Ver mais",
                          style: TextStyle(
                            color: Color(0xFFFF4200),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }
    );
  }
}