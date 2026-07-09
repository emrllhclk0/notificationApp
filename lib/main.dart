import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasarim/pageslogin.dart/login.register.page.dart';
import 'package:tasarim/services/fcm_service.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasarim/firebase_diagnostics_page.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Background message: ${message.messageId}");
}

// Create notification channel
Future<void> _createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'noticlass_bildirimler', // id
    'Noticlass Notifications', // title
    description: 'Notification channel for Noticlass app', // description
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    // Create notification channel
    await _createNotificationChannel();

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request notification permissions
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Set notification presentation options
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize FCM service
    await FCMService().initialize();

    runApp(const MyApp());
  } catch (e) {
    debugPrint("Error initializing app: $e");
    // Run app even if initialization fails
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: AnaEkran(), debugShowCheckedModeBanner: false);
  }
}

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  String? secilenBolum;
  final FCMService _fcmService = FCMService();

  @override
  void initState() {
    super.initState();
    // Initialize FCM service
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    try {
      await _fcmService.initialize();
      // Subscribe to "All Departments" by default
      await _fcmService.updateBolumSubscription('Tüm Bölümler', true);
    } catch (e) {
      debugPrint('FCM initialization error: $e');
    }
  }

  // Helper method to update subscription and pop navigator
  Future<void> _updateSubscriptionAndPop(String department) async {
    try {
      await _fcmService.updateBolumSubscription(department, true);
      // Unsubscribe from other topics
      if (secilenBolum != null && secilenBolum != department) {
        await _fcmService.updateBolumSubscription(secilenBolum!, false);
      }
    } catch (e) {
      debugPrint('Error updating FCM subscription: $e');
    }

    // Check if widget is still mounted before using context
    if (mounted) {
      Navigator.pop(context);
    }
  }

  // Helper method for "Tüm Bölümler" subscription
  Future<void> _subscribeToAllDepartments() async {
    try {
      await _fcmService.updateBolumSubscription('Tüm Bölümler', true);
      // Unsubscribe from specific department if needed
      if (secilenBolum != null) {
        await _fcmService.updateBolumSubscription(secilenBolum!, false);
      }
    } catch (e) {
      debugPrint('Error updating FCM subscription: $e');
    }

    // Check if widget is still mounted before using context
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // If user is not authenticated, redirect to login
            if (!snapshot.hasData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginRegisterPage()),
                );
              });
            }

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: Colors.grey[900]),
                  child: Text(
                    'Ardahan Üniversitesi\nTeknik Bilimler Meslek Yüksekokulu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (snapshot.hasData) ...[
                  ListTile(
                    title: Text('Bilgisayar Programcılığı'),
                    onTap: () {
                      setState(() {
                        secilenBolum = 'Bilgisayar Programcılığı';
                      });
                      _updateSubscriptionAndPop('Bilgisayar Programcılığı');
                    },
                  ),
                  ListTile(
                    title: Text('Aşçılık'),
                    onTap: () {
                      setState(() {
                        secilenBolum = 'Aşçılık';
                      });
                      _updateSubscriptionAndPop('Aşçılık');
                    },
                  ),
                  ListTile(
                    title: Text('SBS'),
                    onTap: () {
                      setState(() {
                        secilenBolum = 'SBS';
                      });
                      _updateSubscriptionAndPop('SBS');
                    },
                  ),
                  ListTile(
                    title: Text('Gıda İşletme'),
                    onTap: () {
                      setState(() {
                        secilenBolum = 'Gıda İşleme Bölümü';
                      });
                      _updateSubscriptionAndPop('Gıda İşleme Bölümü');
                    },
                  ),
                  ListTile(
                    title: Text('İnşaat'),
                    onTap: () {
                      setState(() {
                        secilenBolum = 'İnşaat Bölümü';
                      });
                      _updateSubscriptionAndPop('İnşaat Bölümü');
                    },
                  ),
                  ListTile(
                    title: Text('Saç Güzellik Ve Hizmetleri'),
                    onTap: () {
                      setState(() {
                        secilenBolum = 'Saç ve Güzellik Hizmetleri Bölümü';
                      });
                      _updateSubscriptionAndPop(
                          'Saç ve Güzellik Hizmetleri Bölümü');
                    },
                  ),
                  ListTile(
                    title: Text('Tüm Bölümler'),
                    onTap: () {
                      setState(() {
                        secilenBolum = null;
                      });
                      _subscribeToAllDepartments();
                    },
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Firebase Diagnostics'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FirebaseDiagnosticsPage()),
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Çıkış Yap'),
                    onTap: () async {
                      try {
                        await FirebaseAuth.instance.signOut();
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginRegisterPage()),
                          );
                        }
                      } catch (e) {
                        debugPrint('Sign out error: $e');
                      }
                    },
                  ),
                ],
              ],
            );
          },
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.account_circle_outlined, color: Colors.grey[50]),
              onPressed: () {
                // Check if widget is still mounted before using context
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginRegisterPage()),
                  );
                }
              },
            ),
          ),
        ],
        title: Text("NOTICLASS APP"),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.blueGrey[50],
        ),
        backgroundColor: Colors.grey[900],
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          // Firestore query - optimized with better error handling
          stream: (secilenBolum == null
              ? FirebaseFirestore.instance
                  .collection(
                      'bildirimler') // Make sure this matches the collection name used in notification_page.dart
                  .orderBy('tarih', descending: true)
                  .limit(50) // Limit results for better performance
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection(
                      'bildirimler') // Make sure this matches the collection name used in notification_page.dart
                  .where('bolum', isEqualTo: secilenBolum)
                  .orderBy('tarih', descending: true)
                  .limit(50) // Limit results for better performance
                  .snapshots()),
          builder: (context, snapshot) {
            // Debug: Print snapshot information
            debugPrint(
                'Snapshot connection state: ${snapshot.connectionState}');
            if (snapshot.hasError) {
              debugPrint('Snapshot error: ${snapshot.error}');
              // Show more detailed error information
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Veri yüklenirken hata oluştu:'),
                    Text('${snapshot.error}'),
                    Text('Lütfen Firebase izinlerini kontrol edin.'),
                    ElevatedButton(
                      onPressed: () {
                        // Try to reload
                        setState(() {});
                      },
                      child: Text('Tekrar Dene'),
                    ),
                  ],
                ),
              );
            }
            if (snapshot.hasData) {
              debugPrint(
                  'Snapshot data docs count: ${snapshot.data!.docs.length}');
            }

            // Handle connection state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            // Handle error state
            if (snapshot.hasError) {
              return Center(
                  child:
                      Text('Veri yüklenirken hata oluştu: ${snapshot.error}'));
            }

            // Handle empty data
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              debugPrint('No data available or docs is empty');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Henüz duyuru bulunmamaktadır.'),
                    ElevatedButton(
                      onPressed: () {
                        // Try to reload
                        setState(() {});
                      },
                      child: Text('Tekrar Dene'),
                    ),
                  ],
                ),
              );
            }

            debugPrint(
                'Displaying ${snapshot.data!.docs.length} notifications');

            return ListView(
              children: snapshot.data!.docs.map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                // Debug: Print each document data
                debugPrint('Document data: $data');

                return Container(
                  margin: EdgeInsets.all(16.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: _onemDerecesiRenk(
                        data['onemDerecesi'] ?? 'Az Önemli',
                      ),
                      width: 2.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['baslik'] ?? 'Başlık Yok',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: _onemDerecesiRenk(
                                data['onemDerecesi'] ?? 'Az Önemli',
                              ),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              data['onemDerecesi'] ?? 'Az Önemli',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        _tarihFormatla(data['tarih']),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                      ),
                      SizedBox(height: 12.0),
                      Text(
                        data['icerik'] ?? 'İçerik Yok',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Gönderen: ${data['gonderenAdi'] ?? 'Bilinmiyor'}',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  // Helper function to return color based on importance level
  Color _onemDerecesiRenk(String onem) {
    switch (onem) {
      case 'Çok Önemli':
        return Colors.red;
      case 'Önemli':
        return Colors.orange;
      case 'Az Önemli':
      default:
        return Colors.green;
    }
  }

  // Helper function to format timestamp data to readable format
  String _tarihFormatla(dynamic tarihVerisi) {
    if (tarihVerisi is Timestamp) {
      DateTime tarih = tarihVerisi.toDate();
      // Add leading zero for single digit minutes
      String dakika =
          tarih.minute < 10 ? "0${tarih.minute}" : "${tarih.minute}";
      return "${tarih.day}.${tarih.month}.${tarih.year} - ${tarih.hour}:$dakika";
    }
    if (tarihVerisi is String) {
      return tarihVerisi;
    }
    return "";
  }
}