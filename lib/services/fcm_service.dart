import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tasarim/utils/topic_formatter.dart';

// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  // Show notification
  await _showBackgroundNotification(flutterLocalNotificationsPlugin, message);
  
  if (kDebugMode) {
    print('Background message handled: ${message.messageId}');
  }
}

// Show notification when app is in background
Future<void> _showBackgroundNotification(
    FlutterLocalNotificationsPlugin plugin, RemoteMessage message) async {
  try {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'noticlass_bildirimler',
      'Noticlass Notifications',
      channelDescription: 'Notification channel for Noticlass app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await plugin.show(
      0,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  } catch (e) {
    if (kDebugMode) {
      print('Error showing background notification: $e');
    }
  }
}

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  // Store current subscriptions to avoid duplicate operations
  final Set<String> _currentSubscriptions = {};

  // Initialize the service
  Future<void> initialize() async {
    try {
      // Web'de FlutterLocalNotificationsPlugin çalışmıyor, sadece mobile için
      if (!kIsWeb) {
        // Local notifications settings for Android
        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings('@mipmap/ic_launcher');

        // Local notifications settings for iOS
        const DarwinInitializationSettings initializationSettingsIOS =
            DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

        // Initialization settings
        const InitializationSettings initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

        // Initialize local notifications
        await _flutterLocalNotificationsPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: (NotificationResponse response) {
            // Handle notification tap
            if (kDebugMode) {
              print('Notification tapped: ${response.payload}');
            }
          },
        );
      } else {
        if (kDebugMode) {
          print('Web platform detected - skipping FlutterLocalNotificationsPlugin initialization');
        }
      }

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request notification permissions for iOS
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (kDebugMode) {
        print('User permission status: ${settings.authorizationStatus}');
      }

      // Set notification presentation options
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Foreground message received: ${message.notification?.title}');
          print('Data: ${message.data}');
        }

        // Web'de native notification API kullan, mobile'da local notification
        if (kIsWeb) {
          // Web'de tarayıcı native notification API kullanılır
          if (kDebugMode) {
            print('Web: Foreground notification should be handled by browser');
          }
        } else {
          // Show local notification for mobile
          _showNotification(
            message.notification?.title ?? 'New Notification',
            message.notification?.body ?? '',
            message.data,
          );
        }
      });

      // Listen to notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Notification tapped when app was in background: ${message.notification?.title}');
          print('Data: ${message.data}');
        }
      });

      // Print FCM token for debugging (use VAPID key on web)
      // Web'de FCM token almak için önce service worker'ın hazır olduğundan emin ol
      if (kIsWeb) {
        // Service worker'ın hazır olmasını bekle
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      try {
        final String? token = await _firebaseMessaging.getToken(
          vapidKey: kIsWeb
              ? 'BKd-v-zobbgKobQ4lViDu9S3n_nUFdPn78_4NFoOxNYNoGHWtXOpBBCZxGQK05J3jsqlYdi0bZ97ZmThssC5tG0'
              : null,
        );
        
        if (kDebugMode) {
          if (token == null) {
            print('⚠️ FCM TOKEN: null');
            print('   Web push token alınamadı. Olası nedenler:');
            print('   1. Bildirim izni verilmedi');
            print('   2. Service worker kayıtlı değil');
            print('   3. VAPID key hatalı (Firebase Console > Cloud Messaging > Web Push certificates)');
            print('   4. HTTPS/localhost değil');
            print('   5. Flutter service worker ile Firebase service worker çakışması');
          } else {
            print('✅ FCM TOKEN: $token');
          }
        }
      } catch (e) {
        // Yaygın web hataları: messaging/permission-blocked, messaging/unsupported-browser, messaging/invalid-vapid-key
        if (kDebugMode) {
          print('❌ FCM getToken error: $e');
          print('   Error type: ${e.runtimeType}');
          
          final errorString = e.toString().toLowerCase();
          
          if (errorString.contains('permission-blocked') || errorString.contains('permission denied')) {
            print('   → Kullanıcı bildirim iznini reddetti. Tarayıcı ayarlarından izin verin.');
          } else if (errorString.contains('unsupported-browser') || errorString.contains('not supported')) {
            print('   → Tarayıcı push notification desteklemiyor.');
          } else if (errorString.contains('invalid-vapid') || errorString.contains('vapid')) {
            print('   → VAPID key hatalı.');
            print('   → Firebase Console > Project Settings > Cloud Messaging > Web Push certificates');
            print('   → Key pair oluşturun ve public key\'i buraya ekleyin.');
          } else if (errorString.contains('abort') || errorString.contains('registration failed')) {
            print('   → Push service registration hatası.');
            print('   → Olası çözümler:');
            print('     1. Firebase Console\'da VAPID key oluşturun');
            print('     2. Service worker scope kontrol edin');
            print('     3. Tarayıcıyı yeniden başlatın ve cache\'i temizleyin');
            print('     4. HTTPS veya localhost kullandığınızdan emin olun');
          } else if (errorString.contains('messaging')) {
            print('   → Firebase Messaging hatası. Service worker kontrol edin.');
            print('   → web/firebase-messaging-sw.js dosyasının mevcut olduğundan emin olun');
          }
        }
        // Web'de hata olsa bile uygulama çalışmaya devam etsin
        if (!kIsWeb) {
          rethrow;
        }
      }

      // Subscribe to "All Departments" by default
      await updateBolumSubscription('Tüm Bölümler', true);
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing FCM service: $e');
      }
    }
  }

  // Show local notification
  Future<void> _showNotification(
    String title,
    String body,
    Map<String, dynamic>? data,
  ) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'noticlass_bildirimler',
        'Noticlass Notifications',
        channelDescription: 'Notification channel for Noticlass app',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: data?.toString(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error showing local notification: $e');
      }
    }
  }

  // Update department subscription
  Future<void> updateBolumSubscription(String bolum, bool subscribe) async {
    try {
      // Format topic name for FCM (replace Turkish characters and spaces)
      String formattedTopic = TopicFormatter.formatTopicName(bolum);

      // Check if we're already subscribed to avoid duplicate operations
      bool isCurrentlySubscribed = _currentSubscriptions.contains(formattedTopic);
      
      if (subscribe && !isCurrentlySubscribed) {
        await _firebaseMessaging.subscribeToTopic(formattedTopic);
        _currentSubscriptions.add(formattedTopic);
        if (kDebugMode) {
          print('Subscribed to topic: $formattedTopic');
        }
      } else if (!subscribe && isCurrentlySubscribed) {
        await _firebaseMessaging.unsubscribeFromTopic(formattedTopic);
        _currentSubscriptions.remove(formattedTopic);
        if (kDebugMode) {
          print('Unsubscribed from topic: $formattedTopic');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating subscription for $bolum: $e');
      }
    }
  }
  
  // Get current subscriptions
  Set<String> get currentSubscriptions => _currentSubscriptions;
}