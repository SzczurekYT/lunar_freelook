import 'dart:typed_data';

class PacketResult {
  final bool modified;
  final Uint8List? packet;

  const PacketResult(this.modified, [this.packet]);
}
