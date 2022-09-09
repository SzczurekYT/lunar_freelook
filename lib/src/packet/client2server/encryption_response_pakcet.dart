import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:lunar_freelook/src/converters/packet_byte_buffer.dart';
import 'package:lunar_freelook/src/packet/packet_interface.dart';
import 'package:pointycastle/export.dart';

class EncryptionResponsePacket extends Packet {
  @override
  int get id => 1;
  Uint8List _keyBytes;
  Uint8List _tokenBytes;

  EncryptionResponsePacket(this._keyBytes, this._tokenBytes, RSAPublicKey key) {
    var encrypter = Encrypter(RSA(publicKey: key));

    _keyBytes = encrypter.encryptBytes(_keyBytes).bytes;
    _tokenBytes = encrypter.encryptBytes(_tokenBytes).bytes;
  }

  EncryptionResponsePacket.fromBuffer(PacketByteBuffer buffer)
      : _keyBytes = buffer.readBytesList(),
        _tokenBytes = buffer.readBytesList();

  @override
  void write(PacketByteBuffer buffer) {
    buffer.writeBytesList(_keyBytes);
    buffer.writeBytesList(_tokenBytes);
  }

  Uint8List getKeyBytes(RSAPrivateKey key) {
    var encrypter = Encrypter(RSA(privateKey: key));

    return Uint8List.fromList(encrypter.decryptBytes(Encrypted(_keyBytes)));
  }

  Uint8List getTokenBytes(RSAPrivateKey key) {
    var encrypter = Encrypter(RSA(privateKey: key));

    return Uint8List.fromList(encrypter.decryptBytes(Encrypted(_tokenBytes)));
  }
}
