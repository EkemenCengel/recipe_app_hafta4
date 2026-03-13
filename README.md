# TarifApp Pro - Mobil Programlama Projesi

Bu proje, Yemek Tarifleri paylaşımını ve keşfedilmesini sağlayan tam kapsamlı bir mobil uygulamadır. Backend tarafında Node.js & MongoDB, Frontend tarafında ise Flutter kullanılarak geliştirilmiştir.

## Özellikler (Features)

*   **Kullanıcı Kimlik Doğrulaması (Auth):** Kayıt olma, giriş yapma ve güvenli JWT (JSON Web Token) altyapısı.
*   **Misafir Modu:** Hesabı olmayan kullanıcıların uygulamaya kısıtlı erişimle (sadece tarifleri görüntüleme) girebilmesi.
*   **Tarif Yönetimi (CRUD):** 
    *   Yeni tarif ekleme (başlık, kategori, malzemeler, yapılış adımları, vb.).
    *   Tarifleri listeleme ve detaylarını görüntüleme.
    *   **Düzenleme ve Silme:** Kullanıcılar sadece **kendi ekledikleri** tarifleri silebilir veya güncelleyebilirler (Frontend ve Backend korumalı).
*   **Dinamik Arama ve Filtreleme:** Ana ekranda canlı arama çubuğu ve kategori bazlı filtreleme.
*   **Puanlama Sistemi:** Giriş yapmış kullanıcıların tariflere 1-5 arası yıldızlı puan verebilmesi ve ortalamanın dinamik hesaplanması.
*   **Favoriler:** Beğenilen tariflerin kişisel favoriler listesine eklenmesi.
*   **Profil:** Kullanıcının adının ve e-posta adresinin dinamik olarak gösterildiği profil sayfası.
*   **Derin Bağlantı (Deep Linking) & Paylaşım:** Her tarifin detay sayfasında bir paylaşım butonu bulunur. `myrecipeapp://tarifler/:id` formatıyla üretilen linke tıklandığında, telefon doğrudan uygulamanın o tarif detayını açar.
*   **Navigasyon Güvenliği:** Doğru yapılandırılmış AppBar ve donanımsal geri buton adaptasyonu.

---

## Kurulum ve Çalıştırma

### 1. Backend (Node.js & Express)

1.  Bilgisayarınızda `Node.js` ve `MongoDB` kurulu olmalıdır.
2.  `backend` klasörüne gidin:
    ```bash
    cd backend
    ```
3.  Gerekli kütüphaneleri yükleyin:
    ```bash
    npm install
    ```
4.  Ortam değişkenlerini yapılandırın:
    *   `backend` klasöründe `.env` adında bir dosya oluşturun veya var olanı düzenleyin.
    *   Örnek `.env` içeriği:
        ```env
        PORT=3000
        MONGO_URI=mongodb://localhost:27017/tarifapp
        JWT_SECRET=sizin_gizli_anahtariniz
        ```
5.  Sunucuyu başlatın:
    ```bash
    npm run dev
    ```
    *veya*
    ```bash
    node server.js
    ```

### 2. Frontend (Flutter)

1.  Bilgisayarınızda `Flutter SDK` kurulu olmalıdır.
2.  `frontend` klasörüne gidin:
    ```bash
    cd frontend
    ```
3.  Gerekli paketleri çekin:
    ```bash
    flutter pub get
    ```
4.  **IP Adresi Ayarı Önemlidir:** Fiziksel bir cihazda veya emülatörde test ediyorsanız, Flutter'ın backend'e bağlanabilmesi için doğru IP adresini göstermeniz gerekir.
    *   `frontend/lib/data/services/auth_service.dart` ve `recipe_service.dart` vb. dosyalarındaki `baseUrl` değişkenini bilgisayarınızın yerel IP adresiyle (örn: `http://192.168.1.5:3000/api`) değiştirin. Emülatör kullanıyorsanız `10.0.2.2` kalabilir.
5.  Uygulamayı başlatın (veya APK derleyin):
    ```bash
    flutter run
    ```
    *APK oluşturmak için:*
    ```bash
    flutter build apk
    ```
    *Derlenen APK konumu:* `frontend/build/app/outputs/flutter-apk/app-release.apk`
