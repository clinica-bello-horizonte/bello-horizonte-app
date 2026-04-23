import '../constants/app_constants.dart';

class AppValidators {
  AppValidators._();

  static String? validateDni(String? value) {
    if (value == null || value.isEmpty) return 'El DNI es requerido';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'El DNI solo debe contener números';
    if (value.length != AppConstants.dniLength) return 'El DNI debe tener 8 dígitos';
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'El correo electrónico es requerido';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es requerida';
    if (value.length < AppConstants.minPasswordLength) {
      return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres';
    }
    if (value.length > AppConstants.maxPasswordLength) {
      return 'La contraseña es demasiado larga';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    final baseValidation = validatePassword(value);
    if (baseValidation != null) return baseValidation;
    if (value != password) return 'Las contraseñas no coinciden';
    return null;
  }

  static String? validateName(String? value, {String fieldName = 'El nombre'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName es requerido';
    if (value.trim().length < 2) return '$fieldName debe tener al menos 2 caracteres';
    if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s'-]+$").hasMatch(value.trim())) {
      return '$fieldName solo puede contener letras';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'El teléfono es requerido';
    final clean = value.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
    if (!RegExp(r'^\d+$').hasMatch(clean)) return 'Ingresa un número de teléfono válido';
    if (clean.length < AppConstants.minPhoneLength || clean.length > AppConstants.maxPhoneLength) {
      return 'Ingresa un número de teléfono válido (9 dígitos)';
    }
    return null;
  }

  static String? validateRequired(String? value, {required String fieldName}) {
    if (value == null || value.trim().isEmpty) return '$fieldName es requerido';
    return null;
  }

  static String? validateBirthDate(String? value) {
    if (value == null || value.isEmpty) return 'La fecha de nacimiento es requerida';
    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();
      if (date.isAfter(now)) return 'La fecha de nacimiento no puede ser futura';
      if (now.year - date.year > 120) return 'Ingresa una fecha válida';
    } catch (_) {
      return 'Formato de fecha inválido';
    }
    return null;
  }

  static String? validateReason(String? value) {
    if (value == null || value.trim().isEmpty) return 'El motivo de la cita es requerido';
    if (value.trim().length < 10) return 'Describe el motivo con más detalle';
    return null;
  }
}
