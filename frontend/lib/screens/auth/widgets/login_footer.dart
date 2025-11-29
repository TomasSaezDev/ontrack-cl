import 'package:flutter/material.dart';

class LoginFooter extends StatelessWidget {
  final VoidCallback onRegisterPressed;

  const LoginFooter({super.key, required this.onRegisterPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('¿No tienes cuenta?', style: TextStyle(color: Colors.grey)),
        TextButton(
          onPressed: onRegisterPressed,
          child: const Text('Regístrate'),
        ),
      ],
    );
  }
}
