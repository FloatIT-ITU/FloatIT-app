import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class GitHubAppService {
  GitHubAppService._();
  static final instance = GitHubAppService._();

  // GitHub App constants
  static const String appId = '2172696';
  static const String installationId = '91462056';

  // Decrypt AES (compatible with crypto-js)
  String decryptAES(String encrypted, String key) {
    try {
      final encryptedBytes = base64.decode(encrypted);
      if (encryptedBytes.length < 16) {
        throw Exception('Encrypted data too short, expected at least 16 bytes for IV');
      }

      final iv = encryptedBytes.sublist(0, 16);
      final cipherText = encryptedBytes.sublist(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromUtf8(key)));
      final decrypted = encrypter.decrypt(encrypt.Encrypted(cipherText), iv: encrypt.IV(iv));
      return decrypted;
    } catch (e) {
      throw Exception('Failed to decrypt GitHub key: $e. Encrypted length: ${encrypted.length}, Key length: ${key.length}');
    }
  }

  // Helper to generate JWT
  String generateJWT(String privateKeyPem) {
    try {
      final jwt = JWT(
        {
          'iss': appId,
          'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 600, // 10 minutes
        },
      );
      return jwt.sign(RSAPrivateKey(privateKeyPem), algorithm: JWTAlgorithm.RS256);
    } catch (e) {
      throw Exception('Failed to generate JWT: $e');
    }
  }

  // Get installation token
  Future<String> getInstallationToken(String jwt) async {
    // Validate installation ID to prevent injection
    if (!RegExp(r'^\d+$').hasMatch(installationId)) {
      throw Exception('Invalid installation ID format');
    }

    final response = await http.post(
      Uri.parse('https://api.github.com/app/installations/$installationId/access_tokens'),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Accept': 'application/vnd.github+json',
        'User-Agent': 'FloatIT-App/1.0',
      },
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to get installation token: HTTP ${response.statusCode}');
    }
    final data = jsonDecode(response.body);
    if (data['token'] == null) {
      throw Exception('No token received from GitHub API');
    }
    return data['token'];
  }

  // Trigger repository dispatch
  Future<void> triggerNotificationDispatch(String notificationId) async {
    // Validate notification ID to prevent injection
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(notificationId)) {
      throw Exception('Invalid notification ID format');
    }

    // Fetch encrypted key and passphrase
    final keyDoc = await FirebaseFirestore.instance.collection('admin_config').doc('github_app_key').get();
    final encryptedKey = keyDoc.data()?['encrypted_key'] as String?;
    final storedPassphrase = keyDoc.data()?['passphrase'] as String?;
    if (encryptedKey == null || storedPassphrase == null) throw Exception('GitHub config not found');

    // Decrypt
    final privateKeyPem = decryptAES(encryptedKey, storedPassphrase);

    // Generate JWT
    final jwt = generateJWT(privateKeyPem);

    // Get installation token
    final token = await getInstallationToken(jwt);

    // Dispatch with validated payload
    final payload = {
      'event_type': 'send_notification',
      'client_payload': {'notificationId': notificationId}
    };

    final response = await http.post(
      Uri.parse('https://api.github.com/repos/FloatIT-ITU/FloatIT-app/dispatches'),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github+json',
        'Content-Type': 'application/json',
        'User-Agent': 'FloatIT-App/1.0',
      },
      body: jsonEncode(payload),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to trigger push notifications: HTTP ${response.statusCode}');
    }
  }

  // Check if GitHub App is configured
  bool get isConfigured => appId != 'YOUR_APP_ID' && installationId != 'YOUR_INSTALLATION_ID';
}