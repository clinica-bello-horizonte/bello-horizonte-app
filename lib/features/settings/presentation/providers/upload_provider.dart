import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class UploadNotifier extends StateNotifier<AsyncValue<String?>> {
  UploadNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;
  final _picker = ImagePicker();

  Future<String?> pickAndUpload() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return null;

    state = const AsyncValue.loading();
    try {
      final file = File(picked.path);
      final bytes = await file.readAsBytes();
      final api = _ref.read(apiClientProvider);

      final result = await api.uploadFile(
        ApiEndpoints.uploadAvatar,
        bytes,
        filename: picked.name,
        mimeType: 'image/jpeg',
      );

      final url = result['photoUrl'] as String?;
      state = AsyncValue.data(url);

      // Actualizar el usuario en el estado de auth
      final authNotifier = _ref.read(authStateProvider.notifier);
      authNotifier.updatePhotoUrl(url);

      return url;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      return null;
    }
  }
}

final uploadProvider =
    StateNotifierProvider<UploadNotifier, AsyncValue<String?>>(
  (ref) => UploadNotifier(ref),
);
