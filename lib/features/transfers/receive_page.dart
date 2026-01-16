import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_scaffold.dart';
import '../../app/providers.dart';
import '../../models/transfer_models.dart';
import '../auth/auth_controller.dart';
import 'transfers_controller.dart';

class ReceivePage extends ConsumerWidget {
  const ReceivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final transfers = ref.watch(transfersControllerProvider);

    return AppScaffold(
      location: '/receive',
      title: 'Dosya Al',
      actions: [
        IconButton(
          tooltip: 'Yenile',
          onPressed: () => ref.read(transfersControllerProvider.notifier).refresh(),
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: transfers.when(
          data: (items) {
            final pending = items.where((t) {
              if (t.status != TransferStatus.pending) return false;
              if (auth.userId == null) return false;
              return t.receiverUserId == auth.userId;
            }).toList();

            if (pending.isEmpty) {
              return const Center(child: Text('Bekleyen transfer isteği yok.'));
            }

            return ListView.separated(
              itemCount: pending.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final t = pending[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.file_download),
                    title: Text(t.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${t.fileSize} bytes'),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () async {
                            await ref.read(transfersApiProvider).reject(t.id);
                            await ref.read(transfersControllerProvider.notifier).refresh();
                          },
                          child: const Text('Reddet'),
                        ),
                        FilledButton(
                          onPressed: () async {
                            await ref.read(transfersApiProvider).accept(t.id);
                            await ref.read(transfersControllerProvider.notifier).refresh();
                          },
                          child: const Text('Kabul'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          error: (e, _) => Center(child: Text('Hata: $e')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
