import 'dart:convert';
import 'dart:typed_data';

import '../parser.dart';
import '../stomp_frame.dart';
import '../stomp_parser.dart';

class SockJSParser implements Parser {
  SockJSParser({
    required Function(StompFrame) onStompFrame,
    required this.onDone,
    StompPingFrameCallback? onPingFrame,
  }) {
    _stompParser = StompParser(onStompFrame, onPingFrame);
  }

  late StompParser _stompParser;

  final void Function() onDone;

  @override
  void parseText(String data) {
    parseBytes(utf8.encode(data));
  }

  @override
  void parseBytes(Uint8List byteList) {
    if (byteList.isEmpty) {
      return;
    }

    var msg = utf8.decode(byteList);
    var type = msg.substring(0, 1);
    var content = msg.substring(1);

    // first check for messages that don't need a payload
    switch (type) {
      case 'o': // Open frame
      case 'h': // Heartbeat frame
        return;
      default:
        break;
    }

    if (content.isEmpty) {
      return;
    }

    dynamic payload;
    try {
      payload = json.decode(content);
    } catch (exception) {
      return;
    }

    switch (type) {
      case 'a': //Array of messages
        if (payload is List) {
          for (var item in payload) {
            _stompParser.parseText(item);
          }
        }
        break;
      case 'm': //message
        _stompParser.parseText(payload);
        break;
      case 'c': //Close frame
        onDone();
        break;
    }
  }

  @override
  bool escapeHeaders = false;

  @override
  dynamic serializeFrame(StompFrame frame) {
    dynamic serializedFrame = _stompParser.serializeFrame(frame);

    serializedFrame = _encapsulateFrame(serializedFrame);

    return serializedFrame;
  }

  String _encapsulateFrame(String frame) {
    var result = json.encode(frame);
    return '[$result]';
  }
}
