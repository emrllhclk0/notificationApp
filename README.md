# Bildirim Uygulaması (Notification App)

Firebase Cloud Messaging (FCM) kullanarak push bildirimlerini sorunsuz bir şekilde işlemek ve göndermek için tasarlanmış bir Flutter uygulaması.

## 🚀 Özellikler
* **Firebase Entegrasyonu:** Gerçek zamanlı yetenekler için Firebase servislerine güvenli bağlantı.
* **Push Bildirimleri:** Güçlü bildirim iletimi için `fcm_service` ve `notification_sender_service` yapılandırmaları.
* **Kimlik Doğrulama:** Entegre kullanıcı giriş ve kayıt işlemleri.
* **Çoklu Platform (Cross-Platform):** Flutter ile geliştirildi; Android, iOS, Web, Windows, macOS ve Linux destekler.

## 🛠️ Gereksinimler
- Flutter SDK (en son kararlı sürüm)
- Dart SDK
- Firebase hesabı ve yapılandırma ayarları

## 📦 Kurulum & Başlangıç

1. **Depoyu klonlayın:**
   ```bash
   git clone https://github.com/emrllhclk0/notificationApp.git
   ```
2. **Proje dizinine gidin:**
   ```bash
   cd notificationApp
   ```
3. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```
4. **Uygulamayı çalıştırın:**
   ```bash
   flutter run
   ```

## 🏗️ Mimari
Bu proje temiz bir mimari yaklaşım izleyerek; UI (Kullanıcı Arayüzü) bileşenlerini, iş mantığını ve servisleri (örn. Firebase Auth, FCM) birbirinden ayırır.

## 📄 Lisans
Bu proje açık kaynak kodludur ve [MIT Lisansı](LICENSE) altında kullanılabilir.
