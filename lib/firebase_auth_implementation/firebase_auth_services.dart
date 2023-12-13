import 'package:aplicativo_inclinometro/store/variables.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FirebaseAuthService{
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(String email, String password, String username) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(username);
      errorSignUp = 'Usuário cadastrado com sucesso!';
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        errorSignUp = 'A senha é muito fraca. Escolha uma senha mais forte.';
        print('A senha é muito fraca. Escolha uma senha mais forte.');
      } else if (e.code == 'email-already-in-use') {
        errorSignUp = 'O e-mail já está em uso por outra conta.';
        print('O e-mail já está em uso por outra conta.');
      } else {
        errorSignUp = 'Erro ao criar usuário: ${e.message}';
        print('Erro ao criar usuário: ${e.message}');
      }
    } catch (e) {
      errorSignUp = 'Erro desconhecido: $e';
      print('Erro desconhecido: $e');
    }

    return null;
  }


  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      errorSignUp = 'Conectado com sucesso!';
      return credential.user;
    } catch (e) {

      print('Some error ocurred');
    }
    return null;
  }

}