import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:lunar_freelook/src/connection_side.dart';
import 'package:lunar_freelook/src/converters/packet_byte_buffer.dart';
import 'package:lunar_freelook/src/network_state.dart';
import 'package:lunar_freelook/src/packet/packet_interface.dart';
import 'package:lunar_freelook/src/packet/packet_map.dart';

class PacketCoder {
  PacketMap packetMap = PacketMap();
  NetworkState networkState = NetworkState.handshaking;
  bool encryptionEnabled = false;
  int compressionTreshold = -1;

  // TODO: Handle the ecryption

  Packet decode(Uint8List bytes, ConnectionSide side) {
    PacketByteBuffer buffer = PacketByteBuffer(bytes);
    int id;
    if (compressionTreshold > 0) {
      // Compression is enabled
      buffer.readVarInt(); // Read and discrad the length, we don't need it.
      // Read the uncompressed size
      // If it's 0 it means it's uncompressed
      int size = buffer.readVarInt();
      if (size != 0) {
        // Packet is compressed
        buffer.discard();
        buffer.bytes = Uint8List.fromList(decompress(buffer.bytes));
        id = buffer.readVarInt();
      } else {
        // Packet is uncompressed
        id = buffer.readVarInt();
      }
    } else {
      // Compression is disabled
      buffer.readVarInt(); // Read and discrad the length, we don't need it.
      id = buffer.readVarInt(); // Read the ID
    }

    switch (side) {
      case ConnectionSide.client:
        return packetMap.mapClientPacket(id, buffer, networkState);
      case ConnectionSide.server:
        return packetMap.mapServerPacket(id, buffer, networkState);
    }
  }

  Uint8List encode(Packet packet) {
    // Create a buffer
    var buffer = PacketByteBuffer.empty();
    // And write all the packet's data to it :)
    packet.write(buffer);
    // A list to store and easily write the data.
    List<int> list = List.empty(growable: true);
    if (compressionTreshold > 0) {
      // Compression is enabled

      // Write the id
      list.addAll(PacketByteBuffer.intToVarInt(packet.id));
      // Write the data
      list.addAll(buffer.bytes);
      int compressedSize = 0;
      // Compress if needed
      if (list.length > compressionTreshold) {
        list = compress(list);
        compressedSize = list.length;
      }

      list.insertAll(0, PacketByteBuffer.intToVarInt(compressedSize));
      list.insertAll(0, PacketByteBuffer.intToVarInt(list.length));
    } else {
      // Compression is disabled
      // Write the id
      list.addAll(PacketByteBuffer.intToVarInt(packet.id));
      // Write the data
      list.addAll(buffer.bytes);
      list.insertAll(0, PacketByteBuffer.intToVarInt(list.length));
    }
    return Uint8List.fromList(list);
  }

  List<int> decompress(List<int> bytes) {
    return zlib.decode(bytes);
  }

  List<int> compress(List<int> bytes) {
    return zlib.encode(bytes);
  }
}
