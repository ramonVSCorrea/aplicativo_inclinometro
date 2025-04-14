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
      appBar: AppBar(
        title: Text("Cadastrar Operador"),
        backgroundColor: Color(0xFFA59AFF),
      ),
      body: Container(
        padding: const EdgeInsets.all(40),
        color: const Color(0xFFFFFEFE),
        child: ListView(
          children: <Widget>[
            const Text(
              "Cadastro de Operador",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Nome completo",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: Color(0xFFA59AFF),
              ),
            ),
            const SizedBox(height: 10),
            NameField(controller: _nameController),
            const SizedBox(height: 20),
            const Text(
              "E-mail",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: Color(0xFFA59AFF),
              ),
            ),
            const SizedBox(height: 10),
            EmailField(controller: _emailController),
            const SizedBox(height: 20),

            // Campo para adicionar sensores
            const Text(
              "Sensores (opcional)",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: Color(0xFFA59AFF),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sensorController,
                    maxLength: 4,
                    decoration: InputDecoration(
                      hintText: 'ID do sensor (4 dígitos hex)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      prefixIcon: Icon(Icons.sensors),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      counterText: "",
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _adicionarSensor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFA59AFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text("Adicionar"),
                ),
              ],
            ),

            // Lista de sensores adicionados
            if (_sensoresIDs.isNotEmpty) ...[
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sensores atribuídos:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _sensoresIDs.map((sensor) => Chip(
                        label: Text(sensor),
                        deleteIcon: Icon(Icons.close, size: 18),
                        onDeleted: () => _removerSensor(sensor),
                        backgroundColor: Colors.grey.shade200,
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),
            isLoading
                ? Center(child: CircularProgressIndicator(color: Color(0xFFA59AFF)))
                : CustomButton(
              label: "Cadastrar Operador",
              onPressed: _registerOperator,
            ),

            // Exibir matrícula e senha após o cadastro bem-sucedido
            if (matricula != null && senha != null) ...[
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "✅ Operador cadastrado com sucesso!",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "Matrícula: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(matricula!, overflow: TextOverflow.ellipsis),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, size: 16),
                          onPressed: () {
                            // Implementar cópia para clipboard
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Senha: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(senha!, overflow: TextOverflow.ellipsis),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, size: 16),
                          onPressed: () {
                            // Implementar cópia para clipboard
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Guarde estas informações. O operador precisará delas para acessar o sistema.",
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
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
          title: Text("Erro"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
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