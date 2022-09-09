import 'dart:typed_data';

class MyUtils {
  static String toHexOrSmth(Uint8List data) {
    return data.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  }
}
