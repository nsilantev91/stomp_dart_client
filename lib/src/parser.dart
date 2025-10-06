import 'dart:typed_data';

import 'stomp_frame.dart';

abstract class Parser {
  late bool escapeHeaders;

  void parseText(String data);
  void parseBytes(Uint8List data);

  dynamic serializeFrame(StompFrame frame);
}
