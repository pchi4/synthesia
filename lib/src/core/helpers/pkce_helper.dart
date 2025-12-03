// lib/src/core/helpers/pkce_helper.dart

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PKCEHelper {
  // Gera uma string alfanumérica aleatória
  static String generateCodeVerifier() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(128, (i) => chars[random.nextInt(chars.length)]).join();
  }

  // Gera o Code Challenge (SHA256 e Base64Url) a partir do Code Verifier
  static String generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    
    // Converte o hash para Base64Url (sem padding '=', '+' para '-', '/' para '_')
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }
}