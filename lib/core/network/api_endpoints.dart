class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://bello-horizonte-backend-production.up.railway.app/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';

  // Users
  static const String userProfile = '/users/profile';
  static const String fcmToken = '/users/fcm-token';

  // Admin notifications
  static const String adminNotificationUsers = '/admin/notifications/users';
  static const String adminNotificationSend = '/admin/notifications/send';

  // Doctors
  static const String doctors = '/doctors';
  static String doctorById(String id) => '/doctors/$id';

  // Specialties
  static const String specialties = '/specialties';
  static String specialtyById(String id) => '/specialties/$id';

  // Appointments
  static const String appointments = '/appointments';
  static const String upcomingAppointments = '/appointments/upcoming';
  static const String bookedSlots = '/appointments/booked-slots';
  static String appointmentById(String id) => '/appointments/$id';
  static String cancelAppointment(String id) => '/appointments/$id/cancel';
  static String rescheduleAppointment(String id) => '/appointments/$id/reschedule';

  // Patient records
  static const String patientRecords = '/patient-records';
  static String patientRecordById(String id) => '/patient-records/$id';

  // Doctor (rol médico)
  static const String doctorAgenda = '/doctor/agenda';
  static const String doctorProfile = '/doctor/profile';
  static const String doctorAppointments = '/doctor/appointments';

  // Ratings
  static String rateAppointment(String id) => '/ratings/appointments/$id';
  static String getAppointmentRating(String id) => '/ratings/appointments/$id';

  // Upload
  static const String uploadAvatar = '/upload/avatar';

  // Admin appointments
  static String adminAppointmentsByDoctor(String doctorId) => '/admin/appointments/by-doctor/$doctorId';

  // Admin stats
  static const String adminStats = '/admin/stats';

  // Doctor ratings
  static String doctorRatings(String doctorId) => '/ratings/doctors/$doctorId';

  // Waitlist
  static const String waitlist = '/waitlist';
  static const String myWaitlist = '/waitlist/my';
  static String waitlistEntry(String id) => '/waitlist/$id';
}
