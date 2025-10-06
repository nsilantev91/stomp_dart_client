import 'dart:async';

import 'package:web_socket/web_socket.dart';

import 'stomp_config.dart';

Future<WebSocket> connect(StompConfig config) {
  throw UnsupportedError('No implementation of the connect api provided');
}
