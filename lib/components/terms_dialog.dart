import 'package:flutter/material.dart';

class TermsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Text(
              "Termos de Uso",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Bem-vindo ao nosso aplicativo Inclinâmetro. Ao usar nosso aplicativo, você concorda em cumprir com os seguintes termos e condições. Leia atentamente os seguintes termos antes de usar o aplicativo.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            _buildSubtitle("1. Uso do Aplicativo"),
            Text(
              "Você concorda em usar o aplicativo Inclinâmetro apenas para fins legais e de maneira que não viole as leis e regulamentações aplicáveis. Não utilize o aplicativo de maneira que prejudique sua funcionalidade ou prejudique a experiência de outros usuários.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            _buildSubtitle("2. Privacidade"),
            Text(
              "Respeitamos sua privacidade. Para entender como coletamos, usamos e protegemos suas informações pessoais, consulte nossa Política de Privacidade.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            _buildSubtitle("3. Registro"),
            Text(
              "Ao se registrar no aplicativo, você é responsável por manter a confidencialidade de sua conta e senha. Você também é responsável por todas as atividades que ocorrem em sua conta.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            _buildSubtitle("4. Conteúdo do Usuário"),
            Text(
              "Você concorda em não enviar, carregar ou compartilhar qualquer conteúdo que seja ilegal, ofensivo, difamatório, obsceno ou viole os direitos de terceiros.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            _buildSubtitle("5. Modificações"),
            Text(
              "Reservamo-nos o direito de modificar ou encerrar o aplicativo a qualquer momento, sem aviso prévio.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            _buildSubtitle("6. Desresponsabilização"),
            Text(
              "O aplicativo Inclinâmetro é fornecido \"como está\", e não fazemos representações ou garantias de qualquer tipo, expressas ou implícitas, sobre a operação do aplicativo ou a informação, conteúdo ou materiais incluídos nele.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            _buildSubtitle("7. Lei Aplicável"),
            Text(
              "Este acordo é regido pelas leis do Brasil.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            _buildSubtitle("8. Contato"),
            Text(
              "Se tiver alguma dúvida sobre estes termos de uso, entre em contato conosco pelo e-mail: [seu endereço de e-mail].",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            TextButton(
              child: Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
