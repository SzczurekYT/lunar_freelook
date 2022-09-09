import 'package:lunar_freelook/src/converters/packet_byte_buffer.dart';
import 'package:lunar_freelook/src/packet/packet_interface.dart';

class UnimplementedPacket extends Packet {
  final int _id;
  @override
  int get id => _id;

  UnimplementedPacket(this._id);

  UnimplementedPacket.fromBuffer(PacketByteBuffer buffer)
      : _id = buffer.readVarInt();

  @override
  void write(PacketByteBuffer buffer) {
    buffer.writeVarInt(_id);
  }
}
