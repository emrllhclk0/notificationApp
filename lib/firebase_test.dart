import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

void main() async {
  print('Starting Firebase connection test...');
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✓ Firebase initialized successfully');
    
    // Test Firebase Auth
    final auth = FirebaseAuth.instance;
    print('✓ Firebase Auth instance: $auth');
    print('Current user: ${auth.currentUser?.email ?? "Not signed in"}');
    
    // Test Firestore
    final firestore = FirebaseFirestore.instance;
    print('✓ Firestore instance: $firestore');
    
    // Test basic Firestore operation
    try {
      final testCollection = firestore.collection('test');
      final testDoc = testCollection.doc('connection_test');
      
      // Try to set a test document
      await testDoc.set({
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'connected',
        'test_id': 'firebase_connection_test'
      });
      print('✓ Successfully wrote to Firestore');
      
      // Try to read the document back
      final docSnapshot = await testDoc.get();
      if (docSnapshot.exists) {
        print('✓ Successfully read from Firestore: ${docSnapshot.data()}');
        
        // Clean up test document
        await testDoc.delete();
        print('✓ Test document cleaned up');
      }
    } catch (e) {
      print('⚠ Firestore operation test failed: $e');
    }
    
    // Test FCM
    try {
      final fcm = FirebaseMessaging.instance;
      final token = await fcm.getToken();
      print('✓ FCM Token: ${token?.substring(0, 20)}...'); // Show first 20 chars for privacy
      
      final settings = await fcm.requestPermission();
      print('✓ FCM Permission status: ${settings.authorizationStatus}');
    } catch (e) {
      print('⚠ FCM test failed: $e');
    }
    
    print('\n🎉 All Firebase services tested successfully!');
    
  } catch (e) {
    print('❌ Firebase connection test failed: $e');
  }
}