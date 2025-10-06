import 'dart:async';

import 'package:web_socket/browser_web_socket.dart';
import 'package:web_socket/web_socket.dart';

import 'stomp_config.dart';

Future<WebSocket> connect(StompConfig config) async {
  final webSocketFuture =
      BrowserWebSocket.connect(Uri.parse(config.connectUrl));

  if (config.connectionTimeout.inMilliseconds > 0) {
    return webSocketFuture.timeout(config.connectionTimeout);
  }

  return webSocketFuture;
}
