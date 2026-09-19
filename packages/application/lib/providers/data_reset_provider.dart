import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/data_reset_service.dart';

/// Overridden by the app root, which owns the database and the ProviderScope.
final dataResetServiceProvider = Provider<DataResetService>((ref) {
  throw UnimplementedError(
    'dataResetServiceProvider must be overridden by the app root',
  );
});
