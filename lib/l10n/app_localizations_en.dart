// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tamagotchi';

  @override
  String get welcomeMessage => 'Welcome to Tamagotchi!';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get feed => 'Feed';

  @override
  String get clean => 'Clean';

  @override
  String get play => 'Play';

  @override
  String get sleep => 'Sleep';

  @override
  String get stage => 'Stage';

  @override
  String get age => 'Age';

  @override
  String get stageBaby => 'Baby';

  @override
  String get stageChild => 'Child';

  @override
  String get stageTeen => 'Teen';

  @override
  String get stageAdult => 'Adult';
}
