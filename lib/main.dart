import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/entries_controller.dart';
import 'data/entry_store.dart';
import 'data/media_store.dart';
import 'data/settings.dart';
import 'dev/demo_data.dart';
import 'services/ads_service.dart';
import 'services/notification_service.dart';
import 'services/pro_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  _registerLicenses();

  final prefs = await SharedPreferences.getInstance();
  final web = kIsWeb ? Uri.base.queryParameters : const <String, String>{};
  if (web.containsKey('reset')) await prefs.clear();

  final settings = SettingsController(prefs);
  await initializeDateFormatting();
  await MediaStore.instance.init();
  final entries = EntriesController(await EntryStore.open());
  await entries.load();
  if ((kIsWeb || kDemoData) && !web.containsKey('empty')) await seedDemoData(entries, settings);

  final pro = ProController(settings);
  AdsService.instance.attach(settings, pro);
  try {
    await NotificationService.instance.init();
  } catch (e) {
    // Reminders are optional; never let them block the diary from opening.
    debugPrint('notifications unavailable: $e');
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settings),
      ChangeNotifierProvider.value(value: entries),
      ChangeNotifierProvider.value(value: pro),
    ],
    child: const GunceApp(),
  ));

  unawaited(pro.init());
  if (settings.onboarded) unawaited(AdsService.instance.start());
}

void _registerLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(['Fluent Emoji (stickers, emoji packs)'], '''
MIT License

Copyright (c) Microsoft Corporation.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.''');
    yield const LicenseEntryWithLineBreaks(['Phosphor Icons'], '''
MIT License

Copyright (c) 2020-2023 Phosphor Icons

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.''');
    final ofl = await rootBundle.loadString('assets/licenses/OFL.txt');
    yield LicenseEntryWithLineBreaks(
      const ['Fraunces', 'Nunito', 'Lora', 'Caveat', 'Quicksand', 'Playfair Display', 'Dancing Script', 'Comfortaa', 'Patrick Hand', 'Kalam', 'Courier Prime', 'Pacifico', 'Space Mono'],
      ofl,
    );
  });
}
