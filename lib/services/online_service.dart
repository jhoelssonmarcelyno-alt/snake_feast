// Serviço online temporariamente desabilitado
// Para reativar, instale web_socket_channel: ^2.4.0 no pubspec.yaml

class OnlineService {
  static final OnlineService _instance = OnlineService._internal();
  factory OnlineService() => _instance;
  OnlineService._internal();

  bool get isEnabled => false;
  
  Future<void> init() async {}
  Future<void> connect() async {}
  Future<void> disconnect() async {}
  bool get isConnected => false;
}
