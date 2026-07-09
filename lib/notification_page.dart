import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasarim/main.dart';
import 'package:tasarim/services/notification_sender_service.dart';

class OgretmenBildirimSayfasi extends StatefulWidget {
  const OgretmenBildirimSayfasi({super.key});

  @override
  State<OgretmenBildirimSayfasi> createState() =>
      _OgretmenBildirimSayfasiState();
}

class _OgretmenBildirimSayfasiState extends State<OgretmenBildirimSayfasi> {
  final TextEditingController _baslikController = TextEditingController();
  final TextEditingController _mesajController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationSenderService _notificationService = NotificationSenderService();

  final List<String> _onemSeviyeleri = ['Az Önemli', 'Önemli', 'Çok Önemli'];
  String _secilenOnem = 'Az Önemli';

  final List<String> _bolumler = [
    'Bilgisayar Programcılığı',
    'Aşçılık',
    'SBS',
    'Gıda İşleme Bölümü',
    'İnşaat Bölümü',
    'Saç ve Güzellik Hizmetleri Bölümü',
  ];

  List<String> _secilenBolumler = [];
  bool _tumBolumlereGonder = false;
  bool _yukleniyor = false;

  Future<void> _bildirimGonder() async {
    // Check if user is authenticated
    if (_auth.currentUser == null) {
      _gosterSnackbar('Önce giriş yapmalısınız!', false);
      debugPrint('User not authenticated');
      return;
    }
    
    debugPrint('User authenticated: ${_auth.currentUser?.email}');

    // Validate input fields
    if (_baslikController.text.isEmpty || _mesajController.text.isEmpty) {
      _gosterSnackbar('Başlık ve mesaj boş olamaz!', false);
      return;
    }

    // Validate department selection
    if (_secilenBolumler.isEmpty && !_tumBolumlereGonder) {
      _gosterSnackbar('En az bir bölüm seçmelisiniz!', false);
      return;
    }

    // Set loading state
    setState(() => _yukleniyor = true);

    // Get current user
    final ogretmen = _auth.currentUser;

    try {
      // Save notification to Firestore
      final hedefBolumler = _tumBolumlereGonder ? _bolumler : _secilenBolumler;
      
      debugPrint('Saving notifications for departments: $hedefBolumler');
      debugPrint('Title: ${_baslikController.text}');
      debugPrint('Content: ${_mesajController.text}');
      debugPrint('Importance: $_secilenOnem');
      debugPrint('Sender email: ${ogretmen?.email}');
      
      // Batch write to Firestore for better performance
      WriteBatch batch = _firestore.batch();
      List<DocumentReference> docRefs = [];
      
      for (var bolum in hedefBolumler) {
        DocumentReference docRef = _firestore.collection('bildirimler').doc();
        batch.set(docRef, {
          'baslik': _baslikController.text,
          'icerik': _mesajController.text,
          'bolum': bolum,
          'onemDerecesi': _secilenOnem,
          'tarih': FieldValue.serverTimestamp(),
          'gonderenAdi': ogretmen?.email ?? 'Bilinmeyen Kullanıcı',
        });
        docRefs.add(docRef);
        debugPrint('Adding notification for department: $bolum');
      }
      
      debugPrint('Committing batch write to Firestore...');
      await batch.commit();
      debugPrint('Successfully committed batch write to Firestore');

      // Send FCM notification
      bool bildirimBasarili = true;
      try {
        if (_tumBolumlereGonder) {
          debugPrint('Sending notification to all departments');
          bildirimBasarili = await _notificationService.sendNotificationToAllBolumler(
            title: _baslikController.text,
            body: _mesajController.text,
            importanceLevel: _secilenOnem,
            senderName: ogretmen?.email ?? 'Bilinmeyen Kullanıcı',
          );
        } else {
          debugPrint('Sending notification to specific departments: $_secilenBolumler');
          bildirimBasarili = await _notificationService.sendNotificationToMultipleBolumler(
            _baslikController.text,
            _mesajController.text,
            _secilenBolumler,
            _secilenOnem,
          );
        }
        debugPrint('FCM notification send result: $bildirimBasarili');
      } catch (fcmError) {
        debugPrint("FCM Error: $fcmError");
        bildirimBasarili = false;
      }

      // Show result to user
      _gosterSnackbar(
        bildirimBasarili 
          ? 'Bildirim gönderildi!' 
          : 'Bildirim kaydedildi ancak anlık bildirim gönderilemedi',
        bildirimBasarili
      );

      // Reset form
      _baslikController.clear();
      _mesajController.clear();
      setState(() {
        _secilenBolumler = [];
        _tumBolumlereGonder = false;
        _secilenOnem = 'Az Önemli';
      });
    } on FirebaseException catch (firebaseError) {
      _gosterSnackbar('Firebase Hatası: ${firebaseError.message}', false);
      debugPrint("Firebase Error Code: ${firebaseError.code}");
      debugPrint("Firebase Error Message: ${firebaseError.message}");
      debugPrint("Firebase Error Details: ${firebaseError.toString()}");
      
      // Show detailed error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firebase Hatası: ${firebaseError.message}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      _gosterSnackbar('Hata: $e', false);
      debugPrint("Error sending notification: $e");
      // Also show a more detailed error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bildirim gönderilirken hata oluştu: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() => _yukleniyor = false);
    }
  }

  void _gosterSnackbar(String mesaj, bool basarili) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj),
        backgroundColor: basarili ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.home, color: Colors.grey[50]),
              onPressed: () {
                // Check if widget is still mounted before using context
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AnaEkran()),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _baslikController,
              decoration: InputDecoration(
                labelText: 'Başlık',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _mesajController,
              decoration: InputDecoration(
                labelText: 'Mesaj',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            SizedBox(height: 12),
            Text('Önem Derecesi:'),
            Wrap(
              spacing: 8,
              children:
                  _onemSeviyeleri.map((seviye) {
                    return ChoiceChip(
                      label: Text(seviye),
                      selected: _secilenOnem == seviye,
                      onSelected: (secildi) {
                        setState(() => _secilenOnem = seviye);
                      },
                    );
                  }).toList(),
            ),
            SizedBox(height: 12),
            SwitchListTile(
              title: Text('Tüm Bölümlere Gönder'),
              value: _tumBolumlereGonder,
              onChanged: (val) {
                setState(() {
                  _tumBolumlereGonder = val;
                  if (val) {
                    _secilenBolumler = List.from(_bolumler);
                  } else {
                    _secilenBolumler = [];
                  }
                });
              },
            ),
            Divider(),
            Text('Bölüm Seçimi:'),
            ..._bolumler.map(
              (bolum) => CheckboxListTile(
                title: Text(bolum),
                value: _secilenBolumler.contains(bolum),
                onChanged:
                    _tumBolumlereGonder
                        ? null
                        : (val) {
                          setState(() {
                            if (val == true) {
                              _secilenBolumler.add(bolum);
                            } else {
                              _secilenBolumler.remove(bolum);
                            }
                          });
                        },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _yukleniyor ? null : _bildirimGonder,
              child: Text(_yukleniyor ? 'Gönderiliyor...' : 'Gönder'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _baslikController.dispose();
    _mesajController.dispose();
    super.dispose();
  }
}