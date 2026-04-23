import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/mock_data.dart';

class HealthTip {
  final String id;
  final String title;
  final String body;
  final String icon;
  final String colorHex;

  const HealthTip({
    required this.id,
    required this.title,
    required this.body,
    required this.icon,
    required this.colorHex,
  });
}

final healthTipsProvider = Provider<List<HealthTip>>((ref) {
  return MockData.healthTips
      .map((t) => HealthTip(
            id: t['id'] as String,
            title: t['title'] as String,
            body: t['body'] as String,
            icon: t['icon'] as String,
            colorHex: t['color'] as String,
          ))
      .toList();
});

final currentHealthTipIndexProvider = StateProvider<int>((ref) => 0);

final currentPageIndexProvider = StateProvider<int>((ref) => 0);
