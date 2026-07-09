import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:tasarim/utils/topic_formatter.dart';

class NotificationSenderService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  // Firebase Functions instance
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Send notification to a specific department using Cloud Functions
  Future<bool> sendNotificationToBolum(
    String title,
    String body,
    String department,
    String importanceLevel,
  ) async {
    try {
      // Validate inputs
      if (title.isEmpty || body.isEmpty || department.isEmpty) {
        if (kDebugMode) {
          print('Invalid input parameters for sendNotificationToBolum');
        }
        return false;
      }
      
      // Format department name for FCM topic
      String formattedDepartment = TopicFormatter.formatTopicName(department);

      // Prepare data for Cloud Function
      final data = {
        'title': title,
        'body': body,
        'topic': formattedDepartment,
        'importanceLevel': importanceLevel,
      };

      // Call Cloud Function
      final HttpsCallable callable = _functions.httpsCallable('sendNotification');
      final response = await callable.call(data);
      
      if (kDebugMode) {
        print('Cloud Function Response: ${response.data}');
      }

      // Check response status
      if (response.data['success'] == true) {
        return true;
      } else {
        if (kDebugMode) {
          print('Cloud Function reported failure: ${response.data}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error calling Cloud Function sendNotification: $e');
      }
      return false;
    }
  }

  // Send notification to multiple departments using Cloud Functions
  Future<bool> sendNotificationToMultipleBolumler(
    String title,
    String body,
    List<String> departments,
    String importanceLevel,
  ) async {
    try {
      // Validate inputs
      if (title.isEmpty || body.isEmpty || departments.isEmpty) {
        if (kDebugMode) {
          print('Invalid input parameters for sendNotificationToMultipleBolumler');
        }
        return false;
      }
      
      // Format department names for FCM topics
      List<String> formattedDepartments = departments.map((dept) => TopicFormatter.formatTopicName(dept)).toList();

      // Prepare data for Cloud Function
      final data = {
        'title': title,
        'body': body,
        'topics': formattedDepartments,
        'importanceLevel': importanceLevel,
      };

      // Call Cloud Function
      final HttpsCallable callable = _functions.httpsCallable('sendNotificationToMultipleTopics');
      final response = await callable.call(data);
      
      if (kDebugMode) {
        print('Cloud Function Response: ${response.data}');
      }

      // Check response status
      final List<dynamic> results = response.data['results'];
      bool allSuccess = results.every((result) => result['success'] == true);
      
      int successCount = results.where((result) => result['success'] == true).length;
      int failCount = results.length - successCount;
      
      if (kDebugMode) {
        print('Sent notifications to $successCount departments successfully, $failCount failed');
      }

      return allSuccess;
    } catch (e) {
      if (kDebugMode) {
        print('Error calling Cloud Function sendNotificationToMultipleTopics: $e');
      }
      return false;
    }
  }

  // Send notification to all departments (alias for compatibility)
  Future<bool> sendDuyuru({
    required String baslik,
    required String icerik,
    required String bolum,
    required String onemDerecesi,
    required String gonderenAdi,
  }) async {
    return sendNotificationToBolum(baslik, icerik, bolum, onemDerecesi);
  }

  // Send notification to multiple departments (alias for compatibility)
  Future<bool> sendDuyuruToMultipleBolumler(
    String baslik,
    String icerik,
    List<String> bolumler,
    String onemDerecesi,
  ) async {
    return sendNotificationToMultipleBolumler(baslik, icerik, bolumler, onemDerecesi);
  }

  // Send notification to all departments using Cloud Functions
  Future<bool> sendNotificationToAllBolumler({
    required String title,
    required String body,
    required String importanceLevel,
    required String senderName,
  }) async {
    try {
      // Use the actual department names that match the app
      final List<String> allDepartments = [
        'Tüm Bölümler',
        'Bilgisayar Programcılığı',
        'Aşçılık',
        'SBS',
        'Gıda İşleme Bölümü',
        'İnşaat Bölümü',
        'Saç ve Güzellik Hizmetleri Bölümü'
      ];

      // Send notification to all departments
      return await sendNotificationToMultipleBolumler(
        title,
        body,
        allDepartments,
        importanceLevel,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sending notifications to all departments: $e');
      }
      return false;
    }
  }

  // Send notification to all departments (alias for compatibility)
  Future<bool> sendDuyuruToAllBolumler({
    required String baslik,
    required String icerik,
    required String onemDerecesi,
    required String gonderenAdi,
  }) async {
    return sendNotificationToAllBolumler(
      title: baslik,
      body: icerik,
      importanceLevel: onemDerecesi,
      senderName: gonderenAdi,
    );
  }

  // Subscribe to topic
  Future<bool> subscribeToTopic(String topic) async {
    try {
      // Validate input
      if (topic.isEmpty) {
        if (kDebugMode) {
          print('Invalid topic for subscription');
        }
        return false;
      }
      
      String formattedTopic = TopicFormatter.formatTopicName(topic);
      await _firebaseMessaging.subscribeToTopic(formattedTopic);
      
      if (kDebugMode) {
        print('Subscribed to: $formattedTopic');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to topic $topic: $e');
      }
      return false;
    }
  }
  
  // Unsubscribe from topic
  Future<bool> unsubscribeFromTopic(String topic) async {
    try {
      // Validate input
      if (topic.isEmpty) {
        if (kDebugMode) {
          print('Invalid topic for unsubscription');
        }
        return false;
      }
      
      String formattedTopic = TopicFormatter.formatTopicName(topic);
      await _firebaseMessaging.unsubscribeFromTopic(formattedTopic);
      
      if (kDebugMode) {
        print('Unsubscribed from: $formattedTopic');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error unsubscribing from topic $topic: $e');
      }
      return false;
    }
  }
}