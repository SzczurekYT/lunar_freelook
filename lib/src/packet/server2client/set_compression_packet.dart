import 'package:lunar_freelook/src/converters/packet_byte_buffer.dart';
import 'package:lunar_freelook/src/packet/packet_interface.dart';

class SetCompressionPacket extends Packet {
  @override
  int get id => 3;

  final int compressionThreshold;

  SetCompressionPacket(this.compressionThreshold);

  SetCompressionPacket.fromBuffer(PacketByteBuffer buffer)
      : compressionThreshold = buffer.readVarInt();

  @override
  void write(PacketByteBuffer buffer) {
    buffer.writeVarInt(compressionThreshold);
  }
}
