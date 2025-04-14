import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FirebaseAuthService{
  FirebaseAuth _auth = FirebaseAuth.instance;

  // Campo para armazenar o tipo de usuário atual
  String _userType = "";

  // Getter para acessar o tipo de usuário atual
  String get userType => _userType;

  Future<User?> signUpWithEmailAndPassword(String email, String password, String username, String company) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(username);

      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'username': username,
        'company': company,
        'userType': 'admin', // Armazena o tipo de usuário no Firestore
        'createdAt': FieldValue.serverTimestamp(),
      });

      _userType = 'admin';
      errorSignUp = 'Usuário cadastrado com sucesso!';
      return credential.user;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        errorSignUp = 'A senha é muito fraca. Escolha uma senha mais forte.';
      } else if (e.code == 'email-already-in-use') {
        errorSignUp = 'O e-mail já está em uso por outra conta.';
      } else {
        errorSignUp = 'Erro ao criar usuário: ${e.message}';
      }
      print(errorSignUp);
      return null;
    }
  }

  Future<bool> registerOperator(String email, String password, String username, String adminUid) async {
    try {
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(adminUid)
          .get();

      if(!adminDoc.exists || adminDoc.get('userType') != 'admin') {
        errorSignUp = 'Apenas administradores podem cadastrar operadores.';
        return false;
      }

      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      String company = adminDoc.get('company');

      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'username': username,
        'company': company,
        'userType': 'operator',
        'createdBy': adminUid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      errorSignUp = 'Operador cadastrado com sucesso!';
      return true;
    } catch (e) {
      errorSignUp = 'Erro ao registrar operador: $e';
      print(errorSignUp);
      return false;
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (userDoc.exists) {
        _userType = userDoc.get('userType');
      } else {
        _userType = 'operator'; // valor padrão
      }

      errorSignUp = 'Conectado com sucesso!';
      return credential.user;
    } catch (e) {
      errorSignUp = 'Erro ao fazer login: $e';
      print(errorSignUp);
      return null;
    }
  }

  Future<User?> createOperatorUser({
    required String email,
    required String password,
    required String name,
    required String matricula,
    required String company,
    required List<String> sensoresIDs,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Atualizar o displayName
        await credential.user!.updateDisplayName(name);

        // Salvar informações adicionais no Firestore
        await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
          'userName': name,
          'email': email,
          'operatorId': matricula,
          'sensorId': sensoresIDs,
          'userType': 'operator',
          'company': company,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return credential.user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      //errorSignUp = _handleSignUpError(e.code);
      return null;
    } catch (e) {
      errorSignUp = "Erro desconhecido ao criar operador: $e";
      return null;
    }
  }

  Future<User?> signInWithMatricula(String matricula, String password) async {
    try {
      // Primeiro faça login anônimo
      UserCredential anonAuth = await _auth.signInAnonymously();

      // Verifique se o login anônimo foi bem-sucedido
      if (anonAuth.user == null) {
        errorSignUp = "Falha na autenticação anônima";
        return null;
      }

      print("Usuário anônimo autenticado: ${anonAuth.user!.uid}");

      try {
        // Aguarde um momento para garantir que a autenticação seja propagada
        await Future.delayed(Duration(milliseconds: 500));

        // Agora busque o usuário pela matrícula
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('operatorId', isEqualTo: matricula)
            .limit(1)
            .get();

        // Depuração - verifique o que está sendo retornado
        print("Documentos encontrados: ${querySnapshot.docs.length}");

        if (querySnapshot.docs.isEmpty) {
          await _auth.signOut();
          errorSignUp = "Matrícula não encontrada";
          return null;
        }

        // Obter o e-mail do documento
        final String email = querySnapshot.docs.first.get('email');
        print("Email encontrado: $email");

        // Faça logout do usuário anônimo
        await _auth.signOut();

        // Faça login com email/senha
        UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Definir tipo de usuário
        _userType = querySnapshot.docs.first.get('userType') ?? 'operator';

        return credential.user;
      } catch (e) {
        print("Erro detalhado na consulta: $e");
        await _auth.signOut();
        throw e;
      }
    } on FirebaseAuthException catch (authError) {
      errorSignUp = "Erro de autenticação: ${authError.message}";
      return null;
    } catch (e) {
      errorSignUp = "Erro ao buscar matrícula: $e";
      print("Erro ao fazer login com matrícula: $e");
      return null;
    }
  }

  bool isAdmin() {
    return _userType == 'admin';
  }

}