import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Shows [child] only when the current user satisfies [requiredRole].
/// Falls back to [fallback] (default: empty) otherwise.
class RoleGuard extends ConsumerWidget {
  final UserRole requiredRole;
  final Widget child;
  final Widget fallback;

  const RoleGuard({
    super.key,
    required this.requiredRole,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    if (user == null) return fallback;

    final allowed = switch (requiredRole) {
      UserRole.admin => user.isAdmin,
      UserRole.doctor => user.isDoctor,
      UserRole.user => true,
    };

    return allowed ? child : fallback;
  }
}
