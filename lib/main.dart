import 'package:flutter/material.dart';
import 'package:prueba_notificaciones/services/notification_service.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initializeNotification();
  runApp(const MyApp());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'STOMP WebSocket Demo';
    return const MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StompClient _stompClient;
  String _receivedMessage = "";

  @override
  void initState() {
    super.initState();
    _initializeStompClient();
  }

  void _initializeStompClient() {
    _stompClient = StompClient(
      config: StompConfig(
        url: 'http://192.168.100.56:8080/websocket',
        useSockJS: true, // Habilitar SockJS para usar el protocolo http envés de usar el protocolo ws crudo
        onConnect: _onConnect,
        onWebSocketError: (dynamic error) {
          print("HUBO UN ERROR CON EL WEB SOCKET: $error");
        },
      ),
    );
    _stompClient.activate();
  }

  void _onConnect(StompFrame frame) {
    print("Conectado a WebSocket");
    _stompClient.subscribe(
      destination: '/topic/notification',
      callback: (frame) {
        NotificationService().showNotification(title: '¡Tu orden!', body: frame.body);
        setState(() {
          _receivedMessage = frame.body ?? "Sin mensaje recibido.";
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              "Mensaje recibido: $_receivedMessage",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stompClient.deactivate();
    super.dispose();
  }
}