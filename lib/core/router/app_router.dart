import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/appointments/presentation/pages/appointment_detail_page.dart';
import '../../features/appointments/presentation/pages/appointments_page.dart';
import '../../features/appointments/presentation/pages/create_appointment_page.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/admin/presentation/pages/admin_doctor_appointments_page.dart';
import '../../features/doctor/presentation/pages/doctor_agenda_page.dart';
import '../../features/doctor/presentation/pages/doctor_profile_edit_page.dart';
import '../../features/doctors/presentation/pages/doctor_detail_page.dart';
import '../../features/doctors/presentation/pages/doctor_edit_page.dart';
import '../../features/doctors/presentation/pages/doctors_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/widgets/main_scaffold.dart';
import '../../features/notifications/presentation/pages/admin_notifications_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart' show OnboardingPage, onboardingDoneSyncProvider;
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/patient_history/presentation/pages/patient_history_page.dart';
import '../../features/patient_history/presentation/pages/patient_record_detail_page.dart';
import '../../features/settings/presentation/pages/edit_profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/specialties/presentation/pages/specialties_page.dart';
import '../../features/specialties/presentation/pages/specialty_detail_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState.user != null;
      final isInitializing = authState.isLoading;
      final location = state.matchedLocation;

      final isOnAuthRoute = location == '/login' ||
          location == '/register' ||
          location == '/forgot-password' ||
          location == '/onboarding';

      // Solo redirigir al splash durante el arranque inicial,
      // no durante acciones de login/registro que también ponen isLoading=true
      if (isInitializing) {
        if (location == '/') return null;
        if (isOnAuthRoute) return null; // no interrumpir login/register en curso
        return '/';
      }
      if (location == '/') {
        if (isAuthenticated) return '/home';
        final onboardingDone = ref.read(onboardingDoneSyncProvider);
        return onboardingDone ? '/login' : '/onboarding';
      }

      if (!isAuthenticated && !isOnAuthRoute) return '/login';
      if (isAuthenticated && isOnAuthRoute) return '/home';

      // Doctor only routes (note: /doctor/ not /doctors)
      if (location.startsWith('/doctor/') && authState.user?.role != UserRole.doctor) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => const NoTransitionPage(child: LoginPage()),
      ),
      GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordPage()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingPage()),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/admin/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminNotificationsPage(),
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/doctor/agenda',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DoctorAgendaPage(),
      ),
      GoRoute(
        path: '/doctor/profile/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DoctorProfileEditPage(),
      ),
      GoRoute(
        path: '/admin/doctors/:id/appointments',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final doctor = state.extra;
          return AdminDoctorAppointmentsPage(doctor: doctor as dynamic);
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: '/appointments',
            pageBuilder: (context, state) => const NoTransitionPage(child: AppointmentsPage()),
            routes: [
              GoRoute(
                path: 'create',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return CreateAppointmentPage(
                    initialSpecialtyId: extra?['specialtyId'] as String?,
                    initialDoctorId: extra?['doctorId'] as String?,
                    rescheduleAppointmentId: extra?['rescheduleId'] as String?,
                  );
                },
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => AppointmentDetailPage(
                  appointmentId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/doctors',
            pageBuilder: (context, state) => const NoTransitionPage(child: DoctorsPage()),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => DoctorDetailPage(doctorId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => DoctorEditPage(doctorId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/specialties',
            pageBuilder: (context, state) => const NoTransitionPage(child: SpecialtiesPage()),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => SpecialtyDetailPage(specialtyId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) => const NoTransitionPage(child: PatientHistoryPage()),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => PatientRecordDetailPage(recordId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(child: SettingsPage()),
            routes: [
              GoRoute(
                path: 'edit-profile',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const EditProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Página no encontrada', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextButton(onPressed: () => context.go('/home'), child: const Text('Ir al inicio')),
          ],
        ),
      ),
    ),
  );

  ref.listen<AuthState>(authStateProvider, (_, __) => router.refresh());
  return router;
});
