import 'package:lunar_freelook/src/converters/packet_byte_buffer.dart';
import 'package:lunar_freelook/src/packet/packet_interface.dart';

class LoginSuccesPacket extends Packet {
  @override
  int get id => 2;

  LoginSuccesPacket();

  LoginSuccesPacket.fromBuffer(PacketByteBuffer buffer);

  @override
  void write(PacketByteBuffer buffer) {
    // TODO: implement write
  }
}
