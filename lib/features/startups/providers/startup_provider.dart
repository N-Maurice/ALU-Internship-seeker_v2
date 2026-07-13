import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/startup_model.dart';
import '../../../providers/app_providers.dart';

final startupByIdProvider = FutureProvider.family<StartupModel?, String>((ref, id) {
  return ref.watch(startupRepositoryProvider).getById(id);
});
