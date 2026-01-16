import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../models/transfer_models.dart';

class TransfersController extends AsyncNotifier<List<TransferSession>> {
  @override
  Future<List<TransferSession>> build() async {
    return ref.read(transfersApiProvider).listSessions();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(transfersApiProvider).listSessions());
  }
}

final transfersControllerProvider = AsyncNotifierProvider<TransfersController, List<TransferSession>>(
  TransfersController.new,
);
