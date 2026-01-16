import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_scaffold.dart';
import '../auth/auth_controller.dart';
import '../transfers/transfers_controller.dart';
import '../../models/transfer_models.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final transfers = ref.watch(transfersControllerProvider);

    return AppScaffold(
      location: '/home',
      title: 'Anasayfa',
      actions: [
        IconButton(
          tooltip: 'Yenile',
          onPressed: () => ref.read(transfersControllerProvider.notifier).refresh(),
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          tooltip: 'Çıkış',
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kullanıcı Bilgileri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('User ID: ${auth.userId ?? '-'}'),
                    if (auth.mustChangePassword)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('İlk girişte şifre değişikliği zorunlu.', style: TextStyle(color: Colors.orange)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Son Transferler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: transfers.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(child: Text('Henüz transfer yok.'));
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final t = items[index];
                      return ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(t.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text('${t.fileSize} bytes • ${transferStatusLabel(t.status)}'),
                        trailing: Text(_formatDate(t.createdAt)),
                      );
                    },
                  );
                },
                error: (e, _) => Center(child: Text('Hata: $e')),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  final d = dt.toLocal();
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
