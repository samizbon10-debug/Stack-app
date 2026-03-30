import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';

// ==================== SERVICES PROVIDERS ====================

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final googleDriveServiceProvider = Provider<GoogleDriveService>((ref) {
  return GoogleDriveService();
});

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// ==================== AUTH STATE ====================

final authStateProvider = StreamProvider<UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges.asyncMap((user) async {
    if (user == null) return null;
    return await authService.getCurrentUserData();
  });
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});

// ==================== PATIENTS STATE ====================

final patientsStreamProvider = StreamProvider<List<PatientModel>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getPatients();
});

final patientsProvider = Provider<List<PatientModel>>((ref) {
  final patientsAsync = ref.watch(patientsStreamProvider);
  return patientsAsync.maybeWhen(
    data: (patients) => patients,
    orElse: () => [],
  );
});

final patientProvider = FutureProvider.family<PatientModel?, String>((ref, patientId) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return await firebaseService.getPatient(patientId);
});

// ==================== TREATMENTS STATE ====================

final patientTreatmentsProvider = StreamProvider.family<List<TreatmentModel>, String>((ref, patientId) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getTreatments(patientId);
});

final treatmentsByCategoryProvider = StreamProvider.family<List<TreatmentModel>, TreatmentCategory>((ref, category) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getTreatmentsByCategory(category);
});

// ==================== APPOINTMENTS STATE ====================

final appointmentsStreamProvider = StreamProvider<List<AppointmentModel>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getAppointments();
});

final upcomingAppointmentsProvider = StreamProvider<List<AppointmentModel>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getUpcomingAppointments();
});

final appointmentsProvider = Provider<List<AppointmentModel>>((ref) {
  final appointmentsAsync = ref.watch(appointmentsStreamProvider);
  return appointmentsAsync.maybeWhen(
    data: (appointments) => appointments,
    orElse: () => [],
  );
});

// ==================== BACKUP STATUS ====================

final backupStatusProvider = FutureProvider<BackupStatus>((ref) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return await firebaseService.getBackupStatus();
});

// ==================== SEARCH STATE ====================

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<PatientModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  
  final firebaseService = ref.watch(firebaseServiceProvider);
  return await firebaseService.searchPatients(query);
});

// ==================== UI STATE ====================

final selectedPatientIdProvider = StateProvider<String?>((ref) => null);

final selectedTreatmentCategoryProvider = StateProvider<TreatmentCategory?>((ref) => null);

final isOnlineProvider = StateProvider<bool>((ref) => true);

// ==================== NOTIFIER PROVIDERS ====================

class PatientNotifier extends StateNotifier<AsyncValue<List<PatientModel>>> {
  final FirebaseService _firebaseService;
  final CacheService _cacheService;

  PatientNotifier(this._firebaseService, this._cacheService) : super(const AsyncValue.loading());

  Future<void> loadPatients() async {
    state = const AsyncValue.loading();
    try {
      // Try to get from cache first
      final cached = _cacheService.getCachedPatients();
      if (cached.isNotEmpty) {
        state = AsyncValue.data(cached);
      }

      // Then fetch from network
      final patients = await _firebaseService.getPatientsOnce();
      await _cacheService.cachePatients(patients);
      state = AsyncValue.data(patients);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addPatient(PatientModel patient) async {
    try {
      await _firebaseService.createPatient(patient);
      await _cacheService.cachePatient(patient);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePatient(PatientModel patient) async {
    try {
      await _firebaseService.updatePatient(patient);
      await _cacheService.cachePatient(patient);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePatient(String patientId) async {
    try {
      await _firebaseService.deletePatient(patientId);
      await _cacheService.removeCachedPatient(patientId);
    } catch (e) {
      rethrow;
    }
  }
}

final patientNotifierProvider = StateNotifierProvider<PatientNotifier, AsyncValue<List<PatientModel>>>((ref) {
  return PatientNotifier(
    ref.watch(firebaseServiceProvider),
    ref.watch(cacheServiceProvider),
  );
});

// Appointment Notifier
class AppointmentNotifier extends StateNotifier<AsyncValue<List<AppointmentModel>>> {
  final FirebaseService _firebaseService;
  final CacheService _cacheService;
  final NotificationService _notificationService;

  AppointmentNotifier(
    this._firebaseService,
    this._cacheService,
    this._notificationService,
  ) : super(const AsyncValue.loading());

  Future<void> loadAppointments() async {
    state = const AsyncValue.loading();
    try {
      final cached = _cacheService.getCachedAppointments();
      if (cached.isNotEmpty) {
        state = AsyncValue.data(cached);
      }

      final stream = _firebaseService.getAppointments();
      final appointments = await stream.first;
      await _cacheService.cacheAppointments(appointments);
      state = AsyncValue.data(appointments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addAppointment(AppointmentModel appointment) async {
    try {
      String id = await _firebaseService.createAppointment(appointment);
      
      if (appointment.reminderSet) {
        final reminderId = await _notificationService.scheduleAppointmentReminder(
          appointment.copyWith(id: id),
        );
        appointment = appointment.copyWith(reminderId: reminderId);
        await _firebaseService.updateAppointment(appointment);
      }
      
      await _cacheService.cacheAppointment(appointment);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAppointment(AppointmentModel appointment) async {
    try {
      await _firebaseService.updateAppointment(appointment);
      await _cacheService.cacheAppointment(appointment);
      
      if (appointment.reminderId != null) {
        await _notificationService.cancelReminder(appointment.reminderId!);
      }
      
      if (appointment.reminderSet && appointment.status == AppointmentStatus.scheduled) {
        final reminderId = await _notificationService.scheduleAppointmentReminder(appointment);
        appointment = appointment.copyWith(reminderId: reminderId);
        await _firebaseService.updateAppointment(appointment);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firebaseService.deleteAppointment(appointmentId);
      await _cacheService.removeCachedAppointment(appointmentId);
    } catch (e) {
      rethrow;
    }
  }
}

final appointmentNotifierProvider = StateNotifierProvider<AppointmentNotifier, AsyncValue<List<AppointmentModel>>>((ref) {
  return AppointmentNotifier(
    ref.watch(firebaseServiceProvider),
    ref.watch(cacheServiceProvider),
    ref.watch(notificationServiceProvider),
  );
});
