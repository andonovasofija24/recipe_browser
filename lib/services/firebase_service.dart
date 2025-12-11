import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Timezone packages
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'api_service.dart';

class FirebaseService extends ChangeNotifier {
  FirebaseService._private();
  static final FirebaseService instance = FirebaseService._private();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  User? get user => _auth.currentUser;

  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool get initialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;

    // Sign in anonymously
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }

    // Initialize local notifications
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

    await _localNotif.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Request FCM permission
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Handle foreground FCM messages
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      if (msg.notification != null) {
        _showLocalNotification(msg.notification!.title, msg.notification!.body);
      }
    });

    // Handle notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      final id = message.data['mealId'];
      if (id != null) {
        await ApiService.instance.fetchMealDetail(id);
        // Navigate to meal detail if needed
      }
    });

    // Initialize timezone
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Skopje'));

    // Schedule daily reminder (10:00)
    await scheduleDailyReminder(hour: 10, minute: 0);

    _initialized = true;
    notifyListeners();
  }

  // Firestore favorites collection
  CollectionReference<Map<String, dynamic>> favoritesRef() {
    final uid = _auth.currentUser!.uid;
    return _db.collection('users').doc(uid).collection('favorites');
  }

  // Add favorite
  Future<void> addFavorite(Map<String, dynamic> mealJson) async {
    final id = mealJson['idMeal'] as String;
    await favoritesRef().doc(id).set(mealJson);
  }

  // Remove favorite
  Future<void> removeFavorite(String idMeal) async {
    await favoritesRef().doc(idMeal).delete();
  }

  // Check favorite
  Future<bool> isFavorite(String idMeal) async {
    final doc = await favoritesRef().doc(idMeal).get();
    return doc.exists;
  }

  // Watch favorites as stream
  Stream<List<Map<String, dynamic>>> watchFavorites() {
    return favoritesRef().snapshots().map(
      (snap) => snap.docs.map((d) => d.data()).toList(),
    );
  }

  // Show notification
  Future<void> _showLocalNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'daily_channel',
          'Daily reminders',
          channelDescription: 'Daily random recipe reminder',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotif.show(
      0,
      title ?? 'Recipe Browser',
      body ?? 'Check today\'s random recipe!',
      platformDetails,
    );
  }

  // Daily reminder
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'daily_channel',
          'Daily reminders',
          channelDescription: 'Daily random recipe reminder',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotif.zonedSchedule(
      1000,
      'Recipe of the Day',
      'Open the app to see a random recipe!',
      scheduled,
      platformDetails,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
