import 'dart:io';

import 'package:mason/mason.dart';

/// Generates localization system for a Flutter project if Localization module is selected
void generateLocalizationSystem(HookContext context, String projectName,
    List<dynamic> modules, String stateManagement) {
  // Check if Localization is in the selected modules
  if (!modules.contains('Localization')) {
    context.logger.info(
        'Localization module not selected, skipping localization system generation');
    return;
  }

  context.logger.info('Generating localization system for $projectName');

  // Create directory structure
  _createDirectoryStructure(context, projectName);

  // Generate base localization files
  _generateBaseFiles(context, projectName);

  // Generate state management specific implementation
  _generateStateManagementImpl(context, projectName, stateManagement);

  // Update pubspec.yaml to add localization dependencies
  _updatePubspecForLocalization(context, projectName);

  // Update main.dart to initialize localization
  // _updateMainForLocalization(context, projectName, stateManagement);

  context.logger.success('Localization system generated successfully!');
}

/// Creates the directory structure for localization
void _createDirectoryStructure(HookContext context, String projectName) {
  final directories = [
    'lib/core/localization',
    'lib/core/localization/generated',
    'lib/core/localization/l10n',
  ];

  for (final dir in directories) {
    final directory = Directory('$projectName/$dir');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      context.logger.info('Created directory: $dir');
    }
  }
}

/// Generates base localization files
void _generateBaseFiles(HookContext context, String projectName) {
  // Generate localization.dart file
  _generateLocalizationFile(context, projectName);

  // Generate l10n configuration
  _generateL10nFile(context, projectName);
  _generateL10nYamlFile(context, projectName);

  // Generate ARB files
  _generateArbFiles(context, projectName);

  // Generate language selector widget
  _generateLanguageSelectorWidget(context, projectName);
}

/// Generates state management specific implementation
void _generateStateManagementImpl(
    HookContext context, String projectName, String stateManagement) {
  switch (stateManagement) {
    case 'Bloc':
    case 'BLoC':
      _generateBlocImplementation(context, projectName);
      break;
    case 'Provider':
      _generateProviderImplementation(context, projectName);
      break;
    case 'Riverpod':
      _generateRiverpodImplementation(context, projectName);
      break;
    case 'GetX':
      _generateGetXImplementation(context, projectName);
      break;
    case 'MobX':
      _generateMobXImplementation(context, projectName);
      break;
    case 'Redux':
      _generateReduxImplementation(context, projectName);
      break;
    default:
      _generateDefaultImplementation(context, projectName);
  }
}

/// Generate the localization.dart file with extension methods
void _generateLocalizationFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/localization/localization.dart';

  // Generate extension method for strings
  final stringExtensionMethod = '''
  // Extension for easy access to localized strings
  extension on BuildContext {
    AppLocalizations get strings => l10n;
  }''';

  stringExtensionMethod;

  final content = '''
import 'package:flutter/material.dart';
import 'generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Extension method to get localized strings easier
extension LocalizationExtension on BuildContext {
  /// Get the translation strings instance
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Utility methods for localization
class Localization {
  Localization._();
  
  /// Get all available locales
  static List<Locale> get supportedLocales => AppLocalizations.supportedLocales;
  
  /// Get all localization delegates
  static List<LocalizationsDelegate<dynamic>> get localizationDelegates => [
    AppLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ];
  
  /// Get a friendly display name for a locale
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'ja':
        return '日本語';
      case 'zh':
        return '中文';
      case 'ar':
        return 'العربية';
      case 'pt':
        return 'Português';
      case 'ru':
        return 'Русский';
      case 'ko':
        return '한국어';
      case 'it':
        return 'Italiano';
      case 'en':
      default:
        return 'English';
    }
  }
  
  /// Get a flag emoji for a language
  static String getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'ja':
        return '🇯🇵';
      case 'zh':
        return '🇨🇳';
      case 'ar':
        return '🇸🇦';
      case 'pt':
        return '🇧🇷';
      case 'ru':
        return '🇷🇺';
      case 'ko':
        return '🇰🇷';
      case 'it':
        return '🇮🇹';
      case 'en':
      default:
        return '🇺🇸';
    }
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generate the l10n.dart file with supported locales
void _generateL10nFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/localization/l10n/l10n.dart';
  final content = '''
import 'package:flutter/material.dart';

/// Class to manage supported locales
class L10n {
  L10n._();
  
  /// All supported locales in the app
  static const supportedLocales = [
    Locale('en'),
    Locale('es'),
    // Add more locales as needed
  ];
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generate the l10n.yaml configuration file
void _generateL10nYamlFile(HookContext context, String projectName) {
  final filePath = '$projectName/l10n.yaml';
  final content = '''
arb-dir: lib/core/localization/l10n
output-dir: lib/core/localization/generated
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false
synthetic-package: false
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generate ARB files for English and Spanish
void _generateArbFiles(HookContext context, String projectName) {
  // English ARB file (template)
  final enFilePath = '$projectName/lib/core/localization/l10n/app_en.arb';
  final enContent = '''{
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
  },
  "notifications": "Notifications",
  "@notifications": {
    "description": "Notifications title"
  },
  "notificationSent": "Notification sent",
  "@notificationSent": {
    "description": "Message shown when notification is sent"
  },
  "enableNotifications": "Enable Notifications",
  "@enableNotifications": {
    "description": "Switch label for enabling notifications"
  },
  "receiveNotifications": "Receive push notifications",
  "@receiveNotifications": {
    "description": "Description for notification switch"
  },
  "sendTestNotification": "Send Test Notification",
  "@sendTestNotification": {
    "description": "Button to send a test notification"
  },
  "deviceToken": "Device Token",
  "@deviceToken": {
    "description": "Label for device token section"
  },
  "loading": "Loading...",
  "@loading": {
    "description": "Loading text"
  },
  "notAvailable": "Not available",
  "@notAvailable": {
    "description": "Text for when a feature is not available"
  }
}''';

  final enFile = File(enFilePath);
  enFile.writeAsStringSync(enContent);
  context.logger.info('Created file: $enFilePath');

  // Spanish ARB file
  final esFilePath = '$projectName/lib/core/localization/l10n/app_es.arb';
  final esContent = '''{
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
  "systemMode": "Modo del Sistema",
  "notifications": "Notificaciones",
  "notificationSent": "Notificación enviada",
  "enableNotifications": "Activar Notificaciones",
  "receiveNotifications": "Recibir notificaciones push",
  "sendTestNotification": "Enviar Notificación de Prueba",
  "deviceToken": "Token del Dispositivo",
  "loading": "Cargando...",
  "notAvailable": "No disponible"
}''';

  final esFile = File(esFilePath);
  esFile.writeAsStringSync(esContent);
  context.logger.info('Created file: $esFilePath');
}

/// Generate a language selector widget for easier language switching
void _generateLanguageSelectorWidget(HookContext context, String projectName) {
  final filePath =
      '$projectName/lib/core/localization/widgets/language_selector.dart';
  final directory = Directory('$projectName/lib/core/localization/widgets');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  final content = '''
import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
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
            context.l10n.language,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        ...L10n.supportedLocales.map((locale) {
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
      tooltip: context.l10n.language,
      onPressed: () {
        // Toggle between English and Spanish (or other available locales)
        final supportedLocales = L10n.supportedLocales;
        final currentIndex = supportedLocales.indexWhere(
          (locale) => locale.languageCode == currentLocale.languageCode
        );
        final nextIndex = (currentIndex + 1) % supportedLocales.length;
        onChanged(supportedLocales[nextIndex]);
      },
    );
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generate BLoC implementation for localization
void _generateBlocImplementation(HookContext context, String projectName) {
  // Create directories
  final blocDir = Directory('$projectName/lib/core/localization/bloc');
  if (!blocDir.existsSync()) {
    blocDir.createSync(recursive: true);
  }

  // Generate the locale bloc file
  final blocFilePath =
      '$projectName/lib/core/localization/bloc/locale_bloc.dart';
  final blocContent = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/l10n.dart';

// Events
abstract class LocaleEvent extends Equatable {
  const LocaleEvent();
  
  @override
  List<Object> get props => [];
}

class ChangeLocaleEvent extends LocaleEvent {
  final String languageCode;
  
  const ChangeLocaleEvent(this.languageCode);
  
  @override
  List<Object> get props => [languageCode];
}

class LoadLocaleEvent extends LocaleEvent {}

// State
class LocaleState extends Equatable {
  final Locale locale;
  
  const LocaleState(this.locale);
  
  @override
  List<Object> get props => [locale];
}

// BLoC
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  static const String LOCALE_KEY = 'app_locale';
  
  LocaleBloc() : super(const LocaleState(Locale('en'))) {
    on<ChangeLocaleEvent>(_onChangeLocale);
    on<LoadLocaleEvent>(_onLoadLocale);
    
    // Load saved locale when bloc is created
    add(LoadLocaleEvent());
  }
  
  Future<void> _onChangeLocale(
    ChangeLocaleEvent event, 
    Emitter<LocaleState> emit
  ) async {
    final locale = Locale(event.languageCode);
    emit(LocaleState(locale));
    
    // Save the locale preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LOCALE_KEY, event.languageCode);
  }
  
  Future<void> _onLoadLocale(
    LoadLocaleEvent event, 
    Emitter<LocaleState> emit
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? languageCode = prefs.getString(LOCALE_KEY);
      
      if (languageCode != null) {
        emit(LocaleState(Locale(languageCode)));
      }
    } catch (e) {
      // If there's an error, keep using the default locale
    }
  }
}

// Extension for easy use with BuildContext
extension LocaleBlocExtension on BuildContext {
  void changeLocale(String languageCode) {
    read<LocaleBloc>().add(ChangeLocaleEvent(languageCode));
  }
  
  Locale get locale => read<LocaleBloc>().state.locale;
}
''';

  final blocFile = File(blocFilePath);
  blocFile.writeAsStringSync(blocContent);
  context.logger.info('Created file: $blocFilePath');
}

/// Generate Provider implementation for localization
void _generateProviderImplementation(HookContext context, String projectName) {
  // Create directories
  final providerDir = Directory('$projectName/lib/core/localization/providers');
  if (!providerDir.existsSync()) {
    providerDir.createSync(recursive: true);
  }

  // Generate the localization provider file
  final providerFilePath =
      '$projectName/lib/core/localization/providers/localization_provider.dart';
  final providerContent = '''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/l10n.dart';

class LocalizationProvider extends ChangeNotifier {
  static const String LOCALE_KEY = 'app_locale';
  
  Locale _locale = const Locale('en');
  
  LocalizationProvider() {
    _loadSavedLocale();
  }
  
  Locale get locale => _locale;
  
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? languageCode = prefs.getString(LOCALE_KEY);
      
      if (languageCode != null) {
        _locale = Locale(languageCode);
        notifyListeners();
      }
    } catch (e) {
      // If there's an error, keep using the default locale
    }
  }
  
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LOCALE_KEY, locale.languageCode);
    } catch (e) {
      // If there's an error saving, we still have the locale in memory
    }
  }
  
  Future<void> setLocaleByLanguageCode(String languageCode) async {
    await setLocale(Locale(languageCode));
  }
}

// Extension for easy use with BuildContext
extension LocalizationProviderExtension on BuildContext {
  void changeLocale(String languageCode) {
    Provider.of<LocalizationProvider>(this, listen: false)
        .setLocaleByLanguageCode(languageCode);
  }
  
  Locale get locale => 
      Provider.of<LocalizationProvider>(this, listen: false).locale;
}
''';

  final providerFile = File(providerFilePath);
  providerFile.writeAsStringSync(providerContent);
  context.logger.info('Created file: $providerFilePath');
}

/// Generate Riverpod implementation for localization
void _generateRiverpodImplementation(HookContext context, String projectName) {
  // Create directories
  final riverpodDir = Directory('$projectName/lib/core/localization/providers');
  if (!riverpodDir.existsSync()) {
    riverpodDir.createSync(recursive: true);
  }

  // Generate the locale provider file
  final providerFilePath =
      '$projectName/lib/core/localization/providers/locale_provider.dart';
  final providerContent = '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/l10n.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  static const String LOCALE_KEY = 'app_locale';
  
  LocaleNotifier() : super(const Locale('en')) {
    _loadSavedLocale();
  }
  
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? languageCode = prefs.getString(LOCALE_KEY);
      
      if (languageCode != null) {
        state = Locale(languageCode);
      }
    } catch (e) {
      // If there's an error, keep using the default locale
    }
  }
  
  Future<void> setLocale(String languageCode) async {
    if (state.languageCode == languageCode) return;
    
    state = Locale(languageCode);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LOCALE_KEY, languageCode);
    } catch (e) {
      // If there's an error saving, we still have the locale in memory
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

// Extensions for use with WidgetRef in Consumer widgets
extension LocaleRiverpodExtension on WidgetRef {
  void changeLocale(String languageCode) {
    read(localeProvider.notifier).setLocale(languageCode);
  }
  
  Locale get locale => read(localeProvider);
}
''';

  final providerFile = File(providerFilePath);
  providerFile.writeAsStringSync(providerContent);
  context.logger.info('Created file: $providerFilePath');
}

/// Generate GetX implementation for localization
void _generateGetXImplementation(HookContext context, String projectName) {
  // Create directories
  final getxDir = Directory('$projectName/lib/core/localization/controllers');
  if (!getxDir.existsSync()) {
    getxDir.createSync(recursive: true);
  }

  // Generate the localization controller file
  final controllerFilePath =
      '$projectName/lib/core/localization/controllers/localization_controller.dart';
  final controllerContent = '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/l10n.dart';

class LocalizationController extends GetxController {
  static const String LOCALE_KEY = 'app_locale';
  
  // Observable locale
  final _locale = Rx<Locale>(const Locale('en'));
  
  // Getter for the locale
  Locale get locale => _locale.value;
  
  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }
  
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? languageCode = prefs.getString(LOCALE_KEY);
      
      if (languageCode != null) {
        _locale.value = Locale(languageCode);
        Get.updateLocale(_locale.value);
      }
    } catch (e) {
      // If there's an error, keep using the default locale
    }
  }
  
  Future<void> setLocale(String languageCode) async {
    _locale.value = Locale(languageCode);
    Get.updateLocale(_locale.value);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LOCALE_KEY, languageCode);
    } catch (e) {
      // If there's an error saving, we still have the locale in memory
    }
  }
  
  void toggleLocale() {
    final supportedLocales = L10n.supportedLocales;
    final currentIndex = supportedLocales.indexWhere(
      (locale) => locale.languageCode == _locale.value.languageCode
    );
    final nextIndex = (currentIndex + 1) % supportedLocales.length;
    setLocale(supportedLocales[nextIndex].languageCode);
  }
}

// Extension for easy use with GetX
extension LocalizationGetXExtension on GetInterface {
  void changeLocale(String languageCode) {
    Get.find<LocalizationController>().setLocale(languageCode);
  }
  
  Locale get currentLocale => Get.find<LocalizationController>().locale;
}
''';

  final controllerFile = File(controllerFilePath);
  controllerFile.writeAsStringSync(controllerContent);
  context.logger.info('Created file: $controllerFilePath');
}

/// Generate MobX implementation for localization
void _generateMobXImplementation(HookContext context, String projectName) {
  // Create directories
  final mobxDir = Directory('$projectName/lib/core/localization/stores');
  if (!mobxDir.existsSync()) {
    mobxDir.createSync(recursive: true);
  }

  // Generate the localization store file
  final storeFilePath =
      '$projectName/lib/core/localization/stores/localization_store.dart';
  final storeContent = '''
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/l10n.dart';

// Include generated file
part 'localization_store.g.dart';

// This is the class used by rest of the codebase
class LocalizationStore = _LocalizationStore with _\$LocalizationStore;

// The store class
abstract class _LocalizationStore with Store {
  static const String LOCALE_KEY = 'app_locale';

  _LocalizationStore() {
    _loadSavedLocale();
  }
  
  @observable
  Locale locale = const Locale('en');
  
  @action
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? languageCode = prefs.getString(LOCALE_KEY);
      
      if (languageCode != null) {
        locale = Locale(languageCode);
      }
    } catch (e) {
      // If there's an error, keep using the default locale
    }
  }
  
  @action
  Future<void> setLocale(String languageCode) async {
    locale = Locale(languageCode);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LOCALE_KEY, languageCode);
    } catch (e) {
      // If there's an error saving, we still have the locale in memory
    }
  }
  
  @computed
  String get languageCode => locale.languageCode;
}

// Create a singleton instance
final localizationStore = LocalizationStore();
''';

  final storeFile = File(storeFilePath);
  storeFile.writeAsStringSync(storeContent);
  context.logger.info('Created file: $storeFilePath');

  // Add a note about generating MobX code
  context.logger.info(
      'Note: You need to run "flutter pub run build_runner build" to generate the MobX code');
}

/// Generate Redux implementation for localization
void _generateReduxImplementation(HookContext context, String projectName) {
  // Create directories
  final reduxDir = Directory('$projectName/lib/core/localization/redux');
  if (!reduxDir.existsSync()) {
    reduxDir.createSync(recursive: true);
  }

  // Generate the localization redux file
  final reduxFilePath =
      '$projectName/lib/core/localization/redux/locale_redux.dart';
  final reduxContent = '''
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Actions
class SetLocaleAction {
  final Locale locale;
  
  SetLocaleAction(this.locale);
}

// Thunk Actions
ThunkAction<AppState> loadSavedLocale() {
  return (Store<AppState> store) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? languageCode = prefs.getString('app_locale');
      if (languageCode != null) {
        store.dispatch(SetLocaleAction(Locale(languageCode)));
      }
    } catch (e) {
      // If there's an error, keep using the default locale
    }
  };
}

ThunkAction<AppState> setLocale(String languageCode) {
  return (Store<AppState> store) async {
    store.dispatch(SetLocaleAction(Locale(languageCode)));
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_locale', languageCode);
    } catch (e) {
      // If there's an error saving, we still have the locale in memory
    }
  };
}

// Reducer
Locale localeReducer(Locale state, dynamic action) {
  if (action is SetLocaleAction) {
    return action.locale;
  }
  
  return state;
}

// State
class LocaleState {
  final Locale locale;
  
  LocaleState({required this.locale});
  
  factory LocaleState.initial() {
    return LocaleState(locale: const Locale('en'));
  }
  
  LocaleState copyWith({Locale? locale}) {
    return LocaleState(
      locale: locale ?? this.locale,
    );
  }
}

// Extensions for use with StoreProvider
extension LocaleReduxExtension {
  static void changeLocale(BuildContext context, String languageCode) {
    StoreProvider.of<AppState>(context).dispatch(setLocale(languageCode));
  }
  
  static Locale getCurrentLocale(BuildContext context) {
    return StoreProvider.of<AppState>(context).state.localeState.locale;
  }
}
''';

  final reduxFile = File(reduxFilePath);
  reduxFile.writeAsStringSync(reduxContent);
  context.logger.info('Created file: $reduxFilePath');
}

/// Generate default implementation for localization when no state management is specified
void _generateDefaultImplementation(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/localization/locale_manager.dart';
  final content = '''
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/l10n.dart';

/// Simple class to manage localization without complex state management
class LocaleManager {
  static const String LOCALE_KEY = 'app_locale';
  
  Locale _locale = const Locale('en');
  final List<Function(Locale)> _listeners = [];
  
  static final LocaleManager _instance = LocaleManager._internal();
  
  factory LocaleManager() {
    return _instance;
  }
  
  LocaleManager._internal() {
    _loadSavedLocale();
  }
  
  /// Get the current locale
  Locale get locale => _locale;
  
  /// Add a listener for when the locale changes
  void addListener(Function(Locale) listener) {
    _listeners.add(listener);
  }
  
  /// Remove a listener
  void removeListener(Function(Locale) listener) {
    _listeners.remove(listener);
  }
  
  /// Load the saved locale from SharedPreferences
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? languageCode = prefs.getString(LOCALE_KEY);
      
      if (languageCode != null) {
        _setLocaleInternal(Locale(languageCode));
      }
    } catch (e) {
      // If there's an error, keep using the default locale
    }
  }
  
  /// Set the locale and notify listeners
  void _setLocaleInternal(Locale locale) {
    _locale = locale;
    
    // Notify all listeners
    for (final listener in _listeners) {
      listener(_locale);
    }
  }
  
  /// Change the locale and save to SharedPreferences
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _setLocaleInternal(locale);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LOCALE_KEY, locale.languageCode);
    } catch (e) {
      // If there's an error saving, we still have the locale in memory
    }
  }
  
  /// Set locale using language code
  Future<void> setLocaleByLanguageCode(String languageCode) async {
    await setLocale(Locale(languageCode));
  }
  
  /// Toggle to the next locale in the list of supported locales
  Future<void> toggleLocale() async {
    final supportedLocales = L10n.supportedLocales;
    final currentIndex = supportedLocales.indexWhere(
      (supportedLocale) => supportedLocale.languageCode == _locale.languageCode
    );
    final nextIndex = (currentIndex + 1) % supportedLocales.length;
    await setLocale(supportedLocales[nextIndex]);
  }
}

// Global instance
final localeManager = LocaleManager();
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Update pubspec.yaml to add localization dependencies
void _updatePubspecForLocalization(HookContext context, String projectName) {
  final pubspecFile = File('$projectName/pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    context.logger.warn(
        'pubspec.yaml not found, skipping adding localization dependencies');
    return;
  }

  String content = pubspecFile.readAsStringSync();
  bool modified = false;

  // Add flutter_localizations dependency if not already present
  if (!content.contains('flutter_localizations:')) {
    final flutterDepIndex = content.indexOf('flutter:');
    if (flutterDepIndex != -1) {
      final insertPosition = content.indexOf('sdk: flutter');
      if (insertPosition != -1) {
        final endOfLine = content.indexOf('\n', insertPosition);
        if (endOfLine != -1) {
          final newContent = content.substring(0, endOfLine + 1) +
              '  flutter_localizations:\n    sdk: flutter\n' +
              content.substring(endOfLine + 1);
          content = newContent;
          modified = true;
        }
      }
    }
  }

  // Add intl dependency if not already present
  if (!content.contains('intl:')) {
    final depPosition = content.indexOf('dependencies:');
    if (depPosition != -1) {
      // Find a good spot to insert intl dependency
      final insertPosition = content.indexOf('\n\n', depPosition);
      if (insertPosition != -1) {
        final newContent = content.substring(0, insertPosition) +
            '\n  intl: ^0.18.0' +
            content.substring(insertPosition);
        content = newContent;
        modified = true;
      }
    }
  }

  // Add shared_preferences dependency if not already present
  if (!content.contains('shared_preferences:')) {
    final depPosition = content.indexOf('dependencies:');
    if (depPosition != -1) {
      // Find a good spot to insert dependency
      final insertPosition = content.indexOf('\n\n', depPosition);
      if (insertPosition != -1) {
        final newContent = content.substring(0, insertPosition) +
            '\n  shared_preferences: ^2.1.1' +
            content.substring(insertPosition);
        content = newContent;
        modified = true;
      }
    }
  }

  // Enable Flutter's generation in pubspec.yaml
  if (!content.contains('generate: true')) {
    final flutterSection = content.indexOf('flutter:');
    if (flutterSection != -1) {
      // Find where to add generate: true
      final insertPosition = content.indexOf('\n', flutterSection);
      if (insertPosition != -1) {
        final newContent = content.substring(0, insertPosition + 1) +
            '  generate: true\n' +
            content.substring(insertPosition + 1);
        content = newContent;
        modified = true;
      }
    }
  }

  // Write updated content back to file
  if (modified) {
    pubspecFile.writeAsStringSync(content);
    context.logger
        .success('Updated pubspec.yaml with localization dependencies');
  } else {
    context.logger.info('pubspec.yaml already has localization dependencies');
  }
}

/// Update main.dart to initialize localization
void _updateMainForLocalization(
    HookContext context, String projectName, String stateManagement) {
  final mainDartFile = File('$projectName/lib/main.dart');
  if (!mainDartFile.existsSync()) {
    context.logger
        .warn('main.dart not found, skipping localization initialization');
    return;
  }

  String content = mainDartFile.readAsStringSync();
  bool modified = false;

  // Add import for localization
  if (!content.contains('localization.dart')) {
    final importPattern = RegExp(r'import .*;\n');
    final lastImportMatch = importPattern.allMatches(content).lastOrNull;

    if (lastImportMatch != null) {
      final insertPosition = lastImportMatch.end;
      content = content.substring(0, insertPosition) +
          "import 'package:$projectName/core/localization/localization.dart';\n" +
          content.substring(insertPosition);
      modified = true;
    }
  }

  // Add state management specific import
  String stateManagementImport = '';
  switch (stateManagement) {
    case 'Bloc':
    case 'BLoC':
      if (!content.contains('bloc/locale_bloc.dart')) {
        stateManagementImport =
            "import 'package:$projectName/core/localization/bloc/locale_bloc.dart';\n";
      }
      break;
    case 'Provider':
      if (!content.contains('providers/localization_provider.dart')) {
        stateManagementImport =
            "import 'package:$projectName/core/localization/providers/localization_provider.dart';\n";
      }
      break;
    case 'Riverpod':
      if (!content.contains('providers/locale_provider.dart')) {
        stateManagementImport =
            "import 'package:$projectName/core/localization/providers/locale_provider.dart';\n";
      }
      break;
    case 'GetX':
      if (!content.contains('controllers/localization_controller.dart')) {
        stateManagementImport =
            "import 'package:$projectName/core/localization/controllers/localization_controller.dart';\n";
      }
      break;
    case 'MobX':
      if (!content.contains('stores/localization_store.dart')) {
        stateManagementImport =
            "import 'package:$projectName/core/localization/stores/localization_store.dart';\n";
      }
      break;
    case 'Redux':
      if (!content.contains('redux/locale_redux.dart')) {
        stateManagementImport =
            "import 'package:$projectName/core/localization/redux/locale_redux.dart';\n";
      }
      break;
    default:
      if (!content.contains('locale_manager.dart')) {
        stateManagementImport =
            "import 'package:$projectName/core/localization/locale_manager.dart';\n";
      }
      break;
  }

  if (stateManagementImport.isNotEmpty) {
    final importPattern = RegExp(r'import .*;\n');
    final lastImportMatch = importPattern.allMatches(content).lastOrNull;

    if (lastImportMatch != null) {
      final insertPosition = lastImportMatch.end;
      content = content.substring(0, insertPosition) +
          stateManagementImport +
          content.substring(insertPosition);
      modified = true;
    }
  }

  // Update MaterialApp or similar widget to add localization delegates
  if (!content.contains('localizationsDelegates:') &&
      !content.contains('supportedLocales:')) {
    // Define patterns for different app widgets
    final materialAppPattern = RegExp(r'MaterialApp\(');
    final cupertioAppPattern = RegExp(r'CupertinoApp\(');
    final getMatAppPattern = RegExp(r'GetMaterialApp\(');
    final providerScopePattern = RegExp(r'ProviderScope\(');

    if (materialAppPattern.hasMatch(content)) {
      content = content.replaceAll(
        'MaterialApp(',
        'MaterialApp(\n      localizationsDelegates: Localization.localizationDelegates,\n      supportedLocales: Localization.supportedLocales,',
      );
      modified = true;
    } else if (cupertioAppPattern.hasMatch(content)) {
      content = content.replaceAll(
        'CupertinoApp(',
        'CupertinoApp(\n      localizationsDelegates: Localization.localizationDelegates,\n      supportedLocales: Localization.supportedLocales,',
      );
      modified = true;
    } else if (getMatAppPattern.hasMatch(content)) {
      content = content.replaceAll(
        'GetMaterialApp(',
        'GetMaterialApp(\n      localizationsDelegates: Localization.localizationDelegates,\n      supportedLocales: Localization.supportedLocales,',
      );
      modified = true;
    }
  }

  // Add locale initialization based on state management
  if (!content.contains('locale:')) {
    String localeInitialization = '';

    switch (stateManagement) {
      case 'Bloc':
      case 'BLoC':
        if (content.contains('MultiBlocProvider(')) {
          // If MultiBlocProvider exists, add BlocProvider for LocaleBloc
          final providerPattern = RegExp(r'providers: \[\s*');
          if (providerPattern.hasMatch(content)) {
            content = content.replaceFirst(
              providerPattern,
              'providers: [\n        BlocProvider(create: (_) => LocaleBloc()),\n        ',
            );

            // Also add the locale to MaterialApp/other app widget
            final appPattern =
                RegExp(r'(MaterialApp|CupertinoApp|GetMaterialApp)\(');
            if (appPattern.hasMatch(content)) {
              content = content.replaceFirst(
                'supportedLocales: Localization.supportedLocales,',
                'supportedLocales: Localization.supportedLocales,\n      locale: context.watch<LocaleBloc>().state.locale,',
              );
            }
            modified = true;
          }
        } else {
          // If no MultiBlocProvider, wrap with BlocProvider
          final runAppPattern = RegExp(r'runApp\(\s*(const\s*)?(.*)\s*\);');
          final match = runAppPattern.firstMatch(content);
          if (match != null) {
            final constKeyword = match.group(1) ?? '';
            final appWidget = match.group(2) ?? '';

            content = content.replaceFirst(
              runAppPattern,
              'runApp(\n    BlocProvider(\n      create: (_) => LocaleBloc(),\n      child: BlocBuilder<LocaleBloc, LocaleState>(\n        builder: (context, state) {\n          return $constKeyword$appWidget.copyWith(\n            locale: state.locale,\n          );\n        },\n      ),\n    ),\n  );',
            );
            modified = true;
          }
        }
        break;

      case 'Provider':
        if (content.contains('MultiProvider(')) {
          // If MultiProvider exists, add ChangeNotifierProvider for LocalizationProvider
          final providerPattern = RegExp(r'providers: \[\s*');
          if (providerPattern.hasMatch(content)) {
            content = content.replaceFirst(
              providerPattern,
              'providers: [\n        ChangeNotifierProvider(create: (_) => LocalizationProvider()),\n        ',
            );

            // Also add the locale to MaterialApp/other app widget
            final appPattern =
                RegExp(r'(MaterialApp|CupertinoApp|GetMaterialApp)\(');
            if (appPattern.hasMatch(content)) {
              content = content.replaceFirst(
                'supportedLocales: Localization.supportedLocales,',
                'supportedLocales: Localization.supportedLocales,\n      locale: Provider.of<LocalizationProvider>(context).locale,',
              );
            }
            modified = true;
          }
        } else {
          // If no MultiProvider, wrap with ChangeNotifierProvider
          final runAppPattern = RegExp(r'runApp\(\s*(const\s*)?(.*)\s*\);');
          final match = runAppPattern.firstMatch(content);
          if (match != null) {
            final constKeyword = match.group(1) ?? '';
            final appWidget = match.group(2) ?? '';

            content = content.replaceFirst(
              runAppPattern,
              'runApp(\n    ChangeNotifierProvider(\n      create: (_) => LocalizationProvider(),\n      child: Consumer<LocalizationProvider>(\n        builder: (context, provider, _) {\n          return $constKeyword$appWidget.copyWith(\n            locale: provider.locale,\n          );\n        },\n      ),\n    ),\n  );',
            );
            modified = true;
          }
        }
        break;

      case 'Riverpod':
        // Riverpod already wraps with ProviderScope, just add locale
        final appPattern =
            RegExp(r'(MaterialApp|CupertinoApp|GetMaterialApp)\(');
        if (appPattern.hasMatch(content)) {
          content = content.replaceFirst(
            'supportedLocales: Localization.supportedLocales,',
            'supportedLocales: Localization.supportedLocales,\n      locale: ref.watch(localeProvider),',
          );
          modified = true;
        }
        break;

      case 'GetX':
        // Add controller initialization to main function
        final mainFunctionPattern = RegExp(r'void main\(\) async \{');
        if (mainFunctionPattern.hasMatch(content)) {
          content = content.replaceFirst(
            mainFunctionPattern,
            'void main() async {\n  // Initialize localization controller\n  initializeControllers();;\n',
          );

          // Also add locale to GetMaterialApp
          final appPattern = RegExp(r'GetMaterialApp\(');
          if (appPattern.hasMatch(content)) {
            content = content.replaceFirst(
              'supportedLocales: Localization.supportedLocales,',
              'supportedLocales: Localization.supportedLocales,\n      locale: Get.find<LocalizationController>().locale,',
            );
          }
          modified = true;
        }
        break;

      case 'MobX':
        // Add locale to app widget
        final appPattern =
            RegExp(r'(MaterialApp|CupertinoApp|GetMaterialApp)\(');
        if (appPattern.hasMatch(content)) {
          content = content.replaceFirst(
            'supportedLocales: Localization.supportedLocales,',
            'supportedLocales: Localization.supportedLocales,\n      locale: localizationStore.locale,',
          );
          modified = true;
        }
        break;

      case 'Redux':
        // Redux requires more complex changes - we'll just add locale to app state
        // This is a simplification and would need more customization based on app structure
        final appPattern =
            RegExp(r'(MaterialApp|CupertinoApp|GetMaterialApp)\(');
        if (appPattern.hasMatch(content)) {
          content = content.replaceFirst(
            'supportedLocales: Localization.supportedLocales,',
            'supportedLocales: Localization.supportedLocales,\n      locale: store.state.localeState.locale,',
          );

          // Also add middleware for localization
          final createStorePattern = RegExp(r'middleware: \[thunkMiddleware\]');
          if (createStorePattern.hasMatch(content)) {
            content = content.replaceAll(
              'middleware: [thunkMiddleware]',
              'middleware: [thunkMiddleware, ...createLocaleMiddleware()]',
            );
          }
          modified = true;
        }
        break;

      default:
        // Add locale manager to app widget
        final appPattern =
            RegExp(r'(MaterialApp|CupertinoApp|GetMaterialApp)\(');
        if (appPattern.hasMatch(content)) {
          content = content.replaceFirst(
            'supportedLocales: Localization.supportedLocales,',
            'supportedLocales: Localization.supportedLocales,\n      locale: localeManager.locale,',
          );

          // Also add StatefulBuilder to update on locale changes
          final runAppPattern = RegExp(r'runApp\(\s*(const\s*)?(.*)\s*\);');
          final match = runAppPattern.firstMatch(content);
          if (match != null) {
            final constKeyword = match.group(1) ?? '';
            final appWidget = match.group(2) ?? '';

            content = content.replaceFirst(
              runAppPattern,
              'runApp(\n    StatefulBuilder(\n      builder: (context, setState) {\n        // Listen for locale changes\n        localeManager.addListener((_) => setState(() {}));\n        return $constKeyword$appWidget;\n      },\n    ),\n  );',
            );
          }

          modified = true;
        }
        break;
    }
  }

  // Write updated content back to file
  if (modified) {
    mainDartFile.writeAsStringSync(content);
    context.logger.success('Updated main.dart with localization configuration');
  } else {
    context.logger.info('main.dart already has localization configuration');
  }
}
