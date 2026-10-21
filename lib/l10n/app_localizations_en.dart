// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Günce';

  @override
  String get tagline => 'Every day deserves a beautiful page.';

  @override
  String get getStarted => 'Let\'s begin';

  @override
  String get termsLead => 'By continuing you accept the ';

  @override
  String get terms => 'Terms of Use';

  @override
  String get termsAnd => ' and the ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsTail => '.';

  @override
  String get privacyTitle => 'Your privacy comes first';

  @override
  String get privacyPoint1 =>
      'Your diary is stored only on this phone. No account, no server: what you write never reaches us.';

  @override
  String get privacyPoint2 =>
      'Lock your pages with a PIN and fingerprint whenever you like.';

  @override
  String get privacyPoint3 =>
      'The free version is supported by ads. You can let us use your Google Advertising ID for more relevant ads and change this anytime in Settings.';

  @override
  String get acceptPersonalized => 'I agree';

  @override
  String get declinePersonalized => 'Use non-personalized ads';

  @override
  String get findYourStyle => 'Find your style';

  @override
  String get findYourStyleHint => 'You can change your theme any time.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get unlockWithPremium => 'Unlock with Premium';

  @override
  String get reminderOnboardTitle => 'A tiny habit';

  @override
  String get reminderOnboardText =>
      'A few minutes of writing a day lightens the mind. Shall we gently remind you?';

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get change => 'Change';

  @override
  String get remindMe => 'Remind me';

  @override
  String get notNow => 'Not now';

  @override
  String get notificationsDenied =>
      'Notifications are off. You can turn them on in your phone settings.';

  @override
  String get navJournal => 'Journal';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navInsights => 'Insights';

  @override
  String get navMore => 'More';

  @override
  String get newEntry => 'New page';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get goodNight => 'Good night';

  @override
  String get search => 'Search';

  @override
  String get chooseTheme => 'Choose a theme';

  @override
  String get howAreYouToday => 'How are you today?';

  @override
  String get howAreYou => 'How do you feel?';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-day streak',
      one: '1-day streak',
      zero: 'No streak yet',
    );
    return '$_temp0';
  }

  @override
  String get todayWritten => 'Today\'s page is written. Keep it up!';

  @override
  String get newPage => 'New page';

  @override
  String get emptyJournalTitle => 'Your story starts here';

  @override
  String get emptyJournalMessage =>
      'Tap the + button below to write your first page.';

  @override
  String get writingPrompts =>
      'What made you smile today?|What moment today are you proud of?|What are you grateful for right now?|What small thing did you learn today?|What tired you out today, and what gave you rest?|Did you do someone a kindness today, or did someone do you one?|What is one small wish for tomorrow?|If today had a colour, which would it be?|Which feeling did you feel most today?|How were you kind to yourself today?|What surprised you today?|What would you like to let go of this week?|Which song is stuck in your head today?|Who would you like to thank today?|If you described today in one word?|When did you feel most at peace today?|What is the first thought on your mind right now?|What would you do differently today?|What has been exciting you lately?|What kind words would you like to tell yourself today?';

  @override
  String get titleHint => 'Title';

  @override
  String get bodyHint => 'What happened today?';

  @override
  String get saved => 'Page saved';

  @override
  String get emptyEntry =>
      'An empty page can\'t be saved. Write a few words or pick a mood.';

  @override
  String get discardTitle => 'Discard changes?';

  @override
  String get discardMessage =>
      'If you leave now, your changes to this page will be lost.';

  @override
  String get discard => 'Discard';

  @override
  String get deleteEntryTitle => 'Delete this page?';

  @override
  String get deleteEntryMessage =>
      'The page will be deleted permanently, together with its photos and voice notes.';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get favorite => 'Favorite';

  @override
  String get save => 'Save';

  @override
  String get toolPhoto => 'Photo';

  @override
  String get toolStickers => 'Stickers';

  @override
  String get toolVoice => 'Voice';

  @override
  String get toolBackground => 'Paper';

  @override
  String get toolFont => 'Font';

  @override
  String get addPhoto => 'Add a photo';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get openGallery => 'From gallery';

  @override
  String get changeEmojiPack => 'Change emoji pack';

  @override
  String get stickers => 'Stickers';

  @override
  String get done => 'Done';

  @override
  String get background => 'Paper';

  @override
  String get font => 'Font';

  @override
  String get voiceNote => 'Voice note';

  @override
  String get tapToRecord => 'Tap to record';

  @override
  String get tapToStop => 'Tap to finish';

  @override
  String get micPermission =>
      'Microphone access is needed. You can allow it in your phone settings.';

  @override
  String get webPreviewNote => 'Recording is limited in the web preview.';

  @override
  String get moodGreat => 'Great';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodLoved => 'Loved';

  @override
  String get moodCalm => 'Calm';

  @override
  String get moodMeh => 'Meh';

  @override
  String get moodAnxious => 'Anxious';

  @override
  String get moodSad => 'Sad';

  @override
  String get moodAngry => 'Angry';

  @override
  String get packMochi => 'Mochi';

  @override
  String get packClassic => 'Classic';

  @override
  String get packBear => 'Teddy';

  @override
  String get packBunny => 'Bunny';

  @override
  String get packPup => 'Puppy';

  @override
  String get packCats => 'Cats';

  @override
  String get packWeather => 'Weather';

  @override
  String get stickersLove => 'Love';

  @override
  String get stickersNature => 'Nature';

  @override
  String get stickersSky => 'Sky';

  @override
  String get stickersFood => 'Food';

  @override
  String get stickersAnimals => 'Animals';

  @override
  String get stickersHobby => 'Hobbies';

  @override
  String get stickersTravel => 'Travel';

  @override
  String get stickersParty => 'Party';

  @override
  String get paperPlain => 'Theme';

  @override
  String get paperCream => 'Cream';

  @override
  String get paperLined => 'Lined';

  @override
  String get paperDots => 'Dotted';

  @override
  String get paperGrid => 'Grid';

  @override
  String get paperPeach => 'Peach';

  @override
  String get paperMint => 'Mint';

  @override
  String get paperLilac => 'Lilac';

  @override
  String get paperKraft => 'Kraft';

  @override
  String get paperConfetti => 'Confetti';

  @override
  String get paperHearts => 'Hearts';

  @override
  String get paperNight => 'Night';

  @override
  String get themeDawn => 'Dawn';

  @override
  String get themeOcean => 'Ocean';

  @override
  String get themeForest => 'Forest';

  @override
  String get themeMidnight => 'Midnight';

  @override
  String get themeLavender => 'Lavender';

  @override
  String get themeDunes => 'Dunes';

  @override
  String get themeAurora => 'Aurora';

  @override
  String get themeWinter => 'Winter';

  @override
  String get themeAutumn => 'Autumn';

  @override
  String get themeSakura => 'Sakura';

  @override
  String get themeSunset => 'Sunset';

  @override
  String get themeClouds => 'Clouds';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String entriesThisMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages this month',
      one: '1 page this month',
      zero: 'No pages this month yet',
    );
    return '$_temp0';
  }

  @override
  String get futureDay => 'This day hasn\'t come yet.';

  @override
  String get noEntryThisDay => 'No page for this day.';

  @override
  String get write => 'Write';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get streakStart => 'Write today to start a streak!';

  @override
  String longestStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return 'Longest streak: $_temp0';
  }

  @override
  String get statEntries => 'Pages';

  @override
  String get statWords => 'Words';

  @override
  String get statPhotos => 'Photos';

  @override
  String get statVoice => 'Voice notes';

  @override
  String get moodBreakdown => 'Mood breakdown';

  @override
  String get noMoodsYet => 'No moods logged this month yet.';

  @override
  String mostlyFelt(String mood) {
    return 'Your most common mood: $mood';
  }

  @override
  String get moodEntries => 'moods';

  @override
  String get moodFlow => 'Mood flow';

  @override
  String get moodFlowHint => 'The ups and downs of your month.';

  @override
  String yearInPixels(int year) {
    return '$year in pixels';
  }

  @override
  String get yearInPixelsHint => 'Each square a day, each colour a feeling.';

  @override
  String get moreTitle => 'More';

  @override
  String get sectionPersonalize => 'Personalize';

  @override
  String get sectionHabit => 'Habit';

  @override
  String get sectionSecurity => 'Privacy & security';

  @override
  String get sectionGeneral => 'General';

  @override
  String get sectionData => 'Your data';

  @override
  String get sectionSupport => 'Support';

  @override
  String get appTheme => 'Theme';

  @override
  String get emojiPack => 'Mood emojis';

  @override
  String get dailyReminder => 'Daily reminder';

  @override
  String reminderAt(String time) {
    return 'Every day at $time';
  }

  @override
  String get off => 'Off';

  @override
  String get on => 'On';

  @override
  String get pinLock => 'PIN lock';

  @override
  String get biometricUnlock => 'Unlock with fingerprint';

  @override
  String get personalizedAds => 'Personalized ads';

  @override
  String get personalizedAdsHint =>
      'When off, ads aren\'t based on your interests.';

  @override
  String get adPrivacyOptions => 'Ad privacy options';

  @override
  String get language => 'Language';

  @override
  String get weekStart => 'Week starts on';

  @override
  String get monday => 'Monday';

  @override
  String get sunday => 'Sunday';

  @override
  String get createBackup => 'Create backup';

  @override
  String get createBackupHint =>
      'All pages, photos and voice notes in one file';

  @override
  String get restoreBackup => 'Restore from backup';

  @override
  String get localOnlyNote =>
      'Your diary lives only on this device. Before switching phones, create a backup and keep the file somewhere safe.';

  @override
  String get rateApp => 'Rate Günce';

  @override
  String get shareApp => 'Share with friends';

  @override
  String shareAppText(String url) {
    return 'I keep my diary in Günce. Try it: $url';
  }

  @override
  String get licenses => 'Licenses';

  @override
  String get madeWithLove => 'Designed with love ♥';

  @override
  String get premiumActive => 'Premium is active';

  @override
  String get premiumThanks => 'Thank you for your support!';

  @override
  String get premiumPitch => 'Every theme, sticker and font. No ads.';

  @override
  String get backupShareText => 'My Günce backup';

  @override
  String get backupFailed => 'Couldn\'t create the backup.';

  @override
  String restoreDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages restored',
      one: '1 page restored',
    );
    return '$_temp0';
  }

  @override
  String get restoreFailed =>
      'This file isn\'t a Günce backup or couldn\'t be read.';

  @override
  String get removePinTitle => 'Remove PIN lock?';

  @override
  String get removePinMessage =>
      'Your diary will open without asking for a PIN.';

  @override
  String get remove => 'Remove';

  @override
  String get pinSet => 'PIN lock is on';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get enterPin => 'Enter your PIN';

  @override
  String get wrongPin => 'Wrong PIN, try again';

  @override
  String get unlockReason => 'Verify to open Günce';

  @override
  String get createPin => 'Create a PIN';

  @override
  String get confirmPin => 'Confirm your PIN';

  @override
  String get pinHint =>
      'Choose a 4-digit PIN. If you forget it you can\'t open your diary, so we suggest turning on fingerprint too.';

  @override
  String get pinMismatch => 'The PINs didn\'t match. Let\'s start over.';

  @override
  String get searchHint => 'Search your pages';

  @override
  String get favorites => 'Favorites';

  @override
  String get noResults => 'No results';

  @override
  String get noResultsHint => 'Try another word or filter.';

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get edit => 'Edit';

  @override
  String get premiumTitle => 'Günce Premium';

  @override
  String get premiumSubtitle => 'Make your diary truly yours.';

  @override
  String proThemes(int count) {
    return '$count animated themes';
  }

  @override
  String get proMoodPacks => 'Every mood emoji pack';

  @override
  String proStickers(int count) {
    return '$count+ stickers';
  }

  @override
  String get proFonts => 'Every font and paper';

  @override
  String get proNoAds => 'No ads, ever';

  @override
  String get premiumSoon =>
      'Premium is coming very soon! All core features are free for now.';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get goPremium => 'Get Premium';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get subscriptionNote =>
      'Subscriptions renew automatically unless cancelled. Cancel anytime in Google Play > Subscriptions.';

  @override
  String get planYearly => 'Yearly';

  @override
  String get planMonthly => 'Monthly';

  @override
  String get planLifetime => 'Lifetime';

  @override
  String get perYear => '/year';

  @override
  String get perMonth => '/month';

  @override
  String get bestValue => 'Best value';

  @override
  String get welcomePremium => 'Welcome to Premium!';

  @override
  String get purchaseFailed =>
      'The purchase couldn\'t be completed. Please try again.';

  @override
  String get restoreSuccess => 'Premium restored';

  @override
  String get restoreNothing => 'No purchases to restore.';

  @override
  String get reminderChannel => 'Daily reminder';

  @override
  String get reminderTitle => 'How was today? ✨';

  @override
  String get reminderBodies =>
      'A few lines are enough. How did your day go?|Catch a small moment from today before it slips away.|Logging your mood takes five seconds.|What made you smile today? Write it down.|Take a few minutes for yourself; your page is waiting.|Keep your streak alive! Today\'s page is still empty.|Let the day out before it ends, and feel lighter.';
}
