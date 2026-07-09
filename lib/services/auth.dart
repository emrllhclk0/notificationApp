import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUsers => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Register user
  Future<String?> createUsers({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        return 'Email ve şifre boş olamaz';
      }
      
      // Check password strength
      if (password.length < 6) {
        return 'Şifre en az 6 karakter olmalıdır';
      }

      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Registration error: ${e.code} - ${e.message}');
      }
      
      switch (e.code) {
        case 'email-already-in-use':
          return 'Bu email adresi zaten kullanımda';
        case 'invalid-email':
          return 'Geçersiz email adresi';
        case 'operation-not-allowed':
          return 'Email/şifre hesapları etkin değil';
        case 'weak-password':
          return 'Şifre çok zayıf';
        default:
          return 'Kayıt olurken bir hata oluştu: ${e.message}';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected registration error: $e');
      }
      return 'Beklenmeyen bir hata oluştu';
    }
  }

  // Login method
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        return 'Email ve şifre boş olamaz';
      }

      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Login error: ${e.code} - ${e.message}');
      }
      
      switch (e.code) {
        case 'invalid-email':
          return 'Geçersiz email adresi';
        case 'user-disabled':
          return 'Bu hesap devre dışı bırakıldı';
        case 'user-not-found':
          return 'Bu email adresine ait bir hesap bulunamadı';
        case 'wrong-password':
          return 'Yanlış şifre';
        default:
          return 'Giriş yapılırken bir hata oluştu: ${e.message}';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected login error: $e');
      }
      return 'Beklenmeyen bir hata oluştu';
    }
  }

  // Sign out method
  Future<String?> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return null; // Success
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
      return 'Çıkış yapılırken bir hata oluştu';
    }
  }
}

