// import 'dart:convert';
// import 'dart:math';
//
// import 'package:encrypt/encrypt.dart';
//
//
// final myEncrypter = MyEncryptionDecryption();
//
// class MyEncryptionDecryption{
//   late final Key secretKey;
//
//   MyEncryptionDecryption(){
//     secretKey = Key.fromUtf8('your_secret_key');
//   }
//
// //19mTVOev8tmQ3kAw7bWwUQ==
//   String encryptAES(plainText){
//     final encrypter = Encrypter(AES(secretKey,mode: AESMode.ecb));
//     final encryptedText = encrypter.encrypt(plainText);
//     return encryptedText.base64;
//   }
//
//   String decrypt(String encryptedText){
//     final encrypter = Encrypter(AES(secretKey,mode: AESMode.ecb));
//     final encrypted = encrypter.encrypt(encryptedText);
//
//     final decryptedText =encrypter.decrypt(encrypted);
//     return decryptedText;
//   }
//
//   //109+kCLFd3TjFBjh3LUG4w==
// }
// String generateRandomKey(){
//   final random = Random.secure();
//   final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
//   return base64UrlEncode(keyBytes);
// }

import 'dart:convert';

Codec<String, String> stringToBase64 = utf8.fuse(base64);

// class MyEncryptionDecryption{
//   static final key=encrypt.Key.fromLength(32);
//   static final iv=encrypt.IV.fromLength(16);
//   static final encrypter=encrypt.Encrypter(encrypt.AES(key));
//
//   static encryptAES(text){
//     final encrypted=encrypter.encrypt(text,iv: iv);
//     print(encrypted.bytes);
//     print(encrypted.base16);
//     print(encrypted.base64);
//     return encrypted;
//   }
//
//   static decryptAES(text){
//     return encrypter.decrypt(text,iv: iv);
//   }
// }
