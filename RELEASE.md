# Günce — Yayın Rehberi (v1.0.0)

Bu dosya, uygulamayı Play Store'a çıkarmak ve ardından reklam ile Premium'u bağlamak için gereken her adımı sırayla anlatır.

## Durum

| Konu | Durum |
|---|---|
| Uygulama (günlük, editör, takvim, istatistik, temalar, çıkartmalar, PIN, hatırlatıcı, yedek, TR/EN) | Hazır |
| AdMob reklam kodu (banner + geçiş reklamı, UMP onay formu) | Hazır, **Google test kimlikleriyle** çalışıyor |
| RevenueCat Premium kodu (satın alma, geri yükleme, Premium kilitleri) | Hazır, **API anahtarı bekleniyor** (o zamana kadar Premium ekranı "Çok yakında" der) |
| Gizlilik politikası ve kullanım koşulları | `store/privacy.html`, `store/terms.html` hazır, yayınlanmayı bekliyor |
| Mağaza metinleri | `store/listing.md` |
| Uygulama ikonu (512 px) | `store/icon-512.png` |
| Yükleme anahtarı (upload key) | Senin oluşturman gerekiyor (aşağıda) |

Paket adı: **com.yusuf.gunce** — ilk yüklemeden sonra değiştirilemez. Farklı bir ad istiyorsan ilk yüklemeden önce söyle.

---

## 1. Gizlilik politikasını yayınla

1. `store/privacy.html` ve `store/terms.html` içindeki `DESTEK_EPOSTA` yazan yerleri destek e-posta adresinle değiştir.
2. İki dosyayı herkese açık bir adreste yayınla. Uygulama şu adresleri bekliyor (Stick Gun sitesinin yanında):
   - `https://pomomate001.github.io/gunce/privacy.html`
   - `https://pomomate001.github.io/gunce/terms.html`
3. Farklı bir adres kullanırsan `lib/config/app_config.dart` içindeki `privacyPolicyUrl` ve `termsUrl` değerlerini güncelle.

## 2. Yükleme anahtarı (bir kez)

Play App Signing açık olacak; Google uygulamanın asıl imza anahtarını saklar, sen yalnızca yükleme anahtarıyla imzalarsın.

```bash
keytool -genkey -v -keystore C:\Users\yusuf\Documents\gunce-anahtar\upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Sonra `android/key.properties` dosyasını oluştur (bu dosya git'e girmez):

```
storePassword=<anahtar deposu şifren>
keyPassword=<anahtar şifren>
keyAlias=upload
storeFile=C:/Users/yusuf/Documents/gunce-anahtar/upload-keystore.jks
```

`.jks` dosyasını ve şifreleri güvenli bir yere yedekle. Bu dosya yokken alınan sürüm derlemeleri hata ayıklama anahtarıyla imzalanır (yalnızca test içindir).

## 3. Sürüm derlemesi (AAB)

Klasör adında "ü" olduğu için Flutter komutları ASCII yoldaki bağlantı klasöründen çalıştırılır (`C:\Users\yusuf\gunce_dev` → bu klasör):

```bash
cd C:\Users\yusuf\gunce_dev && flutter build appbundle --release
```

Çıktı: `build/app/outputs/bundle/release/app-release.aab`. Her yeni yüklemede `pubspec.yaml` içindeki `version: 1.0.0+1` satırının `+` sonrasındaki sayıyı bir artır.

## 4. Play Console

1. **Uygulama oluştur**: ad "Günce: Günlük ve Ruh Hali", varsayılan dil Türkçe, Uygulama, Ücretsiz.
2. **Kapalı test**: 2023 sonrasında açılan kişisel geliştirici hesaplarında, üretime çıkmadan önce en az **12 test kullanıcısının 14 gün boyunca** kapalı teste katılmış olması gerekir. AAB'yi önce "Kapalı test" kanalına yükle.
3. **Uygulama içeriği** bölümleri:
   - Gizlilik politikası: 1. adımdaki adres.
   - Reklamlar: **Evet, reklam içeriyor**.
   - Uygulama erişimi: Tüm işlevler özel erişim olmadan kullanılabilir.
   - Hedef kitle: **13 yaş ve üzeri** (13 altını seçmek Aileler politikasını ve ek reklam kısıtlarını tetikler).
   - İçerik derecelendirmesi: anket; şiddet/kumar vb. yok, kullanıcılar arası iletişim veya paylaşım **yok**.
   - Sağlık uygulamaları: ruh hali günlüğü tıbbi bir hizmet değildir; "sağlık özelliği yok" seçilebilir.
   - Finansal özellikler, devlet uygulaması, haber: Hayır.
4. **Veri güvenliği** formu:
   - Veri toplanıyor mu? **Evet** (reklam ve satın alma SDK'ları yüzünden).
   - Cihaz veya diğer kimlikler (Reklam Kimliği): toplanıyor, **paylaşılıyor** (Google AdMob), amaç: Reklam veya pazarlama, Analiz, Sahtekârlığı önleme.
   - Konum → Yaklaşık konum: toplanıyor (AdMob, IP'den), amaç: Reklam.
   - Uygulama etkinliği / Uygulama bilgileri ve performans (çökme kayıtları, tanılama): toplanıyor (AdMob), amaç: Analiz.
   - Finansal bilgiler → Satın alma geçmişi: toplanıyor (RevenueCat, Premium açılınca), paylaşılmıyor, amaç: Uygulama işlevselliği.
   - Günlük metinleri, fotoğraflar, ses kayıtları: **toplanmıyor** (cihazdan çıkmaz).
   - Aktarım sırasında şifreleme: Evet. Kullanıcı veri silme isteyebilir mi: veriler cihazda; uygulama içinden silinebilir.
5. **Mağaza girişi**: `store/listing.md` metinleri, `store/icon-512.png`, öne çıkan görsel (1024×500) ve en az 2 telefon ekran görüntüsü (`store/screenshots/`).

## 5. AdMob (uygulama Play'de görününce)

1. AdMob → Uygulamalar → Uygulama ekle → Google Play'de yayında → "Günce"yi bağla.
2. İki reklam birimi oluştur: **Banner** (sabit uyarlanabilir) ve **Geçiş reklamı** (Interstitial).
3. Gizlilik ve mesajlaşma → **GDPR mesajı** oluştur ve yayınla (AB kullanıcılarına onay formunu bu mesaj gösterir).
4. Geliştirici web sitenin köküne `app-ads.txt` koy (AdMob'un verdiği satır), ör. `https://pomomate001.github.io/app-ads.txt`. Play Console'daki geliştirici web sitesi bu adres olmalı.
5. Kimlikleri yerleştir (ya da bana gönder, ben yerleştireyim):
   - Uygulama kimliği (`ca-app-pub-…~…`): `android/gradle.properties` → `admobAppId`
   - Banner ve geçiş birimleri (`ca-app-pub-…/…`): `lib/config/app_config.dart` → `bannerUnitId`, `interstitialUnitId`

Reklam kuralları (`lib/config/app_config.dart`): günlük kaydedildiğinde bir geçiş reklamı, uygulamada her 30 dakikalık kullanımda bir geçiş reklamı (yazarken değil, sekme değiştirme gibi doğal bir arada), iki geçiş reklamı arasında en az 2 dakika. Banner yalnızca alt menünün altında tek bir yerde. Premium kullanıcıya hiç reklam yok.

## 6. Premium (RevenueCat + Google Play)

1. Play Console → Para kazanma → Ürünler:
   - **Abonelik**: kimlik `gunce_premium`; temel planlar `monthly` (1 ay) ve `yearly` (1 yıl).
   - **Uygulama içi ürün**: kimlik `gunce_lifetime` (ömür boyu, tek seferlik).
2. RevenueCat → yeni proje → Google Play uygulaması ekle (`com.yusuf.gunce`) → Google Cloud hizmet hesabı JSON'unu yükle (RevenueCat'in "Play Store service credentials" rehberi).
3. RevenueCat → Entitlements → **`pro`** oluştur, üç ürünü bağla.
4. RevenueCat → Offerings → **`default`** (current) teklifine paketleri ekle: Monthly, Annual, Lifetime.
5. RevenueCat → API keys → Google public key (`goog_…`) → `lib/config/app_config.dart` → `revenueCatGoogleApiKey`.
6. Play Console → Lisans testi'ne kendi hesabını ekleyip satın almayı ücretsiz dene.

Anahtar girildiği anda Premium ekranı Play fiyatlarını gösterir, satın alma ve geri yükleme çalışır; kurulum akışının sonunda da Premium teklifi görünür.

## 7. Test sürümleri

- Telefona kurmak için: `build/app/outputs/flutter-apk/app-release.apk`.
- Premium özelliklerini mağaza bağlantısı olmadan denemek için geliştirici sürümü: `flutter build apk --release --dart-define=GUNCE_DEV=true`; Daha fazla sayfasının altındaki sürüm yazısına 7 kez dokununca Premium açılıp kapanır. Mağazaya bu sürüm yüklenmez.

## 8. Geliştirici notları

- Varlık üreticileri `tool/` klasöründe: ruh hali karakterleri (`gen_moods.mjs`), çıkartmalar (`gen_stickers.mjs`, Fluent Emoji MIT), ikon (`gen_icon.mjs`), yazı tipleri (`fonts.py`), ikon fontu (`gen_icons.py`). `cd tool && npm install` sonrası çalışır.
- Yeni dil (v2): `lib/l10n/app_<kod>.arb` ekle, `android/app/build.gradle.kts` içindeki `localeFilters` listesine kodu ekle, `lib/features/more/more_page.dart` ve onboarding'deki dil listesine ekle.
- Web önizleme (yalnızca tasarım için, örnek verilerle): `flutter build web --release --no-wasm-dry-run`, ardından `build/web` klasörünü yerel bir sunucuyla aç; `?reset=1` kurulumu baştan başlatır, `?empty=1` örnek veri yüklemez.
