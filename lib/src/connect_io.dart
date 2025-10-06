import 'dart:async';
import 'dart:io' as io;

import 'package:web_socket/io_web_socket.dart';
import 'package:web_socket/web_socket.dart';

import 'stomp_config.dart';

Future<WebSocket> connect(StompConfig config) async {
  var webSocketFuture = io.WebSocket.connect(
    config.connectUrl,
    headers: config.webSocketConnectHeaders,
  );

  if (config.connectionTimeout.inMilliseconds > 0) {
    webSocketFuture = webSocketFuture.timeout(config.connectionTimeout);
  }

  var webSocket = await webSocketFuture;

  webSocket.pingInterval = config.pingInterval;

  return IOWebSocket.fromWebSocket(webSocket);
}
