import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Günce'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Every day deserves a beautiful page.'**
  String get tagline;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s begin'**
  String get getStarted;

  /// No description provided for @termsLead.
  ///
  /// In en, this message translates to:
  /// **'By continuing you accept the '**
  String get termsLead;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get terms;

  /// No description provided for @termsAnd.
  ///
  /// In en, this message translates to:
  /// **' and the '**
  String get termsAnd;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsTail.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get termsTail;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your privacy comes first'**
  String get privacyTitle;

  /// No description provided for @privacyPoint1.
  ///
  /// In en, this message translates to:
  /// **'Your diary is stored only on this phone. No account, no server: what you write never reaches us.'**
  String get privacyPoint1;

  /// No description provided for @privacyPoint2.
  ///
  /// In en, this message translates to:
  /// **'Lock your pages with a PIN and fingerprint whenever you like.'**
  String get privacyPoint2;

  /// No description provided for @privacyPoint3.
  ///
  /// In en, this message translates to:
  /// **'The free version is supported by ads. You can let us use your Google Advertising ID for more relevant ads and change this anytime in Settings.'**
  String get privacyPoint3;

  /// No description provided for @acceptPersonalized.
  ///
  /// In en, this message translates to:
  /// **'I agree'**
  String get acceptPersonalized;

  /// No description provided for @declinePersonalized.
  ///
  /// In en, this message translates to:
  /// **'Use non-personalized ads'**
  String get declinePersonalized;

  /// No description provided for @findYourStyle.
  ///
  /// In en, this message translates to:
  /// **'Find your style'**
  String get findYourStyle;

  /// No description provided for @findYourStyleHint.
  ///
  /// In en, this message translates to:
  /// **'You can change your theme any time.'**
  String get findYourStyleHint;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @unlockWithPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Premium'**
  String get unlockWithPremium;

  /// No description provided for @reminderOnboardTitle.
  ///
  /// In en, this message translates to:
  /// **'A tiny habit'**
  String get reminderOnboardTitle;

  /// No description provided for @reminderOnboardText.
  ///
  /// In en, this message translates to:
  /// **'A few minutes of writing a day lightens the mind. Shall we gently remind you?'**
  String get reminderOnboardText;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @remindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get remindMe;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @notificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off. You can turn them on in your phone settings.'**
  String get notificationsDenied;

  /// No description provided for @navJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get navJournal;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'New page'**
  String get newEntry;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get goodNight;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose a theme'**
  String get chooseTheme;

  /// No description provided for @howAreYouToday.
  ///
  /// In en, this message translates to:
  /// **'How are you today?'**
  String get howAreYouToday;

  /// No description provided for @howAreYou.
  ///
  /// In en, this message translates to:
  /// **'How do you feel?'**
  String get howAreYou;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No streak yet} =1{1-day streak} other{{count}-day streak}}'**
  String streakDays(int count);

  /// No description provided for @todayWritten.
  ///
  /// In en, this message translates to:
  /// **'Today\'s page is written. Keep it up!'**
  String get todayWritten;

  /// No description provided for @newPage.
  ///
  /// In en, this message translates to:
  /// **'New page'**
  String get newPage;

  /// No description provided for @emptyJournalTitle.
  ///
  /// In en, this message translates to:
  /// **'Your story starts here'**
  String get emptyJournalTitle;

  /// No description provided for @emptyJournalMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button below to write your first page.'**
  String get emptyJournalMessage;

  /// No description provided for @writingPrompts.
  ///
  /// In en, this message translates to:
  /// **'What made you smile today?|What moment today are you proud of?|What are you grateful for right now?|What small thing did you learn today?|What tired you out today, and what gave you rest?|Did you do someone a kindness today, or did someone do you one?|What is one small wish for tomorrow?|If today had a colour, which would it be?|Which feeling did you feel most today?|How were you kind to yourself today?|What surprised you today?|What would you like to let go of this week?|Which song is stuck in your head today?|Who would you like to thank today?|If you described today in one word?|When did you feel most at peace today?|What is the first thought on your mind right now?|What would you do differently today?|What has been exciting you lately?|What kind words would you like to tell yourself today?'**
  String get writingPrompts;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleHint;

  /// No description provided for @bodyHint.
  ///
  /// In en, this message translates to:
  /// **'What happened today?'**
  String get bodyHint;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Page saved'**
  String get saved;

  /// No description provided for @emptyEntry.
  ///
  /// In en, this message translates to:
  /// **'An empty page can\'t be saved. Write a few words or pick a mood.'**
  String get emptyEntry;

  /// No description provided for @discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardTitle;

  /// No description provided for @discardMessage.
  ///
  /// In en, this message translates to:
  /// **'If you leave now, your changes to this page will be lost.'**
  String get discardMessage;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @deleteEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this page?'**
  String get deleteEntryTitle;

  /// No description provided for @deleteEntryMessage.
  ///
  /// In en, this message translates to:
  /// **'The page will be deleted permanently, together with its photos and voice notes.'**
  String get deleteEntryMessage;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @toolPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get toolPhoto;

  /// No description provided for @toolStickers.
  ///
  /// In en, this message translates to:
  /// **'Stickers'**
  String get toolStickers;

  /// No description provided for @toolVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get toolVoice;

  /// No description provided for @toolBackground.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get toolBackground;

  /// No description provided for @toolFont.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get toolFont;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get addPhoto;

  /// No description provided for @photoFrame.
  ///
  /// In en, this message translates to:
  /// **'Frame'**
  String get photoFrame;

  /// No description provided for @frameNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get frameNone;

  /// No description provided for @framePolaroid.
  ///
  /// In en, this message translates to:
  /// **'Polaroid'**
  String get framePolaroid;

  /// No description provided for @frameTape.
  ///
  /// In en, this message translates to:
  /// **'Tape'**
  String get frameTape;

  /// No description provided for @frameStamp.
  ///
  /// In en, this message translates to:
  /// **'Stamp'**
  String get frameStamp;

  /// No description provided for @frameFilm.
  ///
  /// In en, this message translates to:
  /// **'Film'**
  String get frameFilm;

  /// No description provided for @fullScreen.
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get fullScreen;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @openGallery.
  ///
  /// In en, this message translates to:
  /// **'From gallery'**
  String get openGallery;

  /// No description provided for @changeEmojiPack.
  ///
  /// In en, this message translates to:
  /// **'Change emoji pack'**
  String get changeEmojiPack;

  /// No description provided for @stickers.
  ///
  /// In en, this message translates to:
  /// **'Stickers'**
  String get stickers;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @background.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get background;

  /// No description provided for @font.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get font;

  /// No description provided for @voiceNote.
  ///
  /// In en, this message translates to:
  /// **'Voice note'**
  String get voiceNote;

  /// No description provided for @tapToRecord.
  ///
  /// In en, this message translates to:
  /// **'Tap to record'**
  String get tapToRecord;

  /// No description provided for @tapToStop.
  ///
  /// In en, this message translates to:
  /// **'Tap to finish'**
  String get tapToStop;

  /// No description provided for @micPermission.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is needed. You can allow it in your phone settings.'**
  String get micPermission;

  /// No description provided for @webPreviewNote.
  ///
  /// In en, this message translates to:
  /// **'Recording is limited in the web preview.'**
  String get webPreviewNote;

  /// No description provided for @moodGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get moodGreat;

  /// No description provided for @moodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodHappy;

  /// No description provided for @moodLoved.
  ///
  /// In en, this message translates to:
  /// **'Loved'**
  String get moodLoved;

  /// No description provided for @moodCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get moodCalm;

  /// No description provided for @moodMeh.
  ///
  /// In en, this message translates to:
  /// **'Meh'**
  String get moodMeh;

  /// No description provided for @moodAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get moodAnxious;

  /// No description provided for @moodSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get moodSad;

  /// No description provided for @moodAngry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get moodAngry;

  /// No description provided for @packMochi.
  ///
  /// In en, this message translates to:
  /// **'Mochi'**
  String get packMochi;

  /// No description provided for @packClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get packClassic;

  /// No description provided for @packBear.
  ///
  /// In en, this message translates to:
  /// **'Teddy'**
  String get packBear;

  /// No description provided for @packBunny.
  ///
  /// In en, this message translates to:
  /// **'Bunny'**
  String get packBunny;

  /// No description provided for @packPup.
  ///
  /// In en, this message translates to:
  /// **'Puppy'**
  String get packPup;

  /// No description provided for @packCats.
  ///
  /// In en, this message translates to:
  /// **'Cats'**
  String get packCats;

  /// No description provided for @packWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get packWeather;

  /// No description provided for @stickersLove.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get stickersLove;

  /// No description provided for @stickersNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get stickersNature;

  /// No description provided for @stickersSky.
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get stickersSky;

  /// No description provided for @stickersFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get stickersFood;

  /// No description provided for @stickersAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get stickersAnimals;

  /// No description provided for @stickersHobby.
  ///
  /// In en, this message translates to:
  /// **'Hobbies'**
  String get stickersHobby;

  /// No description provided for @stickersTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get stickersTravel;

  /// No description provided for @stickersParty.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get stickersParty;

  /// No description provided for @paperPlain.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get paperPlain;

  /// No description provided for @paperCream.
  ///
  /// In en, this message translates to:
  /// **'Cream'**
  String get paperCream;

  /// No description provided for @paperLined.
  ///
  /// In en, this message translates to:
  /// **'Lined'**
  String get paperLined;

  /// No description provided for @paperDots.
  ///
  /// In en, this message translates to:
  /// **'Dotted'**
  String get paperDots;

  /// No description provided for @paperGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get paperGrid;

  /// No description provided for @paperPeach.
  ///
  /// In en, this message translates to:
  /// **'Peach'**
  String get paperPeach;

  /// No description provided for @paperMint.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get paperMint;

  /// No description provided for @paperLilac.
  ///
  /// In en, this message translates to:
  /// **'Lilac'**
  String get paperLilac;

  /// No description provided for @paperKraft.
  ///
  /// In en, this message translates to:
  /// **'Kraft'**
  String get paperKraft;

  /// No description provided for @paperConfetti.
  ///
  /// In en, this message translates to:
  /// **'Confetti'**
  String get paperConfetti;

  /// No description provided for @paperHearts.
  ///
  /// In en, this message translates to:
  /// **'Hearts'**
  String get paperHearts;

  /// No description provided for @paperNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get paperNight;

  /// No description provided for @themeDawn.
  ///
  /// In en, this message translates to:
  /// **'Dawn'**
  String get themeDawn;

  /// No description provided for @themeOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get themeOcean;

  /// No description provided for @themeForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get themeForest;

  /// No description provided for @themeMidnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get themeMidnight;

  /// No description provided for @themeLavender.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get themeLavender;

  /// No description provided for @themeDunes.
  ///
  /// In en, this message translates to:
  /// **'Dunes'**
  String get themeDunes;

  /// No description provided for @themeAurora.
  ///
  /// In en, this message translates to:
  /// **'Aurora'**
  String get themeAurora;

  /// No description provided for @themeWinter.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get themeWinter;

  /// No description provided for @themeAutumn.
  ///
  /// In en, this message translates to:
  /// **'Autumn'**
  String get themeAutumn;

  /// No description provided for @themeSakura.
  ///
  /// In en, this message translates to:
  /// **'Sakura'**
  String get themeSakura;

  /// No description provided for @themeSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get themeSunset;

  /// No description provided for @themeClouds.
  ///
  /// In en, this message translates to:
  /// **'Clouds'**
  String get themeClouds;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @entriesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No pages this month yet} =1{1 page this month} other{{count} pages this month}}'**
  String entriesThisMonth(int count);

  /// No description provided for @futureDay.
  ///
  /// In en, this message translates to:
  /// **'This day hasn\'t come yet.'**
  String get futureDay;

  /// No description provided for @noEntryThisDay.
  ///
  /// In en, this message translates to:
  /// **'No page for this day.'**
  String get noEntryThisDay;

  /// No description provided for @write.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get write;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// No description provided for @streakStart.
  ///
  /// In en, this message translates to:
  /// **'Write today to start a streak!'**
  String get streakStart;

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak: {count, plural, =1{1 day} other{{count} days}}'**
  String longestStreak(int count);

  /// No description provided for @statEntries.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get statEntries;

  /// No description provided for @statWords.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get statWords;

  /// No description provided for @statPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get statPhotos;

  /// No description provided for @statVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice notes'**
  String get statVoice;

  /// No description provided for @moodBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Mood breakdown'**
  String get moodBreakdown;

  /// No description provided for @noMoodsYet.
  ///
  /// In en, this message translates to:
  /// **'No moods logged this month yet.'**
  String get noMoodsYet;

  /// No description provided for @mostlyFelt.
  ///
  /// In en, this message translates to:
  /// **'Your most common mood: {mood}'**
  String mostlyFelt(String mood);

  /// No description provided for @moodEntries.
  ///
  /// In en, this message translates to:
  /// **'moods'**
  String get moodEntries;

  /// No description provided for @moodFlow.
  ///
  /// In en, this message translates to:
  /// **'Mood flow'**
  String get moodFlow;

  /// No description provided for @moodFlowHint.
  ///
  /// In en, this message translates to:
  /// **'The ups and downs of your month.'**
  String get moodFlowHint;

  /// No description provided for @yearInPixels.
  ///
  /// In en, this message translates to:
  /// **'{year} in pixels'**
  String yearInPixels(int year);

  /// No description provided for @yearInPixelsHint.
  ///
  /// In en, this message translates to:
  /// **'Each square a day, each colour a feeling.'**
  String get yearInPixelsHint;

  /// No description provided for @moreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// No description provided for @sectionPersonalize.
  ///
  /// In en, this message translates to:
  /// **'Personalize'**
  String get sectionPersonalize;

  /// No description provided for @sectionHabit.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get sectionHabit;

  /// No description provided for @sectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & security'**
  String get sectionSecurity;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @sectionData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get sectionData;

  /// No description provided for @sectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get sectionSupport;

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get appTheme;

  /// No description provided for @emojiPack.
  ///
  /// In en, this message translates to:
  /// **'Mood emojis'**
  String get emojiPack;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get dailyReminder;

  /// No description provided for @reminderAt.
  ///
  /// In en, this message translates to:
  /// **'Every day at {time}'**
  String reminderAt(String time);

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @pinLock.
  ///
  /// In en, this message translates to:
  /// **'PIN lock'**
  String get pinLock;

  /// No description provided for @biometricUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock with fingerprint'**
  String get biometricUnlock;

  /// No description provided for @personalizedAds.
  ///
  /// In en, this message translates to:
  /// **'Personalized ads'**
  String get personalizedAds;

  /// No description provided for @personalizedAdsHint.
  ///
  /// In en, this message translates to:
  /// **'When off, ads aren\'t based on your interests.'**
  String get personalizedAdsHint;

  /// No description provided for @adPrivacyOptions.
  ///
  /// In en, this message translates to:
  /// **'Ad privacy options'**
  String get adPrivacyOptions;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @weekStart.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get weekStart;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @createBackup.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get createBackup;

  /// No description provided for @createBackupHint.
  ///
  /// In en, this message translates to:
  /// **'All pages, photos and voice notes in one file'**
  String get createBackupHint;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get restoreBackup;

  /// No description provided for @localOnlyNote.
  ///
  /// In en, this message translates to:
  /// **'Your diary lives only on this device. Before switching phones, create a backup and keep the file somewhere safe.'**
  String get localOnlyNote;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate Günce'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share with friends'**
  String get shareApp;

  /// No description provided for @shareAppText.
  ///
  /// In en, this message translates to:
  /// **'I keep my diary in Günce. Try it: {url}'**
  String shareAppText(String url);

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Designed with love ♥'**
  String get madeWithLove;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium is active'**
  String get premiumActive;

  /// No description provided for @premiumThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your support!'**
  String get premiumThanks;

  /// No description provided for @premiumPitch.
  ///
  /// In en, this message translates to:
  /// **'Every theme, sticker and font. No ads.'**
  String get premiumPitch;

  /// No description provided for @backupShareText.
  ///
  /// In en, this message translates to:
  /// **'My Günce backup'**
  String get backupShareText;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the backup.'**
  String get backupFailed;

  /// No description provided for @restoreDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page restored} other{{count} pages restored}}'**
  String restoreDone(int count);

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'This file isn\'t a Günce backup or couldn\'t be read.'**
  String get restoreFailed;

  /// No description provided for @removePinTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove PIN lock?'**
  String get removePinTitle;

  /// No description provided for @removePinMessage.
  ///
  /// In en, this message translates to:
  /// **'Your diary will open without asking for a PIN.'**
  String get removePinMessage;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @pinSet.
  ///
  /// In en, this message translates to:
  /// **'PIN lock is on'**
  String get pinSet;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get enterPin;

  /// No description provided for @wrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN, try again'**
  String get wrongPin;

  /// No description provided for @unlockReason.
  ///
  /// In en, this message translates to:
  /// **'Verify to open Günce'**
  String get unlockReason;

  /// No description provided for @createPin.
  ///
  /// In en, this message translates to:
  /// **'Create a PIN'**
  String get createPin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get confirmPin;

  /// No description provided for @pinHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a 4-digit PIN. If you forget it you can\'t open your diary, so we suggest turning on fingerprint too.'**
  String get pinHint;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'The PINs didn\'t match. Let\'s start over.'**
  String get pinMismatch;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search your pages'**
  String get searchHint;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @noResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try another word or filter.'**
  String get noResultsHint;

  /// No description provided for @resultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String resultCount(int count);

  /// No description provided for @addFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFavorite;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Günce Premium'**
  String get premiumTitle;

  /// No description provided for @premiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make your diary truly yours.'**
  String get premiumSubtitle;

  /// No description provided for @proThemes.
  ///
  /// In en, this message translates to:
  /// **'{count} animated themes'**
  String proThemes(int count);

  /// No description provided for @proMoodPacks.
  ///
  /// In en, this message translates to:
  /// **'Every mood emoji pack'**
  String get proMoodPacks;

  /// No description provided for @proStickers.
  ///
  /// In en, this message translates to:
  /// **'{count}+ stickers'**
  String proStickers(int count);

  /// No description provided for @proFonts.
  ///
  /// In en, this message translates to:
  /// **'Every font and paper'**
  String get proFonts;

  /// No description provided for @proNoAds.
  ///
  /// In en, this message translates to:
  /// **'No ads, ever'**
  String get proNoAds;

  /// No description provided for @premiumSoon.
  ///
  /// In en, this message translates to:
  /// **'Premium is coming very soon! All core features are free for now.'**
  String get premiumSoon;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @goPremium.
  ///
  /// In en, this message translates to:
  /// **'Get Premium'**
  String get goPremium;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @subscriptionNote.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions renew automatically unless cancelled. Cancel anytime in Google Play > Subscriptions.'**
  String get subscriptionNote;

  /// No description provided for @planYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get planYearly;

  /// No description provided for @planMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get planMonthly;

  /// No description provided for @planLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get planLifetime;

  /// No description provided for @perYear.
  ///
  /// In en, this message translates to:
  /// **'/year'**
  String get perYear;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get bestValue;

  /// No description provided for @welcomePremium.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Premium!'**
  String get welcomePremium;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'The purchase couldn\'t be completed. Please try again.'**
  String get purchaseFailed;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Premium restored'**
  String get restoreSuccess;

  /// No description provided for @restoreNothing.
  ///
  /// In en, this message translates to:
  /// **'No purchases to restore.'**
  String get restoreNothing;

  /// No description provided for @reminderChannel.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get reminderChannel;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'How was today? ✨'**
  String get reminderTitle;

  /// No description provided for @reminderBodies.
  ///
  /// In en, this message translates to:
  /// **'A few lines are enough. How did your day go?|Catch a small moment from today before it slips away.|Logging your mood takes five seconds.|What made you smile today? Write it down.|Take a few minutes for yourself; your page is waiting.|Keep your streak alive! Today\'s page is still empty.|Let the day out before it ends, and feel lighter.'**
  String get reminderBodies;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
