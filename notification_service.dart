import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/appointment_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to appointment details
    print('Notification tapped: ${response.payload}');
  }

  Future<bool> requestPermission() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    bool? granted;
    
    if (android != null) {
      granted = await android.requestNotificationsPermission();
    }
    
    if (ios != null) {
      granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return granted ?? false;
  }

  Future<int> scheduleAppointmentReminder(AppointmentModel appointment) async {
    final appointmentTime = appointment.fullDateTime;
    
    // Schedule notification 1 hour before appointment
    final reminderTime = appointmentTime.subtract(const Duration(hours: 1));
    
    // If reminder time is in the past, schedule for 5 minutes from now
    final scheduledTime = reminderTime.isAfter(DateTime.now())
        ? reminderTime
        : DateTime.now().add(const Duration(minutes: 5));

    final notificationId = appointment.id.hashCode;

    await _notifications.zonedSchedule(
      notificationId,
      'Upcoming Appointment',
      '${appointment.patientName} - ${appointment.treatmentType} at ${appointment.time}',
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'appointments',
          'Appointments',
          channelDescription: 'Appointment reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: appointment.id,
    );

    return notificationId;
  }

  Future<void> cancelReminder(int notificationId) async {
    await _notifications.cancel(notificationId);
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'general',
          'General Notifications',
          channelDescription: 'General notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  Future<void> showBackupNotification({
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      999999, // Fixed ID for backup notifications
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'backup',
          'Backup Status',
          channelDescription: 'Backup status notifications',
          importance: Importance.low,
          priority: Priority.low,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );
  }
}
