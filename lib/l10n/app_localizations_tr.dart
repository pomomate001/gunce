// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Günce';

  @override
  String get tagline => 'Her günün, güzel bir sayfayı hak ediyor.';

  @override
  String get getStarted => 'Başlayalım';

  @override
  String get termsLead => 'Devam ederek ';

  @override
  String get terms => 'Kullanım Koşulları';

  @override
  String get termsAnd => '\'nı ve ';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get termsTail => '\'nı kabul etmiş olursun.';

  @override
  String get privacyTitle => 'Gizliliğin bizim için önemli';

  @override
  String get privacyPoint1 =>
      'Günlüklerin yalnızca bu telefonda saklanır. Hesap yok, sunucu yok; yazdıkların bize hiçbir zaman ulaşmaz.';

  @override
  String get privacyPoint2 =>
      'İstediğin zaman sayfalarını PIN ve parmak iziyle kilitleyebilirsin.';

  @override
  String get privacyPoint3 =>
      'Ücretsiz sürüm reklamlarla desteklenir. Reklamların ilgi alanlarına uygun olması için Google Reklam Kimliği\'ni kullanmamıza izin verebilirsin; bu tercihi Ayarlar\'dan dilediğin zaman değiştirebilirsin.';

  @override
  String get acceptPersonalized => 'Kabul ediyorum';

  @override
  String get declinePersonalized => 'Kişiselleştirilmemiş reklam istiyorum';

  @override
  String get findYourStyle => 'Stilini bul';

  @override
  String get findYourStyleHint => 'Temanı dilediğin zaman değiştirebilirsin.';

  @override
  String get continueLabel => 'Devam';

  @override
  String get unlockWithPremium => 'Premium ile aç';

  @override
  String get reminderOnboardTitle => 'Küçük bir alışkanlık';

  @override
  String get reminderOnboardText =>
      'Günde birkaç dakika yazmak zihnini hafifletir. Sana her gün nazikçe hatırlatalım mı?';

  @override
  String get reminderTime => 'Hatırlatma saati';

  @override
  String get change => 'Değiştir';

  @override
  String get remindMe => 'Bana hatırlat';

  @override
  String get notNow => 'Şimdi değil';

  @override
  String get notificationsDenied =>
      'Bildirim izni kapalı. Telefon ayarlarından açabilirsin.';

  @override
  String get navJournal => 'Günlük';

  @override
  String get navCalendar => 'Takvim';

  @override
  String get navInsights => 'İstatistik';

  @override
  String get navMore => 'Daha fazla';

  @override
  String get newEntry => 'Yeni sayfa';

  @override
  String get goodMorning => 'Günaydın';

  @override
  String get goodAfternoon => 'İyi günler';

  @override
  String get goodEvening => 'İyi akşamlar';

  @override
  String get goodNight => 'İyi geceler';

  @override
  String get search => 'Ara';

  @override
  String get chooseTheme => 'Tema seç';

  @override
  String get howAreYouToday => 'Bugün nasılsın?';

  @override
  String get howAreYou => 'Nasıl hissediyorsun?';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count günlük seri',
      zero: 'Henüz seri yok',
    );
    return '$_temp0';
  }

  @override
  String get todayWritten => 'Bugünün sayfası yazıldı. Böyle devam!';

  @override
  String get newPage => 'Yeni sayfa';

  @override
  String get emptyJournalTitle => 'Hikâyen burada başlıyor';

  @override
  String get emptyJournalMessage =>
      'İlk sayfanı yazmak için aşağıdaki + düğmesine dokun.';

  @override
  String get writingPrompts =>
      'Bugün seni ne gülümsetti?|Bugün kendinle gurur duyduğun an neydi?|Şu an neye minnettarsın?|Bugün öğrendiğin küçük bir şey ne?|Bugün seni ne yordu, ne dinlendirdi?|Bugün birine iyilik yaptın mı, ya da biri sana?|Yarın için küçük bir dileğin ne?|Bugünün bir rengi olsaydı hangisi olurdu?|Bugün en çok hangi duyguyu hissettin?|Bugün kendine nasıl iyi davrandın?|Bugün seni şaşırtan ne oldu?|Bu hafta neyi geride bırakmak istiyorsun?|Bugün aklından çıkmayan şarkı hangisi?|Bugün kime teşekkür etmek isterdin?|Bugünü tek bir kelimeyle anlatsan?|Bugün kendini en huzurlu hissettiğin an hangisiydi?|Şu an aklından geçen ilk düşünce ne?|Bugün neyi farklı yapmak isterdin?|Son zamanlarda seni heyecanlandıran ne?|Bugün kendine söylemek istediğin güzel bir söz var mı?';

  @override
  String get titleHint => 'Başlık';

  @override
  String get bodyHint => 'Bugün neler oldu?';

  @override
  String get saved => 'Sayfa kaydedildi';

  @override
  String get emptyEntry =>
      'Boş bir sayfa kaydedilemez. Birkaç kelime yaz ya da ruh halini seç.';

  @override
  String get discardTitle => 'Değişiklikler kaydedilmedi';

  @override
  String get discardMessage =>
      'Şimdi çıkarsan bu sayfadaki değişiklikler kaybolacak.';

  @override
  String get discard => 'Kaydetmeden çık';

  @override
  String get deleteEntryTitle => 'Bu sayfa silinsin mi?';

  @override
  String get deleteEntryMessage =>
      'Sayfa, fotoğrafları ve ses kayıtlarıyla birlikte kalıcı olarak silinecek.';

  @override
  String get delete => 'Sil';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get close => 'Kapat';

  @override
  String get favorite => 'Favori';

  @override
  String get save => 'Kaydet';

  @override
  String get toolPhoto => 'Fotoğraf';

  @override
  String get toolStickers => 'Çıkartma';

  @override
  String get toolVoice => 'Ses';

  @override
  String get toolBackground => 'Arka plan';

  @override
  String get toolFont => 'Yazı tipi';

  @override
  String get addPhoto => 'Fotoğraf ekle';

  @override
  String get takePhoto => 'Fotoğraf çek';

  @override
  String get openGallery => 'Galeriden seç';

  @override
  String get changeEmojiPack => 'Emoji paketini değiştir';

  @override
  String get stickers => 'Çıkartmalar';

  @override
  String get done => 'Tamam';

  @override
  String get background => 'Arka plan';

  @override
  String get font => 'Yazı tipi';

  @override
  String get voiceNote => 'Ses kaydı';

  @override
  String get tapToRecord => 'Kaydetmek için dokun';

  @override
  String get tapToStop => 'Bitirmek için dokun';

  @override
  String get micPermission =>
      'Mikrofon izni gerekiyor. Telefon ayarlarından izin verebilirsin.';

  @override
  String get webPreviewNote => 'Web önizlemesinde ses kaydı sınırlıdır.';

  @override
  String get moodGreat => 'Harika';

  @override
  String get moodHappy => 'Mutlu';

  @override
  String get moodLoved => 'Sevgi dolu';

  @override
  String get moodCalm => 'Sakin';

  @override
  String get moodMeh => 'Öylesine';

  @override
  String get moodAnxious => 'Endişeli';

  @override
  String get moodSad => 'Üzgün';

  @override
  String get moodAngry => 'Kızgın';

  @override
  String get packMochi => 'Mochi';

  @override
  String get packClassic => 'Klasik';

  @override
  String get packBear => 'Ayıcık';

  @override
  String get packBunny => 'Tavşan';

  @override
  String get packPup => 'Pati';

  @override
  String get packCats => 'Kediler';

  @override
  String get packWeather => 'Hava durumu';

  @override
  String get stickersLove => 'Sevgi';

  @override
  String get stickersNature => 'Doğa';

  @override
  String get stickersSky => 'Gökyüzü';

  @override
  String get stickersFood => 'Lezzet';

  @override
  String get stickersAnimals => 'Hayvanlar';

  @override
  String get stickersHobby => 'Hobiler';

  @override
  String get stickersTravel => 'Seyahat';

  @override
  String get stickersParty => 'Kutlama';

  @override
  String get paperPlain => 'Tema';

  @override
  String get paperCream => 'Krem';

  @override
  String get paperLined => 'Çizgili';

  @override
  String get paperDots => 'Noktalı';

  @override
  String get paperGrid => 'Kareli';

  @override
  String get paperPeach => 'Şeftali';

  @override
  String get paperMint => 'Nane';

  @override
  String get paperLilac => 'Leylak';

  @override
  String get paperKraft => 'Kraft';

  @override
  String get paperConfetti => 'Konfeti';

  @override
  String get paperHearts => 'Kalpler';

  @override
  String get paperNight => 'Gece';

  @override
  String get themeDawn => 'Şafak';

  @override
  String get themeOcean => 'Okyanus';

  @override
  String get themeForest => 'Orman';

  @override
  String get themeMidnight => 'Gece yarısı';

  @override
  String get themeLavender => 'Lavanta';

  @override
  String get themeDunes => 'Çöl';

  @override
  String get themeAurora => 'Kutup ışıkları';

  @override
  String get themeWinter => 'Kış';

  @override
  String get themeAutumn => 'Sonbahar';

  @override
  String get themeSakura => 'Sakura';

  @override
  String get themeSunset => 'Gün batımı';

  @override
  String get themeClouds => 'Bulutlar';

  @override
  String get previous => 'Önceki';

  @override
  String get next => 'Sonraki';

  @override
  String entriesThisMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bu ay $count sayfa',
      zero: 'Bu ay henüz sayfa yok',
    );
    return '$_temp0';
  }

  @override
  String get futureDay => 'Bu gün henüz gelmedi.';

  @override
  String get noEntryThisDay => 'Bu güne ait bir sayfa yok.';

  @override
  String get write => 'Yaz';

  @override
  String get insightsTitle => 'İstatistikler';

  @override
  String get streakStart => 'Bugün yazarak serini başlat!';

  @override
  String longestStreak(int count) {
    return 'En uzun serin: $count gün';
  }

  @override
  String get statEntries => 'Sayfa';

  @override
  String get statWords => 'Kelime';

  @override
  String get statPhotos => 'Fotoğraf';

  @override
  String get statVoice => 'Ses kaydı';

  @override
  String get moodBreakdown => 'Ruh hali dağılımı';

  @override
  String get noMoodsYet => 'Bu ay henüz ruh hali kaydı yok.';

  @override
  String mostlyFelt(String mood) {
    return 'Bu ayın baskın ruh hali: $mood';
  }

  @override
  String get moodEntries => 'kayıt';

  @override
  String get moodFlow => 'Ruh hali akışı';

  @override
  String get moodFlowHint => 'Ay boyunca günlerinin iniş çıkışları.';

  @override
  String yearInPixels(int year) {
    return 'Piksellerle $year';
  }

  @override
  String get yearInPixelsHint => 'Her kare bir gün, her renk bir duygu.';

  @override
  String get moreTitle => 'Daha fazla';

  @override
  String get sectionPersonalize => 'Kişiselleştir';

  @override
  String get sectionHabit => 'Alışkanlık';

  @override
  String get sectionSecurity => 'Gizlilik ve güvenlik';

  @override
  String get sectionGeneral => 'Genel';

  @override
  String get sectionData => 'Verilerin';

  @override
  String get sectionSupport => 'Destek';

  @override
  String get appTheme => 'Tema';

  @override
  String get emojiPack => 'Ruh hali emojileri';

  @override
  String get dailyReminder => 'Günlük hatırlatıcı';

  @override
  String reminderAt(String time) {
    return 'Her gün $time';
  }

  @override
  String get off => 'Kapalı';

  @override
  String get on => 'Açık';

  @override
  String get pinLock => 'PIN kilidi';

  @override
  String get biometricUnlock => 'Parmak iziyle aç';

  @override
  String get personalizedAds => 'Kişiselleştirilmiş reklamlar';

  @override
  String get personalizedAdsHint =>
      'Kapalıyken reklamlar ilgi alanlarına göre seçilmez.';

  @override
  String get adPrivacyOptions => 'Reklam gizlilik seçenekleri';

  @override
  String get language => 'Dil';

  @override
  String get weekStart => 'Hafta başlangıcı';

  @override
  String get monday => 'Pazartesi';

  @override
  String get sunday => 'Pazar';

  @override
  String get createBackup => 'Yedek oluştur';

  @override
  String get createBackupHint =>
      'Tüm sayfalar, fotoğraflar ve sesler tek dosyada';

  @override
  String get restoreBackup => 'Yedekten geri yükle';

  @override
  String get localOnlyNote =>
      'Günlüklerin yalnızca bu cihazda saklanır. Telefonunu değiştirmeden önce yedek oluşturup dosyayı güvenli bir yere kaydetmeyi unutma.';

  @override
  String get rateApp => 'Günce\'yi değerlendir';

  @override
  String get shareApp => 'Arkadaşlarınla paylaş';

  @override
  String shareAppText(String url) {
    return 'Günlüğümü Günce ile tutuyorum, sen de dene: $url';
  }

  @override
  String get licenses => 'Lisanslar';

  @override
  String get madeWithLove => 'Sevgiyle tasarlandı ♥';

  @override
  String get premiumActive => 'Premium aktif';

  @override
  String get premiumThanks => 'Desteğin için teşekkürler!';

  @override
  String get premiumPitch =>
      'Tüm temalar, çıkartmalar ve yazı tipleri. Reklam yok.';

  @override
  String get backupShareText => 'Günce yedeğim';

  @override
  String get backupFailed => 'Yedek oluşturulamadı.';

  @override
  String restoreDone(int count) {
    return '$count sayfa geri yüklendi';
  }

  @override
  String get restoreFailed =>
      'Bu dosya bir Günce yedeği değil ya da okunamadı.';

  @override
  String get removePinTitle => 'PIN kilidi kaldırılsın mı?';

  @override
  String get removePinMessage => 'Günlüğün açılırken artık PIN sorulmayacak.';

  @override
  String get remove => 'Kaldır';

  @override
  String get pinSet => 'PIN kilidi açıldı';

  @override
  String get welcomeBack => 'Tekrar hoş geldin';

  @override
  String get enterPin => 'PIN\'ini gir';

  @override
  String get wrongPin => 'PIN yanlış, tekrar dene';

  @override
  String get unlockReason => 'Günce\'yi açmak için doğrula';

  @override
  String get createPin => 'PIN oluştur';

  @override
  String get confirmPin => 'PIN\'i tekrar gir';

  @override
  String get pinHint =>
      '4 haneli bir PIN seç. Unutursan günlüğünü açamazsın; parmak izini de açmanı öneririz.';

  @override
  String get pinMismatch => 'PIN\'ler eşleşmedi. Baştan deneyelim.';

  @override
  String get searchHint => 'Sayfalarında ara';

  @override
  String get favorites => 'Favoriler';

  @override
  String get noResults => 'Sonuç bulunamadı';

  @override
  String get noResultsHint => 'Farklı bir kelime ya da filtre dene.';

  @override
  String resultCount(int count) {
    return '$count sayfa';
  }

  @override
  String get addFavorite => 'Favorilere ekle';

  @override
  String get removeFavorite => 'Favorilerden çıkar';

  @override
  String get edit => 'Düzenle';

  @override
  String get premiumTitle => 'Günce Premium';

  @override
  String get premiumSubtitle => 'Günlüğünü tamamen sana özel hale getir.';

  @override
  String proThemes(int count) {
    return '$count animasyonlu tema';
  }

  @override
  String get proMoodPacks => 'Tüm ruh hali emoji paketleri';

  @override
  String proStickers(int count) {
    return '$count+ çıkartma';
  }

  @override
  String get proFonts => 'Tüm yazı tipleri ve kâğıtlar';

  @override
  String get proNoAds => 'Tamamen reklamsız';

  @override
  String get premiumSoon =>
      'Premium çok yakında geliyor! Şimdilik tüm temel özellikler ücretsiz.';

  @override
  String get comingSoon => 'Çok yakında';

  @override
  String get goPremium => 'Premium\'a geç';

  @override
  String get restorePurchases => 'Satın alımları geri yükle';

  @override
  String get subscriptionNote =>
      'Abonelikler iptal edilmedikçe otomatik olarak yenilenir. Google Play > Abonelikler bölümünden istediğin zaman iptal edebilirsin.';

  @override
  String get planYearly => 'Yıllık';

  @override
  String get planMonthly => 'Aylık';

  @override
  String get planLifetime => 'Ömür boyu';

  @override
  String get perYear => '/yıl';

  @override
  String get perMonth => '/ay';

  @override
  String get bestValue => 'En avantajlı';

  @override
  String get welcomePremium => 'Premium\'a hoş geldin!';

  @override
  String get purchaseFailed => 'Satın alma tamamlanamadı. Lütfen tekrar dene.';

  @override
  String get restoreSuccess => 'Premium geri yüklendi';

  @override
  String get restoreNothing => 'Geri yüklenecek bir satın alma bulunamadı.';

  @override
  String get reminderChannel => 'Günlük hatırlatıcı';

  @override
  String get reminderTitle => 'Bugün nasıldı? ✨';

  @override
  String get reminderBodies =>
      'Birkaç satır yeter. Günün nasıl geçti?|Bugünün küçük bir anını kaybolmadan yakala.|Ruh halini işaretlemek sadece 5 saniye sürer.|Bugün seni ne gülümsetti? Hadi yaz.|Kendine birkaç dakika ayır, sayfan seni bekliyor.|Serini koru! Bugünün sayfası hâlâ boş.|Gün bitmeden içini dök, hafifle.';
}
