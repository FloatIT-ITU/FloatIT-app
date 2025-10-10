import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth_utils.dart';

class PasswordResetDialog extends StatelessWidget {
  final String email;
  const PasswordResetDialog({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Password'),
      content: const Text('A password reset link will be sent to your email.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (AuthUtils.isForbiddenEmail(email)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('This email address cannot be used for password reset.')),
              );
              return;
            }
            try {
              await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password reset email sent')),
                );
              }
            } on FirebaseAuthException catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Failed to send reset email: ${e.message}')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to send reset email.')),
                );
              }
            }
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}
