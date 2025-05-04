import 'package:flutter/material.dart';
import 'package:aplicativo_inclinometro/components/email_field.dart';
import 'package:aplicativo_inclinometro/components/name_field.dart';
import 'package:aplicativo_inclinometro/components/custom_button.dart';
import 'package:aplicativo_inclinometro/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class RegisterOperatorPage extends StatefulWidget {
  @override
  _RegisterOperatorPageState createState() => _RegisterOperatorPageState();
}

class _RegisterOperatorPageState extends State<RegisterOperatorPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sensorController = TextEditingController();
  final FirebaseAuthService _auth = FirebaseAuthService();
  final List<String> _sensoresIDs = [];

  bool isLoading = false;
  String? matricula;
  String? senha;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _sensorController.dispose();
    super.dispose();
  }

  // Gera matrícula de 7 dígitos
  String _gerarMatricula() {
    final random = Random();
    String matricula = "";
    for (int i = 0; i < 7; i++) {
      matricula += random.nextInt(10).toString();
    }
    return matricula;
  }

  // Gera senha aleatória de 8 caracteres
  String _gerarSenha() {
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final random = Random();
    return String.fromCharCodes(
        Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }

  void _adicionarSensor() {
    final sensorID = _sensorController.text.trim();

    // Validação básica: deve ter 4 caracteres hexadecimais
    if (sensorID.isEmpty) {
      _sensorController.clear();
      return;
    }

    if (sensorID.length != 4 || !RegExp(r'^[0-9A-Fa-f]{4}$').hasMatch(sensorID)) {
      _showErrorDialog("ID do sensor deve conter 4 dígitos hexadecimais");
      return;
    }

    if (!_sensoresIDs.contains(sensorID)) {
      setState(() {
        _sensoresIDs.add(sensorID);
        _sensorController.clear();
      });
    } else {
      _showErrorDialog("Este sensor já foi adicionado");
    }
  }

  void _removerSensor(String sensorID) {
    setState(() {
      _sensoresIDs.remove(sensorID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Cadastrar Operador",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Color(0xFFFF4200),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: IconThemeData(color: Color(0xFFFF4200)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            // Campos de Cadastro
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_add, color: Color(0xFFFF4200)),
                        SizedBox(width: 8),
                        Text(
                          'Informações do Operador',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    SizedBox(height: 16),
                    // Substituindo pelo NameField sem os parâmetros que geram erro
                    NameField(
                      controller: _nameController,
                    ),
                    SizedBox(height: 16),
                    // Substituindo pelo EmailField sem os parâmetros que geram erro
                    EmailField(
                      controller: _emailController,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Seção de Sensores
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.sensors, color: Color(0xFFFF4200)),
                        SizedBox(width: 8),
                        Text(
                          'Sensores Associados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    SizedBox(height: 16),

                    // Campo para adicionar sensor
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _sensorController,
                            decoration: InputDecoration(
                              hintText: "ID do Sensor (4 dígitos)",
                              prefixIcon: Icon(Icons.bluetooth, color: Color(0xFFFF4200)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Color(0xFFFF4200)),
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _adicionarSensor,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF4200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Lista de sensores adicionados
                    if (_sensoresIDs.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Nenhum sensor adicionado",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                            fontFamily: 'Poppins',
                          ),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _sensoresIDs.map((sensorID) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Color(0xFFFF4200).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Color(0xFFFF4200).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.bluetooth_connected,
                                      color: Color(0xFFFF4200),
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      sensorID,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red[700],
                                    size: 20,
                                  ),
                                  onPressed: () => _removerSensor(sensorID),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 25),

            // Botão de Cadastrar
            isLoading
                ? Center(child: CircularProgressIndicator(color: Color(0xFFFF4200)))
                : ElevatedButton(
              onPressed: _registerOperator,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF4200),
                foregroundColor: Colors.white,
                elevation: 2,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "CADASTRAR OPERADOR",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),

            // Exibir matrícula e senha após o cadastro bem-sucedido
            if (matricula != null && senha != null) ...[
              SizedBox(height: 25),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Cadastro Realizado!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.green[200]),
                      SizedBox(height: 8),
                      _buildCredentialItem("Matrícula", matricula!),
                      SizedBox(height: 8),
                      _buildCredentialItem("Senha provisória", senha!),
                      SizedBox(height: 16),
                      Text(
                        "Importante: Anote essas informações para repassar ao operador.",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          color: Colors.green[800],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size(double.infinity, 44),
                        ),
                        child: Text(
                          "CONCLUIR",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialItem(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Text(
            "$label:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _registerOperator() async {
    setState(() {
      isLoading = true;
    });

    String username = _nameController.text;
    String email = _emailController.text;

    if (username.isEmpty || email.isEmpty) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog("Preencha nome e e-mail");
      return;
    }

    // Gerar matrícula e senha automaticamente
    matricula = _gerarMatricula();
    senha = _gerarSenha();

    String adminUid = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Obter o nome da empresa do administrador atual
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(adminUid)
          .get();

      if (!adminDoc.exists) {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog("Erro: dados do administrador não encontrados");
        return;
      }

      String company = adminDoc.get('company') ?? '';

      // Modificar o método de registro para incluir sensores, matrícula e senha gerada
      User? user = await _auth.createOperatorUser(
        email: email,
        password: senha!,
        name: username,
        matricula: matricula!,
        sensoresIDs: _sensoresIDs,
        company: company,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (user != null) {
        // Não limpar os inputs até o usuário confirmar
      } else {
        matricula = null;
        senha = null;
        _showErrorDialog(errorSignUp ?? "Erro ao cadastrar operador");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        matricula = null;
        senha = null;
      });
      _showErrorDialog("Erro ao cadastrar operador: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Erro",
            style: TextStyle(
              color: Colors.red[700],
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          content: Text(
            message,
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              child: Text(
                "OK",
                style: TextStyle(
                  color: Color(0xFFFF4200),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          titlePadding: EdgeInsets.fromLTRB(24, 16, 24, 8),
          contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 8),
          actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
      },
    );
  }
}