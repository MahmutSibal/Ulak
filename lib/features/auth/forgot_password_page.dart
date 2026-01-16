import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/ui/auth_shell.dart';
import 'auth_controller.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _email = TextEditingController();
  final _answer = TextEditingController();

  String? _question;
  String? _newPassword;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Şifremi Unuttum',
      maxWidth: 560,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'E-posta'),
          ),
          const SizedBox(height: 12),
          if (_question == null)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  setState(() {
                    _error = null;
                    _newPassword = null;
                  });

                  final res = await ref
                      .read(authControllerProvider.notifier)
                      .forgotQuestion(_email.text.trim());
                  if (!mounted) return;
                  if (res == null) {
                    setState(
                      () => _error = 'Kullanıcı bulunamadı veya hata oluştu.',
                    );
                    return;
                  }
                  setState(() => _question = res.securityQuestion);
                },
                child: const Text('Güvenlik sorusunu getir'),
              ),
            )
          else ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Soru: $_question'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _answer,
              decoration: const InputDecoration(labelText: 'Cevap'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  setState(() {
                    _error = null;
                    _newPassword = null;
                  });

                  final res = await ref
                      .read(authControllerProvider.notifier)
                      .forgotReset(
                        email: _email.text.trim(),
                        answer: _answer.text.trim(),
                      );
                  if (!mounted) return;
                  if (res == null) {
                    setState(
                      () => _error = 'Cevap hatalı veya işlem başarısız.',
                    );
                    return;
                  }
                  setState(() => _newPassword = res.newPassword);
                },
                child: const Text('Yeni şifre üret'),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (_newPassword != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  'Yeni şifreniz: $_newPassword\nİlk girişte şifre değiştirmeniz istenir.',
                ),
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Giriş sayfasına dön'),
          ),
        ],
      ),
    );
  }
}
