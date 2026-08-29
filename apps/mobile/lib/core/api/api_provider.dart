/// Wiring for the generated API client.
///
/// Owned by `core/`, not by either feature owner, so both app developers can
/// depend on it without either of them owning it.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilpsetu_api/shilpsetu_api.dart';

/// Where the backend lives during development.
///
/// `10.0.2.2` is how the Android emulator reaches the host machine's
/// `localhost`. On a physical device over Wi-Fi, override this with your
/// machine's LAN address:
///
/// ```bash
/// flutter run --dart-define=SHILPSETU_API_BASE_URL=http://192.168.1.42:8000
/// ```
const String kApiBaseUrl = String.fromEnvironment(
  'SHILPSETU_API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: kApiBaseUrl,
      // Generous: an artisan on rural 4G is the design case, not an
      // engineer on office fibre.
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
    ),
  );
});

final apiProvider = Provider<ShilpsetuApi>((ref) {
  return ShilpsetuApi(ref.watch(dioProvider));
});
