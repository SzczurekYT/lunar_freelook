import 'package:lunar_freelook/src/converters/packet_byte_buffer.dart';
import 'package:lunar_freelook/src/network_state.dart';
import 'package:lunar_freelook/src/packet/packet_interface.dart';

class HandshakePacket extends Packet {
  @override
  int get id => 0;

  final int protocolVersion;
  final String serverAddres;
  final int serverPort;
  final NetworkState nextState;

  HandshakePacket(
      this.protocolVersion, this.serverAddres, this.serverPort, this.nextState);

  HandshakePacket.formBuffer(PacketByteBuffer buffer)
      : protocolVersion = buffer.readVarInt(),
        serverAddres = buffer.readString(255),
        serverPort = buffer.readUnsignedShort(),
        nextState = NetworkState.byId(buffer.readVarInt());

  @override
  void write(PacketByteBuffer buffer) {
    buffer.writeVarInt(protocolVersion);
    buffer.writeString(serverAddres);
    buffer.writeUnsignedShort(serverPort);
    buffer.writeVarInt(nextState.id);
  }
}
