import 'dart:convert';
import 'dart:typed_data';

class PacketByteBuffer {
  int writerIndex = 0;
  int readerIndex = 0;
  // final List<int> bytes;
  Uint8List bytes;

  static const segmentBits = 0x7F;
  static const continueBit = 0x80;

  PacketByteBuffer(this.bytes);

  PacketByteBuffer.fromList(List<int> list) : this(Uint8List.fromList(list));

  PacketByteBuffer.empty() : bytes = Uint8List(0);

  int readByte() {
    var byte = bytes[readerIndex];
    // var byte = bytes.buffer.asByteData().getUint16(readerIndex, Endian.big);
    readerIndex++;
    // print(byte);
    return byte;
  }

  writeByte(int byte) {
    if (writerIndex > bytes.length - 1) {
      var newList = Uint8List(writerIndex + 1);
      newList.setRange(0, bytes.length, bytes);
      bytes = newList;
    }
    bytes[writerIndex] = byte;
    writerIndex++;
  }

  int readVarInt() {
    int value = 0;
    int position = 0;
    int currentByte;

    while (true) {
      currentByte = readByte();
      value |= (currentByte & segmentBits) << position;

      if ((currentByte & continueBit) == 0) break;

      position += 7;

      if (position >= 32) throw Exception("VarInt is too big");
    }

    return value;
  }

  static int staticReadVarInt(Uint8List bytes) {
    int value = 0;
    int position = 0;
    int currentByte;

    int readerIndex = 0;

    while (true) {
      currentByte = bytes[readerIndex];
      readerIndex++;
      value |= (currentByte & segmentBits) << position;

      if ((currentByte & continueBit) == 0) break;

      position += 7;

      if (position >= 32) throw Exception("VarInt is too big");
    }

    return value;
  }

  void writeVarInt(int value) {
    while (true) {
      if ((value & ~segmentBits) == 0) {
        writeByte(value);
        return;
      }

      writeByte((value & segmentBits) | continueBit);

      // Note: >>> means that the sign bit is shifted with the rest of the number rather than being left alone
      value >>>= 7;
    }
  }

  String readString(int maxLength) {
    int allowedLength = _toEncodedStringLength(maxLength);
    int size = readVarInt();
    if (size > allowedLength) {
      throw Exception(
          "The received encoded string buffer length is longer than maximum allowed ($allowedLength > $size)");
    }
    if (size < 0) {
      throw Exception(
          "The received encoded string buffer length is less than zero! Weird string!");
    }
    String result = utf8.decode(bytes.sublist(readerIndex, readerIndex + size));
    readerIndex += size;
    if (result.length > maxLength) {
      throw Exception(
          "The received string length is longer than maximum allowed (${result.length} > $maxLength)");
    }
    return result;
  }

  void writeString(String string) {
    _writeString(string, 32767);
  }

  void _writeString(String string, int maxLength) {
    var bytes = Uint8List.fromList(utf8.encode(string));
    if (bytes.length > maxLength) {
      throw Exception(
          "String too big (was ${bytes.length} bytes encoded, max $maxLength)");
    }
    writeVarInt(bytes.length);
    writeBytes(bytes);
  }

  int readUnsignedShort() {
    ByteData byteData = ByteData.sublistView(bytes);
    int value = byteData.getUint16(readerIndex, Endian.big);
    readerIndex += 2;
    return value;
  }

  void writeUnsignedShort(int short) {
    ByteData byteData = ByteData.sublistView(bytes);
    byteData.setUint16(writerIndex, short, Endian.big);
    writerIndex += 2;
  }

  int readLong() {
    ByteData byteData = ByteData.sublistView(bytes);
    int value = byteData.getInt64(readerIndex, Endian.big);
    readerIndex += 8;
    return value;
  }

  int readUUID() {
    var value = bytes
        .sublist(readerIndex, readerIndex + 16)
        .buffer
        .asUint64List(readerIndex);
    print(value);
    readerIndex += 2;
    return 0;
  }

  Uint8List readBytesList() {
    int len = readVarInt();
    return readBytes(len);
  }

  void writeBytesList(Uint8List data) {
    writeVarInt(data.length);
    writeBytes(data);
  }

  Uint8List readBytes(int length) {
    var sublist = bytes.sublist(readerIndex, readerIndex + length);
    readerIndex += length;
    return sublist;
  }

  void writeBytes(Uint8List data) {
    if (writerIndex + data.length > bytes.length - 1) {
      var newList = Uint8List(writerIndex + data.length);
      newList.setRange(0, bytes.length, bytes);
      bytes = newList;
    }
    bytes.setRange(writerIndex, writerIndex + data.length, data);
    writerIndex += data.length;
  }

  void discard() {
    bytes = bytes.sublist(readerIndex, bytes.length);
    readerIndex = 0;
  }

  static int _toEncodedStringLength(int decodedLength) {
    return decodedLength * 3;
  }

  static Uint8List intToVarInt(int value) {
    List<int> list = [];
    while (true) {
      if ((value & ~segmentBits) == 0) {
        list.add(value);
        return Uint8List.fromList(list);
      }

      list.add((value & segmentBits) | continueBit);

      // Note: >>> means that the sign bit is shifted with the rest of the number rather than being left alone
      value >>>= 7;
    }
  }

  static int varIntToInt(Uint8List bytes) {
    int index = 0;

    int value = 0;
    int position = 0;
    int currentByte;

    while (true) {
      currentByte = bytes[index];
      index++;
      value |= (currentByte & segmentBits) << position;

      if ((currentByte & continueBit) == 0) break;

      position += 7;

      if (position >= 32) throw Exception("VarInt is too big");
    }

    return value;
  }
}
