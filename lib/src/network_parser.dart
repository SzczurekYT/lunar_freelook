import 'dart:developer';
import 'dart:typed_data';

import 'package:lunar_freelook/src/connection_side.dart';
import 'package:lunar_freelook/src/converters/minecraft_encryption.dart';
import 'package:lunar_freelook/src/converters/packet_coder.dart';
import 'package:lunar_freelook/src/network_state.dart';
import 'package:lunar_freelook/src/packet/client2server/encryption_response_pakcet.dart';
import 'package:lunar_freelook/src/packet/client2server/handshake_packet.dart';
import 'package:lunar_freelook/src/packet/packet_interface.dart';
import 'package:lunar_freelook/src/packet/packet_result.dart';
import 'package:lunar_freelook/src/packet/server2client/encryption_request_packet.dart';
import 'package:lunar_freelook/src/packet/server2client/set_compression_packet.dart';
import 'package:lunar_freelook/src/packet/unimplemented_packet.dart';

class NetworkParser {
  MinecraftEncryption mcEncryption = MinecraftEncryption();
  PacketCoder coder = PacketCoder();

  PacketResult onClientPacket(Uint8List bytes) {
    var packet = coder.decode(bytes, ConnectionSide.client);
    print("Got client packet with id: ${packet.id}!");
    print(packet.runtimeType);

    switch (packet.runtimeType) {
      case HandshakePacket:
        coder.networkState = (packet as HandshakePacket).nextState;
        break;
      case EncryptionResponsePacket:
        print("Client ERP");
        coder.encryptionEnabled = true;
        packet = packet as EncryptionResponsePacket;

        print(packet.getKeyBytes(mcEncryption.proxyKeys.privateKey));

        if (mcEncryption.serverKey == null) {
          throw Exception("Server's public key is null! Why?");
        }

        var replacementPacket = EncryptionResponsePacket(
            packet.getKeyBytes(mcEncryption.proxyKeys.privateKey),
            packet.getTokenBytes(mcEncryption.proxyKeys.privateKey),
            mcEncryption.serverKey!);

        log("Swapped encryption response packed.");
        return PacketResult(true, coder.encode(replacementPacket));
    }
    return const PacketResult(false);
  }

  PacketResult onServerPacket(Uint8List bytes) {
    Packet packet = coder.decode(bytes, ConnectionSide.server);
    print("Got server packet with id: ${packet.id}!");

    switch (packet.runtimeType) {
      case EncrpytionRequestPacket:
        print("Server ERP");
        // Encryption request packet
        packet = packet as EncrpytionRequestPacket;

        mcEncryption.serverKey = packet.publicKey;

        var replacementPacket = EncrpytionRequestPacket(packet.serverID,
            mcEncryption.proxyKeys.publicKey, packet.verifyToken);
        log("modulus: ${(mcEncryption.proxyKeys.publicKey).modulus}");
        log("exponent: ${(mcEncryption.proxyKeys.publicKey).exponent}");
        log("Swapped encryption request packed.");
        var data = coder.encode(replacementPacket);
        print("ERP Len: ${data.length}");
        print("ERP array: $data");
        return PacketResult(true, data);

      case SetCompressionPacket:
        print("Compression!");
        log("Compression has been set!");
        coder.compressionTreshold =
            (packet as SetCompressionPacket).compressionThreshold;
        break;

      case UnimplementedPacket:
        if (coder.networkState == NetworkState.login && packet.id == 2) {
          // Login succes packet
          print("Login succes");
          coder.networkState = NetworkState.play;
        }

        break;
    }
    return const PacketResult(false);
  }
}
