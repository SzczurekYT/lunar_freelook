import 'package:lunar_freelook/src/converters/packet_byte_buffer.dart';
import 'package:lunar_freelook/src/network_state.dart';
import 'package:lunar_freelook/src/packet/client2server/encryption_response_pakcet.dart';
import 'package:lunar_freelook/src/packet/client2server/handshake_packet.dart';
import 'package:lunar_freelook/src/packet/packet_interface.dart';
import 'package:lunar_freelook/src/packet/server2client/encryption_request_packet.dart';
import 'package:lunar_freelook/src/packet/server2client/login_succes_packet.dart';
import 'package:lunar_freelook/src/packet/server2client/set_compression_packet.dart';
import 'package:lunar_freelook/src/packet/unimplemented_packet.dart';

class PacketMap {
  Packet mapClientPacket(
      int id, PacketByteBuffer buffer, NetworkState networkState) {
    switch (networkState) {
      case NetworkState.handshaking:
        switch (id) {
          case 0:
            return HandshakePacket.formBuffer(buffer);
        }
        break;
      case NetworkState.login:
        switch (id) {
          case 1:
            return EncryptionResponsePacket.fromBuffer(buffer);
        }
        break;
      case NetworkState.play:
        break;
      case NetworkState.status:
        break;
    }
    return UnimplementedPacket(id);
  }

  Packet mapServerPacket(
      int id, PacketByteBuffer buffer, NetworkState networkState) {
    switch (networkState) {
      case NetworkState.login:
        switch (id) {
          case 1:
            return EncrpytionRequestPacket.fromBuffer(buffer);
          case 2:
            return LoginSuccesPacket.fromBuffer(buffer);
          case 3:
            return SetCompressionPacket.fromBuffer(buffer);
        }
        break;
      case NetworkState.handshaking:
        break;
      case NetworkState.play:
        break;
      case NetworkState.status:
        break;
    }
    return UnimplementedPacket(id);
  }
}
