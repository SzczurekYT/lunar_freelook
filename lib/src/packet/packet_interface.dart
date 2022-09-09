import 'package:lunar_freelook/src/converters/packet_byte_buffer.dart';

abstract class Packet {
  int get id => 0;

  Packet();

  Packet.fromBuffer(PacketByteBuffer buffer);

  void write(PacketByteBuffer buffer);
}
