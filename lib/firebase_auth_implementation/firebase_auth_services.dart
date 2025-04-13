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

  bool isAdmin() {
    return _userType == 'admin';
  }

}