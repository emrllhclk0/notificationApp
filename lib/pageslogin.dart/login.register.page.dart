import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tasarim/notification_page.dart';
import 'package:tasarim/services/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:tasarim/firebase_diagnostics_page.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  String? errorMessage;
  bool isLogin = true;

  Future<void> signIn() async {
    try {
      // Validate inputs
      if (emailcontroller.text.isEmpty || passwordcontroller.text.isEmpty) {
        setState(() {
          errorMessage = 'Email ve şifre boş olamaz';
        });
        return;
      }

      // Attempt to sign in
      final String? error = await Auth().signIn(
        email: emailcontroller.text,
        password: passwordcontroller.text,
      );

      if (error != null) {
        // Handle login error
        setState(() {
          errorMessage = error;
        });
      } else {
        // Login successful
        if (Auth().currentUsers != null) {
          if (kDebugMode) {
            print('User UID: ${Auth().currentUsers!.uid}');
            print('User email: ${Auth().currentUsers!.email}');
          }
          
          // Navigate to teacher notification page
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => OgretmenBildirimSayfasi()),
            );
          }
        } else {
          setState(() {
            errorMessage = 'Giriş başarısız oldu';
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      
      String friendlyErrorMessage;
      switch (e.code) {
        case 'user-not-found':
          friendlyErrorMessage = 'Bu e-posta adresine kayıtlı bir kullanıcı bulunamadı.';
          break;
        case 'wrong-password':
          friendlyErrorMessage = 'Yanlış şifre girdiniz.';
          break;
        case 'invalid-email':
          friendlyErrorMessage = 'Geçersiz bir e-posta adresi girdiniz.';
          break;
        case 'user-disabled':
          friendlyErrorMessage = 'Bu hesap devre dışı bırakılmış.';
          break;
        case 'too-many-requests':
          friendlyErrorMessage = 'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin.';
          break;
        case 'operation-not-allowed':
          friendlyErrorMessage = 'Bu giriş yöntemi şu anda devre dışı.';
          break;
        case 'network-request-failed':
          friendlyErrorMessage = 'Ağ hatası oluştu. Lütfen internet bağlantınızı kontrol edin.';
          break;
        default:
          friendlyErrorMessage = 'Giriş sırasında bir hata oluştu. Lütfen tekrar deneyin.';
      }
      
      setState(() {
        errorMessage = friendlyErrorMessage;
      });
    } catch (e) {
      // Handle unexpected errors
      setState(() {
        errorMessage = 'Beklenmeyen bir hata oluştu. Lütfen daha sonra tekrar deneyin.';
      });
      if (kDebugMode) {
        print('Unexpected error during sign in: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.grey[50]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FirebaseDiagnosticsPage()),
              );
            },
          ),
        ],
        title: Text("NOTİCLASS APP"),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.blueGrey[50],
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: emailcontroller,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email),
                hintText: "Kullanıcı Adı",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordcontroller,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.password),
                hintText: "Şifre",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            errorMessage != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  )
                : const SizedBox.shrink(),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
                shadowColor: Colors.black,
                elevation: 5,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (isLogin) {
                  signIn();
                }
              },
              child: isLogin
                  ? Text(
                      "Giriş",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}