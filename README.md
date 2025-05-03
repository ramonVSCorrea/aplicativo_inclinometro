# IncliMax - Aplicativo de Inclinômetro

![Logo IncliMax](assets/inclimax-logo-branco.png)

## Sobre o Projeto

O IncliMax é um aplicativo desenvolvido em Flutter para realizar a medição de inclinação de caminhões basculantes. O aplicativo permite monitorar e registrar medidas de inclinação através de conexão Bluetooth com sensores externos. 


## Funcionalidades

- Autenticação de usuários (login/cadastro)
- Medição de inclinação em tempo real
- Comandos de basculamento do caminhão
- Configuração de parâmetros do sensor
- Dashboard com gráficos e relatórios para administradores

## Tecnologias Utilizadas

- Flutter/Dart
- Firebase Authentication
- Cloud Firestore
- Flutter Bluetooth Serial

## Instalação

1. Clone o repositório

```bash
git clone https://github.com/ramonVSCorrea/aplicativo_inclinometro.git
```

2. Instale as dependências

```bash
flutter pub get
```

3. Execute o aplicativo

```bash
flutter run
```

## Configuração

### Requisitos

- Flutter SDK 3.7.0 ou superior
- Android Studio ou Visual Studio Code
- Dispositivo Android com Bluetooth

### Permissões

O aplicativo necessita das seguintes permissões para funcionar corretamente:

- Bluetooth
- Armazenamento

