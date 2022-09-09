import 'dart:typed_data';

import 'package:lunar_freelook/src/utils.dart';
import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/export.dart';
// ignore: implementation_imports
import 'package:pointycastle/src/platform_check/platform_check.dart';

class MinecraftEncryption {
  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> proxyKeys;
  RSAPublicKey? serverKey;

  MinecraftEncryption() : proxyKeys = _generateRandomKeys();

  static Uint8List keyToBytes(RSAPublicKey key) {
    var keySequence = ASN1Sequence();
    keySequence.add(ASN1Integer(key.modulus));
    keySequence.add(ASN1Integer(key.exponent));
    keySequence.encode(encodingRule: ASN1EncodingRule.ENCODING_DER);

    var algorithm = ASN1Sequence();
    algorithm
        .add(ASN1ObjectIdentifier.fromIdentifierString("1.2.840.113549.1.1.1"));
    algorithm.add(ASN1Null());

    var seqence = ASN1Sequence();
    seqence.add(algorithm);
    // seqence.add(ASN1BitString(
    //     elements: [keySequence], tag: ASN1Tags.BIT_STRING_CONSTRUCTED));
    seqence.add(ASN1BitString(stringValues: keySequence.encodedBytes!));
    seqence.encode(encodingRule: ASN1EncodingRule.ENCODING_DER);
    print("Encoded ${MyUtils.toHexOrSmth(seqence.encodedBytes!)}");
    return seqence.encodedBytes!;
  }

  static RSAPublicKey keyFromBytes(Uint8List bytes) {
    print("Decoded: ${MyUtils.toHexOrSmth(bytes)}");
    ASN1Sequence sequence = ASN1Sequence.fromBytes(bytes);
    ASN1Sequence keys = ASN1Sequence.fromBytes(
      Uint8List.fromList(
          (sequence.elements![1] as ASN1BitString).stringValues!),
    );
    //  sequence.elements
    var modulus = (keys.elements![0] as ASN1Integer).integer;
    var exponent = (keys.elements![1] as ASN1Integer).integer;
    return RSAPublicKey(modulus!, exponent!);
  }

  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> _generateRandomKeys() {
    final RSAKeyGenerator keyGen = RSAKeyGenerator();
    keyGen.init(
      ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 1024, 64),
        SecureRandom('Fortuna')
          ..seed(
            KeyParameter(
              Platform.instance.platformEntropySource().getBytes(32),
            ),
          ),
      ),
    );
    var pair = keyGen.generateKeyPair();
    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
        pair.publicKey as RSAPublicKey, pair.privateKey as RSAPrivateKey);
  }
}
