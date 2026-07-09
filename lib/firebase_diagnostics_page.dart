import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseDiagnosticsPage extends StatefulWidget {
  const FirebaseDiagnosticsPage({super.key});

  @override
  State<FirebaseDiagnosticsPage> createState() => _FirebaseDiagnosticsPageState();
}

class _FirebaseDiagnosticsPageState extends State<FirebaseDiagnosticsPage> {
  String _status = 'Testing...';
  Map<String, dynamic> _results = {};
  bool _isTesting = false;

  Future<void> _runDiagnostics() async {
    setState(() {
      _isTesting = true;
      _status = 'Testing...';
      _results = {};
    });

    try {
      // Test Firebase Core
      await _testFirebaseCore();
      
      // Test Firebase Auth
      await _testFirebaseAuth();
      
      // Test Firestore
      await _testFirestore();
      
      // Test FCM
      await _testFCM();
      
      setState(() {
        _status = 'All tests completed successfully!';
        _isTesting = false;
      });
      
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isTesting = false;
      });
    }
  }

  Future<void> _testFirebaseCore() async {
    try {
      final app = Firebase.app();
      _results['firebase_core'] = {
        'status': 'success',
        'name': app.name,
        'options': app.options.projectId,
      };
      debugPrint('Firebase Core: OK');
    } catch (e) {
      _results['firebase_core'] = {
        'status': 'error',
        'message': e.toString(),
      };
      debugPrint('Firebase Core Error: $e');
    }
  }

  Future<void> _testFirebaseAuth() async {
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      _results['firebase_auth'] = {
        'status': 'success',
        'user': user?.email ?? 'Not signed in',
        'uid': user?.uid ?? 'N/A',
      };
      debugPrint('Firebase Auth: OK');
    } catch (e) {
      _results['firebase_auth'] = {
        'status': 'error',
        'message': e.toString(),
      };
      debugPrint('Firebase Auth Error: $e');
    }
  }

  Future<void> _testFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;
      // Test basic operation
      final testDoc = await firestore.collection('test').limit(1).get();
      _results['firestore'] = {
        'status': 'success',
        'documents_count': testDoc.docs.length,
      };
      debugPrint('Firestore: OK');
    } catch (e) {
      _results['firestore'] = {
        'status': 'error',
        'message': e.toString(),
      };
      debugPrint('Firestore Error: $e');
    }
  }

  Future<void> _testFCM() async {
    try {
      final fcm = FirebaseMessaging.instance;
      final token = await fcm.getToken();
      final settings = await fcm.requestPermission();
      
      _results['fcm'] = {
        'status': 'success',
        'token_available': token != null,
        'token_preview': token?.substring(0, 20) ?? 'N/A',
        'authorization_status': settings.authorizationStatus.toString(),
      };
      debugPrint('FCM: OK');
    } catch (e) {
      _results['fcm'] = {
        'status': 'error',
        'message': e.toString(),
      };
      debugPrint('FCM Error: $e');
    }
  }

  // Additional test functions that were previously in main.dart
  Future<void> _testFirestoreConnectivity() async {
    try {
      debugPrint('Testing Firestore connectivity...');
      final collection = FirebaseFirestore.instance.collection('bildirimler');
      final snapshot = await collection.limit(1).get();
      debugPrint(
          'Firestore test successful. Found ${snapshot.docs.length} documents.');
      
      // Add result to diagnostics
      _results['firestore_connectivity'] = {
        'status': 'success',
        'documents_found': snapshot.docs.length,
      };
    } catch (e) {
      debugPrint('Firestore connectivity test failed: $e');
      _results['firestore_connectivity'] = {
        'status': 'error',
        'message': e.toString(),
      };
    }
    setState(() {}); // Update UI
  }

  Future<void> _testFirestorePermissions() async {
    try {
      debugPrint('Testing Firestore read permissions...');

      // Test read permission
      final readTest = await FirebaseFirestore.instance
          .collection('bildirimler')
          .limit(1)
          .get();
      debugPrint(
          'Read test successful. Found ${readTest.docs.length} documents.');

      // Test write permission with a test document
      debugPrint('Testing Firestore write permissions...');
      final testDoc =
          await FirebaseFirestore.instance.collection('bildirimler').add({
        'test': true,
        'timestamp': FieldValue.serverTimestamp(),
        'tester': 'permission_test',
      });
      debugPrint('Write test successful. Test document ID: ${testDoc.id}');

      // Clean up test document
      await testDoc.delete();
      debugPrint('Test document cleaned up.');

      // Add result to diagnostics
      _results['firestore_permissions'] = {
        'status': 'success',
        'read_test': 'OK',
        'write_test': 'OK',
      };

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firebase izinleri doğru çalışıyor!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseException catch (e) {
      debugPrint('Firebase permission test failed: ${e.message}');
      debugPrint('Error code: ${e.code}');

      _results['firestore_permissions'] = {
        'status': 'error',
        'message': e.message,
        'code': e.code,
      };

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firebase izin hatası: ${e.message}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 10),
          ),
        );
      }
    } catch (e) {
      debugPrint('Permission test error: $e');

      _results['firestore_permissions'] = {
        'status': 'error',
        'message': e.toString(),
      };

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İzin testi hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() {}); // Update UI
  }

  Future<void> _testFirebaseConnection() async {
    try {
      debugPrint('Testing Firebase connection...');

      // Test Firebase Authentication
      final auth = FirebaseAuth.instance;
      debugPrint('Firebase Auth instance: $auth');
      debugPrint('Current user: ${auth.currentUser?.email ?? "Not signed in"}');

      // Test Firestore connection
      final firestore = FirebaseFirestore.instance;
      debugPrint('Firestore instance: $firestore');

      // Test basic Firestore operation
      final testCollection = firestore.collection('test_connection');
      final testDoc = testCollection.doc('connection_test');

      // Try to set a test document
      await testDoc.set({
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'connected',
        'test_id': 'firebase_connection_test'
      });

      debugPrint('Successfully wrote to Firestore');

      // Try to read the document back
      final docSnapshot = await testDoc.get();
      if (docSnapshot.exists) {
        debugPrint('Successfully read from Firestore: ${docSnapshot.data()}');

        // Clean up test document
        await testDoc.delete();
        debugPrint('Test document cleaned up');
      }

      // Test FCM token
      final fcm = FirebaseMessaging.instance;
      final token = await fcm.getToken();
      debugPrint(
          'FCM Token: ${token?.substring(0, 20)}...'); // Show first 20 chars for privacy

      // Add result to diagnostics
      _results['firebase_connection'] = {
        'status': 'success',
        'auth_instance': 'OK',
        'firestore_instance': 'OK',
        'firestore_write': 'OK',
        'firestore_read': docSnapshot.exists ? 'OK' : 'Failed',
        'fcm_token_available': token != null,
      };

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firebase bağlantısı başarılı!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseException catch (e) {
      debugPrint('Firebase Error: ${e.code} - ${e.message}');
      
      _results['firebase_connection'] = {
        'status': 'error',
        'message': e.message,
        'code': e.code,
      };

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firebase Hatası: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Connection test error: $e');
      
      _results['firebase_connection'] = {
        'status': 'error',
        'message': e.toString(),
      };

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bağlantı testi hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() {}); // Update UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Diagnostics'),
        backgroundColor: Colors.grey[900],
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.blueGrey[50],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _isTesting ? null : _runDiagnostics,
                  child: Text(_isTesting ? 'Testing...' : 'Run Diagnostics'),
                ),
                ElevatedButton(
                  onPressed: _testFirebaseConnection,
                  child: Text('Test Connection'),
                ),
                ElevatedButton(
                  onPressed: _testFirestorePermissions,
                  child: Text('Test Permissions'),
                ),
                ElevatedButton(
                  onPressed: _testFirestoreConnectivity,
                  child: Text('Test Connectivity'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              _status,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _status.startsWith('Error') ? Colors.red : Colors.green,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: _results.entries.map((entry) {
                  final key = entry.key;
                  final value = entry.value;
                  final status = value['status'];
                  
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                status == 'success' ? Icons.check_circle : Icons.error,
                                color: status == 'success' ? Colors.green : Colors.red,
                              ),
                              SizedBox(width: 10),
                              Text(
                                key.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          ...value.entries.where((e) => e.key != 'status').map((e) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 26.0, bottom: 4.0),
                              child: Text(
                                '${e.key}: ${e.value}',
                                style: TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}