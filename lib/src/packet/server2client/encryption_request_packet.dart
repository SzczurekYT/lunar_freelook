import 'dart:typed_data';

import 'package:lunar_freelook/src/converters/minecraft_encryption.dart';
import 'package:lunar_freelook/src/converters/packet_byte_buffer.dart';
import 'package:lunar_freelook/src/packet/packet_interface.dart';
import 'package:pointycastle/asymmetric/api.dart';

class EncrpytionRequestPacket extends Packet {
  final String serverID;
  final RSAPublicKey publicKey;
  final Uint8List verifyToken;
  @override
  int get id => 1;

  EncrpytionRequestPacket(this.serverID, this.publicKey, this.verifyToken);

  EncrpytionRequestPacket.fromBuffer(PacketByteBuffer buffer)
      : serverID = buffer.readString(20),
        publicKey = MinecraftEncryption.keyFromBytes(buffer.readBytesList()),
        verifyToken = buffer.readBytesList();

  @override
  void write(PacketByteBuffer buffer) {
    buffer.writeString(serverID);
    buffer.writeBytesList(MinecraftEncryption.keyToBytes(publicKey));
    buffer.writeBytesList(verifyToken);
  }
}
