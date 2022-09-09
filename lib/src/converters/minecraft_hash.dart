import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';
// ignore: implementation_imports
import 'package:pointycastle/src/utils.dart';

class MinecraftHash {
  static String hash(String str) {
    Uint8List digest = _digest(str);
    return decodeBigInt(digest).toRadixString(16);
  }

  static Uint8List _digest(String str) {
    var md = SHA1Digest();
    Uint8List strBytes = Uint8List.fromList(utf8.encode(str));
    return md.process(strBytes);
  }
}
