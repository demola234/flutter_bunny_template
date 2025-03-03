import 'dart:io';

import 'package:mason/mason.dart';

import 'integrate_theme_manager.dart';

/// Generates a theme system for a Flutter project if the theme module is selected
void generateThemeSystem(
    HookContext context, String projectName, List<dynamic> modules) {
  // Check if Theme Manager is in the selected modules
  if (!modules.contains('Theme Manager')) {
    context.logger.info(
        'Theme Manager module not selected, skipping theme system generation');
    return;
  }

  context.logger.info('Generating theme system for $projectName');

  // Create directory structure
  final directories = [
    'lib/core/design_system/app_colors',
    'lib/core/design_system/color_extension',
    'lib/core/design_system/font_extension',
    'lib/core/design_system/theme_extension',
  ];

  for (final dir in directories) {
    final directory = Directory('$projectName/$dir');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      context.logger.info('Created directory: $dir');
    }
  }

  // Generate theme files
  _generateAppColorsFile(context, projectName);
  _generateColorExtensionFile(context, projectName);
  _generateFontExtensionFile(context, projectName);
  _generateAppThemeExtensionFile(context, projectName);
  _generateThemeManagerFile(context, projectName);

  // Integrate with main.dart and app.dart
  final stateManagement = context.vars['state_management'] as String;
  integrateThemeManager(context, projectName, stateManagement, modules);

  context.logger.success('Theme system generated successfully!');
}

/// Generates the app_colors.dart file
void _generateAppColorsFile(HookContext context, String projectName) {
  final filePath =
      '$projectName/lib/core/design_system/app_colors/app_colors.dart';
  final content = '''
import 'package:flutter/material.dart';

class AppColor {
  static const Color textPrimary = Color(0xFF000003);
  static const Color textTertiary = Color(0xFF666666);
  static const Color surfaceCard = Color(0xFFF6F6F7);
  static const Color textHighlightBlue = Color(0xFF0000E5);
  static const Color surface = Color(0xFFF2F2F2);
  static const Color inactiveButton = Color(0xFFD3D3D7);
  static const Color activeButton = Color(0xFF0000E5);
  static const Color activeButtonDark = Color.fromARGB(255, 73, 73, 215);
  static const Color textWhite = Color(0xFFF6F6F7);
  static const Color iconRed = Color(0xFFE50900);
  static const Color iconBlue = Color(0xFF0000E5);
  static const Color buttonTertiary = Color(0xFFCCFF00);
  static const Color buttonSecondary = Color(0xFF141619);
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the app_color_extension.dart file
void _generateColorExtensionFile(HookContext context, String projectName) {
  final filePath =
      '$projectName/lib/core/design_system/color_extension/app_color_extension.dart';
  final projectNameCapitalized = _toSentenceCase(projectName);

  final content = '''
import 'package:flutter/material.dart';

/// `ThemeExtension` for $projectNameCapitalized custom colors.
///
/// This extension includes colors from the $projectNameCapitalized palette and can be easily used
/// throughout the app for consistent theming.
///
/// Usage example: `Theme.of(context).extension<AppColorExtension>()?.textPrimary`.
class AppColorExtension extends ThemeExtension<AppColorExtension> {
  const AppColorExtension({
    required this.textPrimary,
    required this.textTertiary,
    required this.surfaceCard,
    required this.textHighlightBlue,
    required this.surface,
    required this.inactiveButton,
    required this.activeButton,
    required this.textWhite,
    required this.iconRed,
    required this.iconBlue,
    required this.buttonTertiary,
    required this.buttonSecondary,
  });

  final Color textPrimary;
  final Color textTertiary;
  final Color surfaceCard;
  final Color textHighlightBlue;
  final Color surface;
  final Color inactiveButton;
  final Color activeButton;
  final Color textWhite;
  final Color iconRed;
  final Color iconBlue;
  final Color buttonTertiary;
  final Color buttonSecondary;

  @override
  ThemeExtension<AppColorExtension> copyWith({
    Color? textPrimary,
    Color? textTertiary,
    Color? surfaceCard,
    Color? textHighlightBlue,
    Color? surface,
    Color? inactiveButton,
    Color? activeButton,
    Color? textWhite,
    Color? iconRed,
    Color? iconBlue,
    Color? buttonTertiary,
    Color? buttonSecondary,
  }) {
    return AppColorExtension(
      textPrimary: textPrimary ?? this.textPrimary,
      textTertiary: textTertiary ?? this.textTertiary,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      textHighlightBlue: textHighlightBlue ?? this.textHighlightBlue,
      surface: surface ?? this.surface,
      inactiveButton: inactiveButton ?? this.inactiveButton,
      activeButton: activeButton ?? this.activeButton,
      textWhite: textWhite ?? this.textWhite,
      iconRed: iconRed ?? this.iconRed,
      iconBlue: iconBlue ?? this.iconBlue,
      buttonTertiary: buttonTertiary ?? this.buttonTertiary,
      buttonSecondary: buttonSecondary ?? this.buttonSecondary,
    );
  }

  @override
  ThemeExtension<AppColorExtension> lerp(
    covariant ThemeExtension<AppColorExtension>? other,
    double t,
  ) {
    if (other is! AppColorExtension) {
      return this;
    }
    return AppColorExtension(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      textHighlightBlue:
          Color.lerp(textHighlightBlue, other.textHighlightBlue, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      inactiveButton: Color.lerp(inactiveButton, other.inactiveButton, t)!,
      activeButton: Color.lerp(activeButton, other.activeButton, t)!,
      textWhite: Color.lerp(textWhite, other.textWhite, t)!,
      iconRed: Color.lerp(iconRed, other.iconRed, t)!,
      iconBlue: Color.lerp(iconBlue, other.iconBlue, t)!,
      buttonTertiary: Color.lerp(buttonTertiary, other.buttonTertiary, t)!,
      buttonSecondary: Color.lerp(buttonSecondary, other.buttonSecondary, t)!,
    );
  }
}

/// Extension to create a ColorScheme from AppColorExtension.
extension ColorSchemeBuilder on AppColorExtension {
  ColorScheme toColorScheme(Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: textPrimary,
      onPrimary: textWhite,
      secondary: activeButton,
      onSecondary: buttonSecondary,
      error: iconRed,
      onError: textWhite,
      background: surface,
      onBackground: textPrimary,
      surface: surface,
      onSurface: textPrimary,
    );
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the font_extension.dart file
void _generateFontExtensionFile(HookContext context, String projectName) {
  final filePath =
      '$projectName/lib/core/design_system/font_extension/font_extension.dart';
  final content = '''
import 'package:flutter/material.dart';

/// `ThemeExtension` template for custom text styles.
/// 
/// This extension defines the typography styles used throughout the app.
class AppFontThemeExtension extends ThemeExtension<AppFontThemeExtension> {
  const AppFontThemeExtension({
    required this.headerLarger,
    required this.headerSmall,
    required this.subHeader,
    required this.bodyMedium,
  });

  final TextStyle headerLarger;
  final TextStyle headerSmall;
  final TextStyle subHeader;
  final TextStyle bodyMedium;

  @override
  ThemeExtension<AppFontThemeExtension> copyWith({
    TextStyle? headerLarger,
    TextStyle? headerSmall,
    TextStyle? subHeader,
    TextStyle? bodyMedium,
  }) {
    return AppFontThemeExtension(
      headerLarger: headerLarger ?? this.headerLarger,
      headerSmall: headerSmall ?? this.headerSmall,
      subHeader: subHeader ?? this.subHeader,
      bodyMedium: bodyMedium ?? this.bodyMedium,
    );
  }

  @override
  ThemeExtension<AppFontThemeExtension> lerp(
    covariant ThemeExtension<AppFontThemeExtension>? other,
    double t,
  ) {
    if (other is! AppFontThemeExtension) {
      return this;
    }

    return AppFontThemeExtension(
      headerLarger: TextStyle.lerp(headerLarger, other.headerLarger, t)!,
      headerSmall: TextStyle.lerp(headerSmall, other.headerSmall, t)!,
      subHeader: TextStyle.lerp(subHeader, other.subHeader, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
    );
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the app_theme_extension.dart file
void _generateAppThemeExtensionFile(HookContext context, String projectName) {
  final filePath =
      '$projectName/lib/core/design_system/theme_extension/app_theme_extension.dart';
  final content = '''
import 'package:flutter/material.dart';

import '../app_colors/app_colors.dart';
import '../color_extension/app_color_extension.dart';
import '../font_extension/font_extension.dart';

class AppTheme {
  static final light = () {
    final defaultTheme = ThemeData.light();

    return defaultTheme.copyWith(
      colorScheme: _lightAppColors.toColorScheme(Brightness.light),
      scaffoldBackgroundColor: _lightAppColors.surface,
      appBarTheme: AppBarTheme(
        color: _lightAppColors.surface,
      ),
      extensions: [
        _lightAppColors,
        _lightFontTheme,
      ],
    );
  }();

  static final dark = () {
    final defaultTheme = ThemeData.dark();

    return defaultTheme.copyWith(
      colorScheme: _darkAppColors.toColorScheme(Brightness.dark),
      scaffoldBackgroundColor: _darkAppColors.surface,
      appBarTheme: AppBarTheme(
        color: _darkAppColors.surface,
      ),
      extensions: [
        _darkAppColors,
        _darkFontTheme,
      ],
    );
  }();

  static final _lightFontTheme = AppFontThemeExtension(
    headerLarger: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: _lightAppColors.textPrimary,
    ),
    headerSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: _lightAppColors.textPrimary,
    ),
    subHeader: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: _lightAppColors.textTertiary,
    ),
    bodyMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: _lightAppColors.textPrimary,
    ),
  );

  static final _darkFontTheme = AppFontThemeExtension(
    headerLarger: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: _darkAppColors.textPrimary,
    ),
    headerSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: _darkAppColors.textPrimary,
    ),
    subHeader: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: _darkAppColors.textTertiary,
    ),
    bodyMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: _darkAppColors.textPrimary,
    ),
  );

  static const _lightAppColors = AppColorExtension(
    textPrimary: AppColor.textPrimary,
    textTertiary: AppColor.textTertiary,
    surfaceCard: AppColor.surfaceCard,
    textHighlightBlue: AppColor.textHighlightBlue,
    surface: AppColor.surface,
    inactiveButton: AppColor.inactiveButton,
    activeButton: AppColor.activeButton,
    textWhite: AppColor.textWhite,
    iconRed: AppColor.iconRed,
    iconBlue: AppColor.iconBlue,
    buttonTertiary: AppColor.buttonTertiary,
    buttonSecondary: AppColor.buttonSecondary,
  );

  static const _darkAppColors = AppColorExtension(
    textPrimary: AppColor.textWhite,
    textTertiary: AppColor.textTertiary,
    surfaceCard: AppColor.buttonSecondary,
    textHighlightBlue: AppColor.activeButtonDark,
    surface: AppColor.textPrimary,
    inactiveButton: AppColor.inactiveButton,
    activeButton: AppColor.activeButtonDark,
    textWhite: AppColor.textPrimary,
    iconRed: AppColor.iconRed,
    iconBlue: AppColor.iconBlue,
    buttonTertiary: AppColor.buttonTertiary,
    buttonSecondary: AppColor.buttonSecondary,
  );
}

extension ThemeGetter on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;
}

extension AppThemeExtension on ThemeData {
  AppColorExtension get colors =>
      extension<AppColorExtension>() ?? AppTheme._lightAppColors;

  AppFontThemeExtension get fonts =>
      extension<AppFontThemeExtension>() ?? AppTheme._lightFontTheme;
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the theme_manager.dart file based on selected state management
void _generateThemeManagerFile(HookContext context, String projectName) {
  final filePath =
      '$projectName/lib/core/design_system/theme_extension/theme_manager.dart';
  final stateManagement = context.vars['state_management'] as String;

  String content = '';

  // Different implementations based on state management
  switch (stateManagement) {
    case 'BLoC':
    case 'Bloc':
      content = '''
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum representing different theme modes
enum ThemeModeEnum {
  light,
  dark,
  system;

  /// Convert ThemeModeEnum to Flutter's ThemeMode
  ThemeMode toThemeMode() {
    switch (this) {
      case ThemeModeEnum.light:
        return ThemeMode.light;
      case ThemeModeEnum.dark:
        return ThemeMode.dark;
      case ThemeModeEnum.system:
        return ThemeMode.system;
    }
  }

  /// Get the string name of the theme mode
  String get name {
    switch (this) {
      case ThemeModeEnum.light:
        return 'Light';
      case ThemeModeEnum.dark:
        return 'Dark';
      case ThemeModeEnum.system:
        return 'System';
    }
  }
}

/// Class to manage the theme state using SharedPreferences
class ThemeManager {
  static const String _themeKey = 'app_theme';
  ThemeModeEnum _currentTheme = ThemeModeEnum.system;
  final List<Function(ThemeModeEnum)> _listeners = [];

  /// Function to initialize the theme manager
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);

    if (themeIndex != null) {
      _currentTheme = ThemeModeEnum
          .values[themeIndex.clamp(0, ThemeModeEnum.values.length - 1)];
    }
  }

  /// Get the current theme mode
  ThemeModeEnum get currentTheme => _currentTheme;

  /// Get the Flutter ThemeMode
  ThemeMode get themeMode => _currentTheme.toThemeMode();

  /// Function to set the theme
  Future<void> setTheme(ThemeModeEnum theme) async {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, theme.index);

      // Notify all listeners
      for (final listener in _listeners) {
        listener(theme);
      }
    }
  }

  /// Add a listener for theme changes
  void addListener(Function(ThemeModeEnum) listener) {
    _listeners.add(listener);
  }

  /// Remove a listener
  void removeListener(Function(ThemeModeEnum) listener) {
    _listeners.remove(listener);
  }

  /// Check if the current theme is dark
  bool get isDarkMode {
    if (_currentTheme == ThemeModeEnum.system) {
      // Get system brightness when in system mode
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _currentTheme == ThemeModeEnum.dark;
  }
}

/// ThemeManager instance to be used throughout the app
final themeManager = ThemeManager();

/// Bloc implementation for theme management
class ThemeState {
  final ThemeModeEnum themeMode;

  ThemeState(this.themeMode);
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(ThemeModeEnum.system)) {
    // Initialize from shared preferences
    themeManager.initialize().then((_) {
      emit(ThemeState(themeManager.currentTheme));
    });

    // Add listener for theme changes
    themeManager.addListener(_onThemeChanged);
  }

  void setTheme(ThemeModeEnum theme) {
    themeManager.setTheme(theme);
  }

  void _onThemeChanged(ThemeModeEnum theme) {
    emit(ThemeState(theme));
  }

  @override
  Future<void> close() {
    themeManager.removeListener(_onThemeChanged);
    return super.close();
  }
}
''';
      break;

    case 'Provider':
      content = '''
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum representing different theme modes
enum ThemeModeEnum {
  light,
  dark,
  system;

  /// Convert ThemeModeEnum to Flutter's ThemeMode
  ThemeMode toThemeMode() {
    switch (this) {
      case ThemeModeEnum.light:
        return ThemeMode.light;
      case ThemeModeEnum.dark:
        return ThemeMode.dark;
      case ThemeModeEnum.system:
        return ThemeMode.system;
    }
  }

  /// Get the string name of the theme mode
  String get name {
    switch (this) {
      case ThemeModeEnum.light:
        return 'Light';
      case ThemeModeEnum.dark:
        return 'Dark';
      case ThemeModeEnum.system:
        return 'System';
    }
  }
}

/// Provider implementation for theme management
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  ThemeModeEnum _themeMode = ThemeModeEnum.system;
  bool _isInitialized = false;

  ThemeProvider() {
    _loadTheme();
  }

  /// Load theme from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    
    if (themeIndex != null) {
      _themeMode = ThemeModeEnum.values[
        themeIndex.clamp(0, ThemeModeEnum.values.length - 1)
      ];
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  /// Get current theme mode
  ThemeModeEnum get themeMode => _themeMode;
  
  /// Get Flutter ThemeMode for MaterialApp
  ThemeMode get flutterThemeMode => _themeMode.toThemeMode();
  
  /// Check if the theme provider is initialized
  bool get isInitialized => _isInitialized;
  
  /// Check if dark mode is active (including system dark mode)
  bool get isDarkMode {
    if (_themeMode == ThemeModeEnum.system) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeModeEnum.dark;
  }

  /// Set theme mode and save to SharedPreferences
  Future<void> setThemeMode(ThemeModeEnum mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }
}

/// Extension method to access theme provider easily
extension ThemeProviderExtension on BuildContext {
  ThemeProvider get themeProvider => Provider.of<ThemeProvider>(this, listen: false);
  ThemeModeEnum get themeMode => Provider.of<ThemeProvider>(this, listen: true).themeMode;
  bool get isDarkMode => Provider.of<ThemeProvider>(this, listen: true).isDarkMode;
}
''';
      break;

    case 'Riverpod':
      content = '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum representing different theme modes
enum ThemeModeEnum {
  light,
  dark,
  system;

  /// Convert ThemeModeEnum to Flutter's ThemeMode
  ThemeMode toThemeMode() {
    switch (this) {
      case ThemeModeEnum.light:
        return ThemeMode.light;
      case ThemeModeEnum.dark:
        return ThemeMode.dark;
      case ThemeModeEnum.system:
        return ThemeMode.system;
    }
  }

  /// Get the string name of the theme mode
  String get name {
    switch (this) {
      case ThemeModeEnum.light:
        return 'Light';
      case ThemeModeEnum.dark:
        return 'Dark';
      case ThemeModeEnum.system:
        return 'System';
    }
  }
}

/// Provider for theme settings
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeModeEnum>((ref) {
  return ThemeNotifier();
});

/// Notifier for theme state
class ThemeNotifier extends StateNotifier<ThemeModeEnum> {
  static const String _themeKey = 'app_theme';

  ThemeNotifier() : super(ThemeModeEnum.system) {
    _loadTheme();
  }

  /// Load theme from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    
    if (themeIndex != null) {
      state = ThemeModeEnum.values[
        themeIndex.clamp(0, ThemeModeEnum.values.length - 1)
      ];
    }
  }

  /// Set theme mode and save to SharedPreferences
  Future<void> setThemeMode(ThemeModeEnum mode) async {
    if (state == mode) return;
    
    state = mode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }
}

/// Provider to check if dark mode is active
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeProvider);
  
  if (themeMode == ThemeModeEnum.system) {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }
  
  return themeMode == ThemeModeEnum.dark;
});

/// Provider for Flutter's ThemeMode
final flutterThemeModeProvider = Provider<ThemeMode>((ref) {
  final themeMode = ref.watch(themeProvider);
  return themeMode.toThemeMode();
});
''';
      break;

    case 'GetX':
      content = '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum representing different theme modes
enum ThemeModeEnum {
  light,
  dark,
  system;

  /// Convert ThemeModeEnum to Flutter's ThemeMode
  ThemeMode toThemeMode() {
    switch (this) {
      case ThemeModeEnum.light:
        return ThemeMode.light;
      case ThemeModeEnum.dark:
        return ThemeMode.dark;
      case ThemeModeEnum.system:
        return ThemeMode.system;
    }
  }

  /// Get the string name of the theme mode
  String get name {
    switch (this) {
      case ThemeModeEnum.light:
        return 'Light';
      case ThemeModeEnum.dark:
        return 'Dark';
      case ThemeModeEnum.system:
        return 'System';
    }
  }
}

/// GetX controller for theme management
class ThemeController extends GetxController {
  static const String _themeKey = 'app_theme';
  
  final Rx<ThemeModeEnum> _themeMode = ThemeModeEnum.system.obs;
  
  ThemeModeEnum get currentTheme => _themeMode.value;
  ThemeMode get themeMode => _themeMode.value.toThemeMode();
  
  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }
  
  /// Load theme from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    
    if (themeIndex != null) {
      _themeMode.value = ThemeModeEnum.values[
        themeIndex.clamp(0, ThemeModeEnum.values.length - 1)
      ];
    }
  }
  
  /// Set theme mode and save to SharedPreferences
  Future<void> setThemeMode(ThemeModeEnum mode) async {
    if (_themeMode.value == mode) return;
    
    _themeMode.value = mode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }
  
  /// Check if dark mode is active (including system dark mode)
  bool get isDarkMode {
    if (_themeMode.value == ThemeModeEnum.system) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode.value == ThemeModeEnum.dark;
  }
}

/// Global instance of ThemeController
final themeController = ThemeController();
''';
      break;

    case 'MobX':
      content = '''
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Include generated file
part 'theme_manager.g.dart';

/// Enum representing different theme modes
enum ThemeModeEnum {
  light,
  dark,
  system;

  /// Convert ThemeModeEnum to Flutter's ThemeMode
  ThemeMode toThemeMode() {
    switch (this) {
      case ThemeModeEnum.light:
        return ThemeMode.light;
      case ThemeModeEnum.dark:
        return ThemeMode.dark;
      case ThemeModeEnum.system:
        return ThemeMode.system;
    }
  }

  /// Get the string name of the theme mode
  String get name {
    switch (this) {
      case ThemeModeEnum.light:
        return 'Light';
      case ThemeModeEnum.dark:
        return 'Dark';
      case ThemeModeEnum.system:
        return 'System';
    }
  }
}

/// MobX store for theme management
class ThemeStore = _ThemeStore with _\$ThemeStore;

abstract class _ThemeStore with Store {
  static const String _themeKey = 'app_theme';
  
  @observable
  ThemeModeEnum themeMode = ThemeModeEnum.system;
  
  @observable
  bool isInitialized = false;
  
  _ThemeStore() {
    _loadTheme();
  }
  
  /// Load theme from SharedPreferences
  @action
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);

    if (themeIndex != null) {
      themeMode = ThemeModeEnum.values[
        themeIndex.clamp(0, ThemeModeEnum.values.length - 1)
      ];
    }
    
    isInitialized = true;
  }
  
  /// Set theme mode and save to SharedPreferences
  @action
  Future<void> setThemeMode(ThemeModeEnum mode) async {
    if (themeMode == mode) return;
    
    themeMode = mode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }
  
  /// Get Flutter ThemeMode for MaterialApp
  @computed
  ThemeMode get flutterThemeMode => themeMode.toThemeMode();
  
  /// Check if dark mode is active (including system dark mode)
  @computed
  bool get isDarkMode {
    if (themeMode == ThemeModeEnum.system) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return themeMode == ThemeModeEnum.dark;
  }
}

/// Create a global instance of the store
final themeStore = ThemeStore();
''';
      break;

    case 'Redux':
      content = '''
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum representing different theme modes
enum ThemeModeEnum {
  light,
  dark,
  system;

  /// Convert ThemeModeEnum to Flutter's ThemeMode
  ThemeMode toThemeMode() {
    switch (this) {
      case ThemeModeEnum.light:
        return ThemeMode.light;
      case ThemeModeEnum.dark:
        return ThemeMode.dark;
      case ThemeModeEnum.system:
        return ThemeMode.system;
    }
  }

  /// Get the string name of the theme mode
  String get name {
    switch (this) {
      case ThemeModeEnum.light:
        return 'Light';
      case ThemeModeEnum.dark:
        return 'Dark';
      case ThemeModeEnum.system:
        return 'System';
    }
  }
}

/// Theme state for Redux
class ThemeState {
  final ThemeModeEnum themeMode;
  final bool isInitialized;
  
  ThemeState({
    required this.themeMode,
    required this.isInitialized,
  });
  
  factory ThemeState.initial() => ThemeState(
    themeMode: ThemeModeEnum.system,
    isInitialized: false,
  );
  
  ThemeState copyWith({
    ThemeModeEnum? themeMode,
    bool? isInitialized,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
  
  /// Get Flutter ThemeMode for MaterialApp
  ThemeMode get flutterThemeMode => themeMode.toThemeMode();
  
  /// Check if dark mode is active (including system dark mode)
  bool get isDarkMode {
    if (themeMode == ThemeModeEnum.system) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return themeMode == ThemeModeEnum.dark;
  }
}

/// Theme actions for Redux
class LoadThemeAction {}

class ThemeLoadedAction {
  final ThemeModeEnum themeMode;
  
  ThemeLoadedAction(this.themeMode);
}

class SetThemeAction {
  final ThemeModeEnum themeMode;
  
  SetThemeAction(this.themeMode);
}

/// Theme reducer for Redux
ThemeState themeReducer(ThemeState state, dynamic action) {
  if (action is ThemeLoadedAction) {
    return state.copyWith(
      themeMode: action.themeMode,
      isInitialized: true,
    );
  } else if (action is SetThemeAction) {
    return state.copyWith(themeMode: action.themeMode);
  }
  
  return state;
}

/// Theme middleware for Redux
List<Middleware<AppState>> createThemeMiddleware() {
  return [
    TypedMiddleware<AppState, LoadThemeAction>(_loadTheme),
    TypedMiddleware<AppState, SetThemeAction>(_saveTheme),
  ];
}

void _loadTheme(Store<AppState> store, LoadThemeAction action, NextDispatcher next) async {
  next(action);
  
  final prefs = await SharedPreferences.getInstance();
  final themeIndex = prefs.getInt('app_theme');
  
  if (themeIndex != null) {
    final themeMode = ThemeModeEnum.values[
      themeIndex.clamp(0, ThemeModeEnum.values.length - 1)
    ];
    store.dispatch(ThemeLoadedAction(themeMode));
  } else {
    store.dispatch(ThemeLoadedAction(ThemeModeEnum.system));
  }
}

void _saveTheme(Store<AppState> store, SetThemeAction action, NextDispatcher next) async {
  next(action);
  
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('app_theme', action.themeMode.index);
}

/// Example AppState for Redux
class AppState {
  final ThemeState themeState;
  
  AppState({required this.themeState});
  
  factory AppState.initial() => AppState(
    themeState: ThemeState.initial(),
  );
}
''';
      break;

    default:
      // Default implementation using a simple ThemeManager
      content = '''
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum representing different theme modes
enum ThemeModeEnum {
  light,
  dark,
  system;

  /// Convert ThemeModeEnum to Flutter's ThemeMode
  ThemeMode toThemeMode() {
    switch (this) {
      case ThemeModeEnum.light:
        return ThemeMode.light;
      case ThemeModeEnum.dark:
        return ThemeMode.dark;
      case ThemeModeEnum.system:
        return ThemeMode.system;
    }
  }

  /// Get the string name of the theme mode
  String get name {
    switch (this) {
      case ThemeModeEnum.light:
        return 'Light';
      case ThemeModeEnum.dark:
        return 'Dark';
      case ThemeModeEnum.system:
        return 'System';
    }
  }
}

/// Class to manage the theme state using SharedPreferences
class ThemeManager {
  static const String _themeKey = 'app_theme';
  ThemeModeEnum _currentTheme = ThemeModeEnum.system;
  final List<Function(ThemeModeEnum)> _listeners = [];

  /// Function to initialize the theme manager
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);

    if (themeIndex != null) {
      _currentTheme = ThemeModeEnum
          .values[themeIndex.clamp(0, ThemeModeEnum.values.length - 1)];
    }
  }

  /// Get the current theme mode
  ThemeModeEnum get currentTheme => _currentTheme;

  /// Get the Flutter ThemeMode
  ThemeMode get themeMode => _currentTheme.toThemeMode();

  /// Function to set the theme
  Future<void> setTheme(ThemeModeEnum theme) async {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, theme.index);

      // Notify all listeners
      for (final listener in _listeners) {
        listener(theme);
      }
    }
  }

  /// Add a listener for theme changes
  void addListener(Function(ThemeModeEnum) listener) {
    _listeners.add(listener);
  }

  /// Remove a listener
  void removeListener(Function(ThemeModeEnum) listener) {
    _listeners.remove(listener);
  }

  /// Check if the current theme is dark
  bool get isDarkMode {
    if (_currentTheme == ThemeModeEnum.system) {
      // Get system brightness when in system mode
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _currentTheme == ThemeModeEnum.dark;
  }
}

/// ThemeManager instance to be used throughout the app
final themeManager = ThemeManager();
''';
      break;
  }

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger
      .info('Created file: $filePath with ${stateManagement} implementation');
}

/// Create a file for theme detection
void _generateThemeDetectionFile(HookContext context, String projectName) {
  final filePath =
      '$projectName/lib/core/design_system/theme_extension/theme_detection.dart';
  final content = '''
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Utility class for detecting device theme preferences
class ThemeDetection {
  /// Check if the device is currently using dark mode
  static bool isDarkMode() {
    final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  /// Get the current device brightness
  static Brightness getCurrentBrightness() {
    return SchedulerBinding.instance.platformDispatcher.platformBrightness;
  }

  /// Listen to brightness changes and execute callback when it changes
  static void addBrightnessListener(void Function(Brightness) onChanged) {
    SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      onChanged(brightness);
    };
  }
}

/// Extension to simplify theme access in widgets
extension ThemeDetectionContext on BuildContext {
  /// Check if the device is currently using dark mode
  bool get isDarkMode {
    return ThemeDetection.isDarkMode();
  }

  /// Get the current platform brightness
  Brightness get platformBrightness {
    return ThemeDetection.getCurrentBrightness();
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Helper function to convert string to sentence case (first letter capitalized)
String _toSentenceCase(String text) {
  if (text.isEmpty) return '';
  return text[0].toUpperCase() + text.substring(1);
}
