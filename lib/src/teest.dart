// void main(List<String> args) {
// const beginPublicKey = '-----BEGIN PUBLIC KEY-----';
// const endPublicKey = '-----END PUBLIC KEY-----';

// // Create a new RSA pulic key
// RSAPublicKey publicKey;

// // Create the top level sequence
// var topLevelSeq = ASN1Sequence();

// // Create the sequence holding the algorithm information
// var algorithmSeq = ASN1Sequence();
// var paramsAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
// algorithmSeq
//     .add(ASN1ObjectIdentifier.fromIdentifierString('1.2.840.113549.1.1.1'));
// algorithmSeq.add(paramsAsn1Obj);

// // Create the constructed ASN1BitString
// var keySequence = ASN1Sequence();
// keySequence.add(ASN1Integer(publicKey.modulus));
// keySequence.add(ASN1Integer(publicKey.exponent));
// keySequence.encode(encodingRule: ASN1EncodingRule.ENCODING_DER);
// var publicKeySeqBitString =
//     ASN1BitString(stringValues: keySequence.encodedBytes!);

// // Add ASN1 objects to the top level sequence
// topLevelSeq.add(algorithmSeq);
// topLevelSeq.add(publicKeySeqBitString);
// topLevelSeq.encode(encodingRule: ASN1EncodingRule.ENCODING_DER);

// // Util function for splitting string into equal parts.
// // Taken from basic_utils package.
// List<String> chunk(String s, int chunkSize) {
//   var chunked = <String>[];
//   for (var i = 0; i < s.length; i += chunkSize) {
//     var end = (i + chunkSize < s.length) ? i + chunkSize : s.length;
//     chunked.add(s.substring(i, end));
//   }
//   return chunked;
// }

// // Encode base64
// var dataBase64 = base64.encode(topLevelSeq.encodedBytes!);
// var chunks = chunk(dataBase64, 64);

// print('$beginPublicKey\n${chunks.join('\n')}\n$endPublicKey');
// }

import 'dart:typed_data';

import 'package:lunar_freelook/src/converters/minecraft_encryption.dart';
import 'package:lunar_freelook/src/converters/packet_byte_buffer.dart';
import 'package:pointycastle/asymmetric/api.dart';

void main(List<String> args) {
  var key = RSAPublicKey(
      BigInt.parse(
          "116077862227991398272887861350629113619607729930508609862776760092445783780634097206185468863906557401433719717487193594706499502507101380271531844609801366129500979811790708222397795964504995146968216289163846422187608200076437156024944222993399011922484821048169281644867033038090144062654643513584539208741"),
      BigInt.from(65537));

  var buf = PacketByteBuffer.empty();
  buf.writeString("");
  print(buf.bytes);

  var ulist = Uint8List.fromList([-97, -20, -71, 94]);

  print(MinecraftEncryption.keyToBytes(key));
  buf = PacketByteBuffer.empty();
  buf.writeBytesList(ulist);
  print(buf.bytes);

  buf = PacketByteBuffer.empty();
  print(buf.bytes);

  buf = PacketByteBuffer.empty();
  buf.bytes = ulist;
  print(buf.bytes);
}
