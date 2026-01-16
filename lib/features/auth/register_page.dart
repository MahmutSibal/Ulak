import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/ui/auth_shell.dart';
import 'auth_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _password2 = TextEditingController();
  final _question = TextEditingController(text: 'İlk okul öğretmeninizin adı?');
  final _answer = TextEditingController();

  String? _error;
  String? _info;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _password2.dispose();
    _question.dispose();
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return AuthShell(
      title: 'Kayıt Ol',
      maxWidth: 560,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstName,
                    decoration: const InputDecoration(labelText: 'Ad'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Zorunlu' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastName,
                    decoration: const InputDecoration(labelText: 'Soyad'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Zorunlu' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'E-posta'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Zorunlu' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _password,
                    decoration: const InputDecoration(
                      labelText: 'Şifre (6 hane)',
                    ),
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Zorunlu' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _password2,
                    decoration: const InputDecoration(
                      labelText: 'Şifre Tekrar',
                    ),
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Zorunlu' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _question,
              decoration: const InputDecoration(labelText: 'Güvenlik Sorusu'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Zorunlu' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _answer,
              decoration: const InputDecoration(labelText: 'Güvenlik Cevabı'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Zorunlu' : null,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (_info != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _info!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        setState(() {
                          _error = null;
                          _info = null;
                        });
                        if (!_formKey.currentState!.validate()) return;

                        final err = await ref
                            .read(authControllerProvider.notifier)
                            .register(
                              firstName: _firstName.text.trim(),
                              lastName: _lastName.text.trim(),
                              email: _email.text.trim(),
                              password: _password.text,
                              passwordConfirm: _password2.text,
                              securityQuestion: _question.text.trim(),
                              securityAnswer: _answer.text.trim(),
                            );

                        if (!mounted) return;
                        if (err != null) {
                          setState(() => _error = err);
                          return;
                        }

                        setState(
                          () => _info = 'Kayıt başarılı. Giriş yapabilirsiniz.',
                        );
                      },
                child: auth.isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Kayıt Ol'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Giriş sayfasına dön'),
            ),
          ],
        ),
      ),
    );
  }
}
