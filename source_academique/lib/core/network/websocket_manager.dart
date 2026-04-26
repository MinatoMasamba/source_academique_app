import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/env.dart';

class WebSocketManager {
  WebSocketChannel? _channel;
  final _controller = StreamController<dynamic>.broadcast();

  Stream<dynamic> get messages => _controller.stream;

  void connect(String token) {
    final uri = Uri.parse("${Env.wsUrl}?token=$token");
    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen(
      (message) {
        _controller.add(jsonDecode(message));
      },
      onDone: () => _reconnect(token),
      onError: (_) => _reconnect(token),
    );
  }

  void _reconnect(String token) {
    Timer(const Duration(seconds: 5), () => connect(token));
  }

  void sendMessage(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  void dispose() {
    _channel?.sink.close();
    _controller.close();
  }
}