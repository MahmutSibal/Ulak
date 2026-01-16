import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_scaffold.dart';
import '../auth/auth_controller.dart';
import 'theme_controller.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _newPassword2 = TextEditingController();

  String? _error;
  String? _info;

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _newPassword2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return AppScaffold(
      location: '/settings',
      title: 'Ayarlar',
      actions: [
        IconButton(
          tooltip: 'Çıkış',
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Tema'),
              subtitle: const Text('Açık / Koyu / Sistem'),
              trailing: DropdownButton<ThemeMode>(
                value: themeMode,
                onChanged: (v) {
                  if (v == null) return;
                  ref.read(themeModeProvider.notifier).setMode(v);
                },
                items: const [
                  DropdownMenuItem(value: ThemeMode.system, child: Text('Sistem')),
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Açık')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Koyu')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Şifre Değiştir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (auth.mustChangePassword)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('Devam etmek için şifrenizi değiştirin.', style: TextStyle(color: Colors.orange)),
                    ),
                  TextField(
                    controller: _oldPassword,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Mevcut Şifre'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newPassword,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Yeni Şifre (6 hane)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newPassword2,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Yeni Şifre Tekrar'),
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  if (_info != null)
                    Text(_info!, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 12),
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

                              final err = await ref.read(authControllerProvider.notifier).changePassword(
                                    oldPassword: _oldPassword.text,
                                    newPassword: _newPassword.text,
                                    confirm: _newPassword2.text,
                                  );
                              if (!mounted) return;
                              if (err != null) {
                                setState(() => _error = err);
                                return;
                              }
                              setState(() => _info = 'Şifre güncellendi.');
                            },
                      child: auth.isLoading
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Şifreyi Değiştir'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
