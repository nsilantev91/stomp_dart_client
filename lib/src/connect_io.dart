import 'dart:async';
import 'dart:io' as io;

import 'package:web_socket/io_web_socket.dart';
import 'package:web_socket/web_socket.dart';

import 'stomp_config.dart';

/// One [io.HttpClient] per [io.SecurityContext], created lazily.
///
/// Building a client per connection attempt would leak one on every
/// reconnect, and reconnects are the normal mode of operation here.
final Expando<io.HttpClient> _clients =
    Expando<io.HttpClient>('stompHttpClients');

io.HttpClient _clientFor(io.SecurityContext context) =>
    _clients[context] ??= io.HttpClient(context: context);

Future<WebSocket> connect(StompConfig config) async {
  final securityContext = config.securityContext;

  var webSocketFuture = io.WebSocket.connect(
    config.connectUrl,
    headers: config.webSocketConnectHeaders,
    customClient: securityContext == null ? null : _clientFor(securityContext),
  );

  if (config.connectionTimeout.inMilliseconds > 0) {
    webSocketFuture = webSocketFuture.timeout(config.connectionTimeout);
  }

  var webSocket = await webSocketFuture;

  webSocket.pingInterval = config.pingInterval;

  return IOWebSocket.fromWebSocket(webSocket);
}
