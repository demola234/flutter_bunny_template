import 'dart:io';
import 'package:mason/mason.dart';

/// Generates localization system if Localization module is selected
void generateLocalizationSystem(HookContext context, String projectName, List<dynamic> modules) {
  // Check if Localization is in the selected modules
  if (!modules.contains('Localization')) {
    context.logger.info('Localization module not selected, skipping localization system generation');
    return;
  }

  context.logger.info('Generating localization system for $projectName');
  
  // Create directory structure
  final directories = [
    'lib/core/localization',
    'lib/core/localization/generated',
  ];

  for (final dir in directories) {
    final directory = Directory('$projectName/$dir');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      context.logger.info('Created directory: $dir');
    }
  }

  // Generate localization files
  _generateLocalizationFile(context, projectName);
  _generateL10nFile(context, projectName);
  _generateL10nYamlFile(context, projectName);
  _generateIntlEnArbFile(context, projectName);
  _generateIntlEsArbFile(context, projectName);
  
  // Generate generated files
  _generateStringsDartFile(context, projectName);
  _generateStringsEnDartFile(context, projectName);
  _generateStringsEsDartFile(context, projectName);

  // Update pubspec.yaml to add localization dependencies
  _updatePubspecForLocalization(context, projectName);
  
  // Update main.dart to initialize localization
  _updateMainForLocalization(context, projectName);

  context.logger.success('Localization system generated successfully!');
}

/// Generates the localization.dart file
void _generateLocalizationFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/localization/localization.dart';
  final content = '''
import 'package:flutter/material.dart';

import 'generated/strings.dart';

/// Extension method to get localized strings easier
extension LocalizationExtension on BuildContext {
  /// Get the translation strings instance
  Strings get strings => Strings.of(this)!;
}

/// Utility methods for localization
class Localization {
  Localization._();
  
  /// Get all available locales
  static List<Locale> get supportedLocales => Strings.supportedLocales;
  
  /// Get all localization delegates
  static List<LocalizationsDelegate<dynamic>> get localizationDelegates => 
      Strings.localizationsDelegates;
  
  /// Get a friendly display name for a locale
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'es':
        return 'Español';
      case 'en':
      default:
        return 'English';
    }
  }
  
  /// Get a display name for the current locale
  static String getCurrentLanguageName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return getLanguageName(locale.languageCode);
  }
  
  /// Get a flag emoji for a language
  static String getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'es':
        return '🇪🇸';
      case 'en':
      default:
        return '🇬🇧';
    }
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the l10n.dart file
void _generateL10nFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/localization/l10n.dart';
  final content = '''
import 'package:flutter/material.dart';

class L10n {
  L10n._();
  
  static final all = [
    const Locale('en'),
    const Locale('es'),
  ];
  
  static String getFlag(String code) {
    switch (code) {
      case 'es':
        return 'Spanish';
      case 'en':
      default:
        return 'English';
    }
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the l10n.yaml file
void _generateL10nYamlFile(HookContext context, String projectName) {
  final filePath = '$projectName/l10n.yaml';
  final content = '''
arb-dir: lib/core/localization
output-dir: lib/core/localization/generated
template-arb-file: intl_en.arb
output-localization-file: strings.dart
output-class: Strings
synthetic-package: false
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the intl_en.arb file with sample translations
void _generateIntlEnArbFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/localization/intl_en.arb';
  final content = '''{
  "@@locale": "en",
  "appTitle": "My App",
  "@appTitle": {
    "description": "The title of the application"
  },
  "welcome": "Welcome",
  "@welcome": {
    "description": "Welcome message"
  },
  "hello": "Hello, {name}",
  "@hello": {
    "description": "A welcome message with a name parameter",
    "placeholders": {
      "name": {
        "type": "String",
        "example": "John"
      }
    }
  },
  "counter": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
  "@counter": {
    "description": "A plural message for counter items",
    "placeholders": {
      "count": {
        "type": "int",
        "format": "compact"
      }
    }
  },
  "signIn": "Sign In",
  "@signIn": {
    "description": "Sign in button text"
  },
  "signUp": "Sign Up",
  "@signUp": {
    "description": "Sign up button text"
  },
  "email": "Email",
  "@email": {
    "description": "Email field label"
  },
  "password": "Password",
  "@password": {
    "description": "Password field label"
  },
  "forgotPassword": "Forgot Password?",
  "@forgotPassword": {
    "description": "Forgot password button text"
  },
  "settings": "Settings",
  "@settings": {
    "description": "Settings menu item"
  },
  "language": "Language",
  "@language": {
    "description": "Language setting"
  },
  "theme": "Theme",
  "@theme": {
    "description": "Theme setting"
  },
  "darkMode": "Dark Mode",
  "@darkMode": {
    "description": "Dark mode setting"
  },
  "lightMode": "Light Mode",
  "@lightMode": {
    "description": "Light mode setting"
  },
  "systemMode": "System Mode",
  "@systemMode": {
    "description": "System theme mode setting"
  }
}''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the intl_es.arb file with Spanish translations
void _generateIntlEsArbFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/localization/intl_es.arb';
  final content = '''{
  "@@locale": "es",
  "appTitle": "Mi Aplicación",
  "welcome": "Bienvenido",
  "hello": "Hola, {name}",
  "counter": "{count, plural, =0{Sin elementos} =1{1 elemento} other{{count} elementos}}",
  "signIn": "Iniciar Sesión",
  "signUp": "Registrarse",
  "email": "Correo electrónico",
  "password": "Contraseña",
  "forgotPassword": "¿Olvidaste tu contraseña?",
  "settings": "Configuración",
  "language": "Idioma",
  "theme": "Tema",
  "darkMode": "Modo Oscuro",
  "lightMode": "Modo Claro",
  "systemMode": "Modo del Sistema"
}''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the generated/strings.dart file
void _generateStringsDartFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/localization/generated/strings.dart';
  final content = '''
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'strings_en.dart';
import 'strings_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of Strings
/// returned by `Strings.of(context)`.
///
/// Applications need to include `Strings.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/strings.dart';
///
/// return MaterialApp(
///   localizationsDelegates: Strings.localizationsDelegates,
///   supportedLocales: Strings.supportedLocales,
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
/// To configure the locales supported by your app, you'll need to edit this
/// file.
///
/// First, open your project's ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project's Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the Strings.supportedLocales
/// property.
abstract class Strings {
  Strings(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static Strings? of(BuildContext context) {
    return Localizations.of<Strings>(context, Strings);
  }

  static const LocalizationsDelegate<Strings> delegate = _StringsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'My App'**
  String get appTitle;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// A welcome message with a name parameter
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String hello(String name);

  /// A plural message for counter items
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String counter(int count);

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Forgot password button text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Settings menu item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Light mode setting
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// System theme mode setting
  ///
  /// In en, this message translates to:
  /// **'System Mode'**
  String get systemMode;
}

class _StringsDelegate extends LocalizationsDelegate<Strings> {
  const _StringsDelegate();

  @override
  Future<Strings> load(Locale locale) {
    return SynchronousFuture<Strings>(lookupStrings(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_StringsDelegate old) => false;
}

Strings lookupStrings(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return StringsEn();
    case 'es': return StringsEs();
  }

  throw FlutterError(
    'Strings.delegate failed to load unsupported locale "${'locale'}". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the generated/strings_en.dart file
void _generateStringsEnDartFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/localization/generated/strings_en.dart';
  final content = '''
import 'package:intl/intl.dart' as intl;

import 'strings.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class StringsEn extends Strings {
  StringsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My App';

  @override
  String get welcome => 'Welcome';

  @override
  String hello(String name) {
    return 'Hello, \$name';
  }

  @override
  String counter(int count) {
    return intl.Intl.pluralLogic(
      count,
      locale: localeName,
      zero: 'No items',
      one: '1 item',
      other: '\$count items',
    );
  }

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemMode => 'System Mode';
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the generated/strings_es.dart file
void _generateStringsEsDartFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/localization/generated/strings_es.dart';
  final content = '''
import 'package:intl/intl.dart' as intl;

import 'strings.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class StringsEs extends Strings {
  StringsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Mi Aplicación';

  @override
  String get welcome => 'Bienvenido';

  @override
  String hello(String name) {
    return 'Hola, \$name';
  }

  @override
  String counter(int count) {
    return intl.Intl.pluralLogic(
      count,
      locale: localeName,
      zero: 'Sin elementos',
      one: '1 elemento',
      other: '\$count elementos',
    );
  }

  @override
  String get signIn => 'Iniciar Sesión';

  @override
  String get signUp => 'Registrarse';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get lightMode => 'Modo Claro';

  @override
  String get systemMode => 'Modo del Sistema';
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Update pubspec.yaml to add localization dependencies
void _updatePubspecForLocalization(HookContext context, String projectName) {
  final pubspecFile = File('$projectName/pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    context.logger.warn('pubspec.yaml not found, skipping adding localization dependencies');
    return;
  }

  String content = pubspecFile.readAsStringSync();
  
  // Make sure flutter_localizations is included
  if (!content.contains('flutter_localizations:')) {
    // Find the position to insert the dependencies
    final sdkDepIndex = content.indexOf('sdk: flutter');
    if (sdkDepIndex != -1) {
      final insertPoint = content.indexOf('\n', sdkDepIndex) + 1;
      
      final localizationDeps = '''
  flutter_localizations:
    sdk: flutter
  intl: any # Use the pinned version from flutter_localizations
''';
      
      content = content.substring(0, insertPoint) + 
               localizationDeps + 
               content.substring(insertPoint);
    }
  }
  
  // Check if the generate: true is in the flutter section
  final flutterSection = content.indexOf('flutter:');
  if (flutterSection != -1) {
    final flutterEndIndex = content.indexOf('\n', flutterSection);
    if (flutterEndIndex != -1) {
      final flutterSectionStart = content.substring(0, flutterEndIndex + 1);
      final flutterSectionEnd = content.substring(flutterEndIndex + 1);
      
      if (!content.contains('generate: true')) {
        content = flutterSectionStart +
                 '  generate: true\n' +
                 flutterSectionEnd;
      }
    }
  }
  
  // Write updated content back to file
  pubspecFile.writeAsStringSync(content);
  context.logger.success('Updated pubspec.yaml with localization dependencies');
}

/// Update main.dart to initialize localization
void _updateMainForLocalization(HookContext context, String projectName) {
  final mainDartFile = File('$projectName/lib/main.dart');
  if (!mainDartFile.existsSync()) {
    context.logger.warn('main.dart not found, skipping localization initialization');
    return;
  }

  String content = mainDartFile.readAsStringSync();
  
  // Add import if not already present
  if (!content.contains('localization.dart')) {
    final importPattern = RegExp(r'import .*;\n');
    final lastImportMatch = importPattern.allMatches(content).lastOrNull;
    
    if (lastImportMatch != null) {
      final insertPosition = lastImportMatch.end;
      content = content.substring(0, insertPosition) +
               "import 'package:$projectName/core/localization/localization.dart';\n" +
               content.substring(insertPosition);
    }
  }
  
  // Update MaterialApp or similar widget to add localization delegates
  final materialAppPattern = RegExp(r'MaterialApp\(');
  final getMatAppPattern = RegExp(r'GetMaterialApp\(');
  
  if (materialAppPattern.hasMatch(content)) {
    // Find a good spot to insert localization properties
    if (!content.contains('localizationsDelegates:') && !content.contains('supportedLocales:')) {
      content = content.replaceAll(
        'MaterialApp(',
        'MaterialApp(\n      localizationsDelegates: Localization.localizationDelegates,\n      supportedLocales: Localization.supportedLocales,\n      // Set initial locale if needed\n      // locale: const Locale(\'en\'),',
      );
    }
  } else if (getMatAppPattern.hasMatch(content)) {
    // Support for GetX
    if (!content.contains('localizationsDelegates:') && !content.contains('supportedLocales:')) {
      content = content.replaceAll(
        'GetMaterialApp(',
        'GetMaterialApp(\n      localizationsDelegates: Localization.localizationDelegates,\n      supportedLocales: Localization.supportedLocales,\n      // Set initial locale if needed\n      // locale: const Locale(\'en\'),',
      );
    }
  }
  
  // Write updated content back to file
  mainDartFile.writeAsStringSync(content);
  context.logger.success('Updated main.dart with localization configuration');
}

/// Generate a language selector widget as an example
void _generateLanguageSelectorWidget(HookContext context, String projectName) {
  final directory = Directory('$projectName/lib/core/localization/widgets');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }
  
  final filePath = '$projectName/lib/core/localization/widgets/language_selector.dart';
  final content = '''
import 'package:flutter/material.dart';

import '../l10n.dart';
import '../localization.dart';

/// A widget to select language in settings
class LanguageSelector extends StatelessWidget {
  /// Callback when language changes
  final Function(Locale) onChanged;

  const LanguageSelector({Key? key, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            context.strings.language,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        ...L10n.all.map((locale) {
          final isSelected = currentLocale.languageCode == locale.languageCode;
          
          return ListTile(
            leading: Text(
              Localization.getLanguageFlag(locale.languageCode),
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(Localization.getLanguageName(locale.languageCode)),
            trailing: isSelected 
              ? const Icon(Icons.check, color: Colors.green) 
              : null,
            onTap: () {
              if (!isSelected) {
                onChanged(locale);
              }
            },
          );
        }).toList(),
      ],
    );
  }
}

/// A simple language toggle for the app bar
class LanguageToggle extends StatelessWidget {
  /// Callback when language changes
  final Function(Locale) onChanged;

  const LanguageToggle({Key? key, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);
    
    return IconButton(
      icon: Text(
        Localization.getLanguageFlag(currentLocale.languageCode),
        style: const TextStyle(fontSize: 24),
      ),
      tooltip: context.strings.language,
      onPressed: () {
        // Simple toggle between English and Spanish
        final newLocale = currentLocale.languageCode == 'en' 
            ? const Locale('es') 
            : const Locale('en');
        onChanged(newLocale);
      },
    );
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created language selector widget: $filePath');
}

/// Generate a LocalizationProvider for state management if using Provider
void _generateLocalizationProvider(HookContext context, String projectName, String stateManagement) {
  if (stateManagement != 'Provider') {
    return;
  }
  
  final filePath = '$projectName/lib/core/localization/providers/localization_provider.dart';
  
  // Create directory if it doesn't exist
  final directory = Directory('$projectName/lib/core/localization/providers');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }
  
  final content = '''
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider to manage application locale
class LocalizationProvider extends ChangeNotifier {
  static const String _localeKey = 'locale';
  Locale _locale = const Locale('en');
  bool _isInitialized = false;
  
  /// Current locale
  Locale get locale => _locale;
  
  /// Is provider initialized
  bool get isInitialized => _isInitialized;
  
  /// Initialize provider and load saved locale
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    
    if (savedLocale != null) {
      _locale = Locale(savedLocale);
    }
    
    _isInitialized = true;
    notifyListeners();
  }
  
  /// Set new locale and save to preferences
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    
    notifyListeners();
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created localization provider: $filePath');
}

/// Generate localization controller for GetX if using GetX
void _generateLocalizationController(HookContext context, String projectName, String stateManagement) {
  if (stateManagement != 'GetX') {
    return;
  }
  
  final filePath = '$projectName/lib/core/localization/controllers/localization_controller.dart';
  
  // Create directory if it doesn't exist
  final directory = Directory('$projectName/lib/core/localization/controllers');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }
  
  final content = '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n.dart';

/// GetX controller for managing application locale
class LocalizationController extends GetxController {
  static const String _localeKey = 'locale';
  
  // Observable locale
  final Rx<Locale> _locale = Rx<Locale>(const Locale('en'));
  
  /// Get current locale
  Locale get locale => _locale.value;
  
  /// Set new locale
  set locale(Locale value) => _locale.value = value;
  
  @override
  void onInit() {
    super.onInit();
    loadSavedLocale();
  }
  
  /// Load saved locale from preferences
  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    
    if (savedLocale != null) {
      _locale.value = Locale(savedLocale);
      
      // Update GetX locale
      Get.updateLocale(_locale.value);
      final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    
    if (savedLocale != null) {
      _locale.value = Locale(savedLocale);
      
      // Update GetX locale
      Get.updateLocale(_locale.value);
    }
  }
  
  /// Set new locale and save to preferences
  Future<void> setLocale(Locale locale) async {
    if (_locale.value == locale) return;
    
    _locale.value = locale;
    
    // Update GetX locale
    Get.updateLocale(locale);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
  
  /// Toggle between available locales
  void toggleLocale() {
    final currentLanguageCode = _locale.value.languageCode;
    final availableLocales = L10n.all;
    
    // Find current index
    final currentIndex = availableLocales.indexWhere(
      (locale) => locale.languageCode == currentLanguageCode
    );
    
    // Get next locale (or first if at the end)
    final nextIndex = (currentIndex + 1) % availableLocales.length;
    final nextLocale = availableLocales[nextIndex];
    
    setLocale(nextLocale);
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created localization controller: $filePath');
}

/// Generate localization BLoC if using BLoC
void _generateLocalizationBloc(HookContext context, String projectName, String stateManagement) {
  if (stateManagement != 'Bloc' && stateManagement != 'BLoC') {
    return;
  }
  
  // Create directories if they don't exist
  final directories = [
    '$projectName/lib/core/localization/bloc',
    '$projectName/lib/core/localization/bloc/state',
    '$projectName/lib/core/localization/bloc/event',
  ];
  
  for (final dir in directories) {
    final directory = Directory(dir);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
  }
  
  // Generate localization state file
  final stateFilePath = '$projectName/lib/core/localization/bloc/state/localization_state.dart';
  final stateContent = '''
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Base state for localization
abstract class LocalizationState extends Equatable {
  const LocalizationState();
  
  @override
  List<Object> get props => [];
}

/// Initial loading state
class LocalizationInitial extends LocalizationState {
  const LocalizationInitial();
}

/// State representing current localization
class LocalizationLoaded extends LocalizationState {
  final Locale locale;
  
  const LocalizationLoaded(this.locale);
  
  @override
  List<Object> get props => [locale.languageCode];
}

/// Error state
class LocalizationError extends LocalizationState {
  final String message;
  
  const LocalizationError(this.message);
  
  @override
  List<Object> get props => [message];
}
''';

  final stateFile = File(stateFilePath);
  stateFile.writeAsStringSync(stateContent);
  context.logger.info('Created file: $stateFilePath');
  
  // Generate localization event file
  final eventFilePath = '$projectName/lib/core/localization/bloc/event/localization_event.dart';
  final eventContent = '''
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Base event for localization
abstract class LocalizationEvent extends Equatable {
  const LocalizationEvent();
  
  @override
  List<Object> get props => [];
}

/// Event to initialize localization
class LocalizationStarted extends LocalizationEvent {
  const LocalizationStarted();
}

/// Event to change locale
class LocalizationChanged extends LocalizationEvent {
  final Locale locale;
  
  const LocalizationChanged(this.locale);
  
  @override
  List<Object> get props => [locale.languageCode];
}
''';

  final eventFile = File(eventFilePath);
  eventFile.writeAsStringSync(eventContent);
  context.logger.info('Created file: $eventFilePath');
  
  // Generate bloc file
  final blocFilePath = '$projectName/lib/core/localization/bloc/localization_bloc.dart';
  final blocContent = '''
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'event/localization_event.dart';
import 'state/localization_state.dart';

/// BLoC for managing application localization
class LocalizationBloc extends Bloc<LocalizationEvent, LocalizationState> {
  static const String _localeKey = 'locale';
  
  LocalizationBloc() : super(const LocalizationInitial()) {
    on<LocalizationStarted>(_onStarted);
    on<LocalizationChanged>(_onChanged);
  }
  
  /// Handle initialization
  Future<void> _onStarted(
    LocalizationStarted event,
    Emitter<LocalizationState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString(_localeKey);
      
      if (savedLocale != null) {
        emit(LocalizationLoaded(Locale(savedLocale)));
      } else {
        emit(const LocalizationLoaded(Locale('en')));
      }
    } catch (e) {
      emit(LocalizationError(e.toString()));
      emit(const LocalizationLoaded(Locale('en')));
    }
  }
  
  /// Handle locale change
  Future<void> _onChanged(
    LocalizationChanged event,
    Emitter<LocalizationState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, event.locale.languageCode);
      
      emit(LocalizationLoaded(event.locale));
    } catch (e) {
      emit(LocalizationError(e.toString()));
    }
  }
}
''';

  final blocFile = File(blocFilePath);
  blocFile.writeAsStringSync(blocContent);
  context.logger.info('Created file: $blocFilePath');
}

/// Generate localization repository for Clean Architecture
void _generateLocalizationRepository(HookContext context, String projectName, String architecture) {
  if (architecture != 'Clean Architecture') {
    return;
  }
  
  // Create directories
  final directories = [
    '$projectName/lib/core/localization/domain/repositories',
    '$projectName/lib/core/localization/domain/usecases',
    '$projectName/lib/core/localization/data/repositories',
    '$projectName/lib/core/localization/data/datasources',
  ];
  
  for (final dir in directories) {
    final directory = Directory(dir);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
  }
  
  // Generate repository interface
  final repoPath = '$projectName/lib/core/localization/domain/repositories/localization_repository.dart';
  final repoContent = '''
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../error/failures/failure.dart';

/// Repository interface for localization
abstract class LocalizationRepository {
  /// Get the current locale
  Future<Either<Failure, Locale>> getCurrentLocale();
  
  /// Set a new locale
  Future<Either<Failure, void>> setLocale(Locale locale);
  
  /// Get the list of supported locales
  Future<Either<Failure, List<Locale>>> getSupportedLocales();
}
''';

  final repoFile = File(repoPath);
  repoFile.writeAsStringSync(repoContent);
  context.logger.info('Created file: $repoPath');
  
  // Generate data source interface
  final dsPath = '$projectName/lib/core/localization/data/datasources/localization_data_source.dart';
  final dsContent = '''
import 'package:flutter/material.dart';

/// Data source interface for localization
abstract class LocalizationDataSource {
  /// Get the current locale
  Future<Locale> getCurrentLocale();
  
  /// Set a new locale
  Future<void> setLocale(Locale locale);
  
  /// Get the list of supported locales
  Future<List<Locale>> getSupportedLocales();
}

/// Implementation of LocalizationDataSource using shared preferences
class LocalizationLocalDataSource implements LocalizationDataSource {
  static const String _localeKey = 'locale';
  final SharedPreferences _prefs;
  
  LocalizationLocalDataSource(this._prefs);
  
  @override
  Future<Locale> getCurrentLocale() async {
    final savedLocale = _prefs.getString(_localeKey);
    return Locale(savedLocale ?? 'en');
  }
  
  @override
  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_localeKey, locale.languageCode);
  }
  
  @override
  Future<List<Locale>> getSupportedLocales() async {
    return const [
      Locale('en'),
      Locale('es'),
    ];
  }
}
''';

  final dsFile = File(dsPath);
  dsFile.writeAsStringSync(dsContent);
  context.logger.info('Created file: $dsPath');
  
  // Add import at the top of the file
  final importLine = "import 'package:shared_preferences/shared_preferences.dart';\n\n";
  final dsFileContent = dsFile.readAsStringSync();
  dsFile.writeAsStringSync(importLine + dsFileContent);
  
  // Generate repository implementation
  final repoImplPath = '$projectName/lib/core/localization/data/repositories/localization_repository_impl.dart';
  final repoImplContent = '''
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../error/exceptions/error_exception.dart';
import '../../../../error/failures/failure.dart';
import '../../domain/repositories/localization_repository.dart';
import '../datasources/localization_data_source.dart';

/// Implementation of the localization repository
class LocalizationRepositoryImpl implements LocalizationRepository {
  final LocalizationDataSource _dataSource;
  
  LocalizationRepositoryImpl(this._dataSource);
  
  @override
  Future<Either<Failure, Locale>> getCurrentLocale() async {
    try {
      final locale = await _dataSource.getCurrentLocale();
      return Right(locale);
    } on Exception catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> setLocale(Locale locale) async {
    try {
      await _dataSource.setLocale(locale);
      return const Right(null);
    } on Exception catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<Locale>>> getSupportedLocales() async {
    try {
      final locales = await _dataSource.getSupportedLocales();
      return Right(locales);
    } on Exception catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
''';

  final repoImplFile = File(repoImplPath);
  repoImplFile.writeAsStringSync(repoImplContent);
  context.logger.info('Created file: $repoImplPath');
  
  // Generate use cases
  final usecasesPath = '$projectName/lib/core/localization/domain/usecases/localization_usecases.dart';
  final usecasesContent = '''
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../../error/failures/failure.dart';
import '../repositories/localization_repository.dart';

/// Use case to get the current locale
class GetCurrentLocaleUseCase {
  final LocalizationRepository repository;
  
  GetCurrentLocaleUseCase(this.repository);
  
  Future<Either<Failure, Locale>> execute() {
    return repository.getCurrentLocale();
  }
}

/// Use case to set a new locale
class SetLocaleUseCase {
  final LocalizationRepository repository;
  
  SetLocaleUseCase(this.repository);
  
  Future<Either<Failure, void>> execute(Locale locale) {
    return repository.setLocale(locale);
  }
}

/// Use case to get supported locales
class GetSupportedLocalesUseCase {
  final LocalizationRepository repository;
  
  GetSupportedLocalesUseCase(this.repository);
  
  Future<Either<Failure, List<Locale>>> execute() {
    return repository.getSupportedLocales();
  }
}
''';

  final usecasesFile = File(usecasesPath);
  usecasesFile.writeAsStringSync(usecasesContent);
  context.logger.info('Created file: $usecasesPath');
}

/// Complete localization system generation based on project configuration
void generateCompleteLocalizationSystem(HookContext context, String projectName, String stateManagement, String architecture) {
  // Generate basic files
  _generateLocalizationFile(context, projectName);
  _generateL10nFile(context, projectName);
  _generateL10nYamlFile(context, projectName);
  _generateIntlEnArbFile(context, projectName);
  _generateIntlEsArbFile(context, projectName);
  
  // Generate generated files
  _generateStringsDartFile(context, projectName);
  _generateStringsEnDartFile(context, projectName);
  _generateStringsEsDartFile(context, projectName);
  
  // Generate example widget
  _generateLanguageSelectorWidget(context, projectName);
  
  // Generate state management specific implementations
  _generateLocalizationProvider(context, projectName, stateManagement);
  _generateLocalizationController(context, projectName, stateManagement);
  _generateLocalizationBloc(context, projectName, stateManagement);
  
  // Generate architecture specific implementations
  _generateLocalizationRepository(context, projectName, architecture);
  
  // Update pubspec.yaml and main.dart
  _updatePubspecForLocalization(context, projectName);
  _updateMainForLocalization(context, projectName);
}