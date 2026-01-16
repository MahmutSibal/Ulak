import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_scaffold.dart';
import '../../app/providers.dart';
import '../../core/checksum.dart';
import 'transfers_controller.dart';

class SendPage extends ConsumerStatefulWidget {
  const SendPage({super.key});

  @override
  ConsumerState<SendPage> createState() => _SendPageState();
}

class _SendPageState extends ConsumerState<SendPage> {
  final _receiverIp = TextEditingController();
  final _receiverUserId = TextEditingController();

  List<PlatformFile> _files = const [];
  String? _error;
  bool _sending = false;

  @override
  void dispose() {
    _receiverIp.dispose();
    _receiverUserId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      location: '/send',
      title: 'Dosya Ver',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Alıcı', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _receiverIp,
                      decoration: const InputDecoration(
                        labelText: 'IP adresi (opsiyonel)',
                        hintText: '192.168.1.100',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _receiverUserId,
                      decoration: const InputDecoration(
                        labelText: 'Kullanıcı ID (UUID) (opsiyonel)',
                        hintText: 'e.g. 3fa85f64-5717-4562-b3fc-2c963f66afa6',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Dosyalar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: _sending
                              ? null
                              : () async {
                                  final res = await FilePicker.platform.pickFiles(
                                    allowMultiple: true,
                                    withData: true,
                                  );
                                  if (res == null) return;
                                  setState(() {
                                    _files = res.files;
                                    _error = null;
                                  });
                                },
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Dosya Seç'),
                        ),
                        if (_files.isNotEmpty)
                          OutlinedButton.icon(
                            onPressed: _sending
                                ? null
                                : () {
                                    setState(() => _files = const []);
                                  },
                            icon: const Icon(Icons.clear),
                            label: const Text('Temizle'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_files.isNotEmpty)
                      Column(
                        children: [
                          for (final f in _files)
                            ListTile(
                              dense: true,
                              leading: const Icon(Icons.insert_drive_file),
                              title: Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text('${f.size} bytes'),
                            ),
                        ],
                      )
                    else
                      const Text('Henüz dosya seçilmedi.'),
                    const SizedBox(height: 12),
                    if (_error != null)
                      Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _sending
                            ? null
                            : () async {
                                setState(() {
                                  _error = null;
                                  _sending = true;
                                });

                                try {
                                  if (_files.isEmpty) {
                                    setState(() => _error = 'En az 1 dosya seçmelisiniz.');
                                    return;
                                  }

                                  final receiverIp = _receiverIp.text.trim().isEmpty ? null : _receiverIp.text.trim();
                                  final receiverUserId = _receiverUserId.text.trim().isEmpty ? null : _receiverUserId.text.trim();
                                  if (receiverIp == null && receiverUserId == null) {
                                    setState(() => _error = 'Alıcı IP veya Kullanıcı ID girin.');
                                    return;
                                  }

                                  final api = ref.read(transfersApiProvider);

                                  for (final f in _files) {
                                    final Uint8List? bytes = f.bytes;
                                    if (bytes == null) {
                                      throw StateError('Web için withData=true gereklidir.');
                                    }

                                    final checksum = sha256Hex(bytes);
                                    await api.createSession(
                                      fileName: f.name,
                                      fileSize: f.size,
                                      fileType: f.extension,
                                      checksumSha256: checksum,
                                      receiverIp: receiverIp,
                                      receiverUserId: receiverUserId,
                                    );
                                  }

                                  await ref.read(transfersControllerProvider.notifier).refresh();
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Transfer oturumu oluşturuldu.')),
                                  );
                                } catch (e) {
                                  setState(() => _error = 'Gönderim başlatılamadı: $e');
                                } finally {
                                  setState(() => _sending = false);
                                }
                              },
                        child: _sending
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Transfer Başlat'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
