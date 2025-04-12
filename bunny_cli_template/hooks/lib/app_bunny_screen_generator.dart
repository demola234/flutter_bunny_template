import 'dart:io';

import 'package:mason/mason.dart';

/// Generates the FlutterBunnyScreen file
void _generateFlutterBunnyScreenFile(
    HookContext context,
    String projectName,
    String stateManagement,
    bool hasThemeManager,
    bool hasLocalization,
    bool hasPushNotification) {
  final filePath = '$projectName/lib/app/app_flutter_bunny.dart';

  // Generate imports based on state management and modules
  final stateImports = _generateStateImports(stateManagement, projectName);
  final themeImports = hasThemeManager
      ? '''
import 'package:$projectName/core/design_system/theme_extension/app_theme_extension.dart';
import 'package:$projectName/core/design_system/theme_extension/theme_manager.dart';'''
      : '';
  final localizationImports = hasLocalization
      ? '''
import 'package:$projectName/core/localization/localization.dart';
'''
      : '';
  final pushNotificationImports = hasPushNotification
      ? '''
import 'package:$projectName/core/notifications/models/push_notification_model.dart';
import 'package:$projectName/core/notifications/notification_handler.dart';'''
      : '';

  // Generate content
  final content = '''
import 'package:flutter/material.dart';
$stateImports
$themeImports
$localizationImports
$pushNotificationImports

class FlutterBunnyScreen extends StatefulWidget {
  const FlutterBunnyScreen({Key? key}) : super(key: key);

  @override
  State<FlutterBunnyScreen> createState() => _FlutterBunnyScreenState();
}

class _FlutterBunnyScreenState extends State<FlutterBunnyScreen> {
  ${hasPushNotification ? '''
  String? fcmToken;
  bool notificationsEnabled = true;
  bool isTokenExpanded = false;
  ''' : ''}

  @override
  void initState() {
    super.initState();
    ${hasPushNotification ? '_loadFCMToken();' : ''}
  }

  ${hasPushNotification ? '''
  Future<void> _loadFCMToken() async {
    try {
      final token = await notificationHandler.getFCMToken();
      if (mounted) {
        setState(() {
          fcmToken = token;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          fcmToken = 'Not available';
          notificationsEnabled = false;
        });
      }
    }
  }

  void _sendTestNotification() async {
    final notification = PushNotificationModel(
      title: 'Test Notification',
      body: 'This is a test notification from your app',
      payload: '{"type": "test", "id": "123"}',
    );

    await notificationHandler.showLocalNotification(notification);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(${hasLocalization ? 'context.l10n.notificationSent' : '"Test notification sent"'}),
        backgroundColor: ${hasThemeManager ? 'context.theme.colors.activeButton' : 'Colors.blue'},
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  ''' : ''}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ${hasThemeManager ? 'context.theme.colors.surface' : 'Theme.of(context).scaffoldBackgroundColor'},
      appBar: AppBar(
        title: Text(
          'FlutterBunny',
          style: ${hasThemeManager ? 'context.theme.fonts.headerLarger.copyWith(fontSize: 20)' : 'Theme.of(context).textTheme.titleLarge'},
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        ${hasLocalization ? _generateLanguageActionButton(stateManagement, hasThemeManager) : ''}
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ${hasThemeManager ? '// Theme Section\n              _buildThemeSection(),' : ''}
              
              ${hasThemeManager ? 'const SizedBox(height: 30),' : ''}

              ${hasPushNotification ? '// Notification Section\n              _buildNotificationSection(),' : ''}
              
              ${hasPushNotification ? 'const SizedBox(height: 30),' : ''}

              ${hasLocalization ? '// Language Section\n              ' + _generateLanguageSectionCall(stateManagement) : ''}
            ],
          ),
        ),
      ),
    );
  }

  ${hasThemeManager ? _generateThemeSection(stateManagement, hasLocalization) : ''}

  ${hasPushNotification ? _generateNotificationSection(hasThemeManager, hasLocalization) : ''}

  ${hasLocalization ? _generateLanguageSection(stateManagement, hasThemeManager) : ''}

  ${hasLocalization ? _generateLanguagePickerMethod(hasThemeManager, stateManagement) : ''}
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates imports based on state management
String _generateStateImports(String stateManagement, String projectName) {
  switch (stateManagement) {
    case 'BLoC':
    case 'Bloc':
      return '''
import 'package:$projectName/core/localization/bloc/locale_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';''';
    case 'Provider':
      return '''
import 'package:provider/provider.dart';
import 'package:$projectName/core/localization/providers/localization_provider.dart';
''';

    case 'Riverpod':
      return '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$projectName/core/localization/providers/locale_provider.dart';
''';
    case 'GetX':
      return '''
import 'package:get/get.dart';''';
    case 'MobX':
      return '''
import 'package:mobx/mobx.dart';
import 'package:$projectName/core/localization/stores/localization_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';''';
    case 'Redux':
      return '''
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';''';
    default:
      return '';
  }
}

/// Generates the theme section
String _generateThemeSection(String stateManagement, bool hasLocalization) {
  String themeButton;
  switch (stateManagement) {
    case 'BLoC':
    case 'Bloc':
      themeButton = '''
  Widget _buildThemeModeButton(ThemeModeEnum mode, IconData icon, String label) {
    final isSelected = context.watch<ThemeCubit>().state.themeMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<ThemeCubit>().setTheme(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? context.theme.colors.activeButton
                : context.theme.colors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: context.theme.colors.activeButton.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? context.theme.colors.textWhite
                    : context.theme.colors.textPrimary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? context.theme.colors.textWhite
                      : context.theme.colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }''';
      break;

    case 'Provider':
      themeButton = '''
  Widget _buildThemeModeButton(ThemeModeEnum mode, IconData icon, String label) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isSelected = themeProvider.themeMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          themeProvider.setThemeMode(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? context.theme.colors.activeButton
                : context.theme.colors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: context.theme.colors.activeButton.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? context.theme.colors.textWhite
                    : context.theme.colors.textPrimary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? context.theme.colors.textWhite
                      : context.theme.colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }''';
      break;

    case 'Riverpod':
      themeButton = '''
  Widget _buildThemeModeButton(ThemeModeEnum mode, IconData icon, String label) {
    return Consumer(
      builder: (context, ref, child) {
        final currentTheme = ref.watch(themeProvider);
        final isSelected = currentTheme == mode;
        
        return Expanded(
          child: GestureDetector(
            onTap: () {
              ref.read(themeProvider.notifier).setThemeMode(mode);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.theme.colors.activeButton
                    : context.theme.colors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: context.theme.colors.activeButton.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? context.theme.colors.textWhite
                        : context.theme.colors.textPrimary,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? context.theme.colors.textWhite
                          : context.theme.colors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }''';
      break;

    case 'GetX':
      themeButton = '''
  Widget _buildThemeModeButton(ThemeModeEnum mode, IconData icon, String label) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        final isSelected = controller.currentTheme == mode;
        
        return Expanded(
          child: GestureDetector(
            onTap: () {
              controller.setThemeMode(mode);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.theme.colors.activeButton
                    : context.theme.colors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: context.theme.colors.activeButton.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? context.theme.colors.textWhite
                        : context.theme.colors.textPrimary,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? context.theme.colors.textWhite
                          : context.theme.colors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }''';
      break;

    case 'MobX':
      themeButton = '''
  Widget _buildThemeModeButton(ThemeModeEnum mode, IconData icon, String label) {
    return Observer(
      builder: (_) {
        final isSelected = themeStore.themeMode == mode;
        
        return Expanded(
          child: GestureDetector(
            onTap: () {
              themeStore.setThemeMode(mode);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.theme.colors.activeButton
                    : context.theme.colors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: context.theme.colors.activeButton.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? context.theme.colors.textWhite
                        : context.theme.colors.textPrimary,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? context.theme.colors.textWhite
                          : context.theme.colors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }''';
      break;

    case 'Redux':
      themeButton = '''
  Widget _buildThemeModeButton(ThemeModeEnum mode, IconData icon, String label) {
    return StoreConnector<AppState, ThemeModeEnum>(
      converter: (store) => store.state.themeState.themeMode,
      builder: (context, currentTheme) {
        final isSelected = currentTheme == mode;
        
        return Expanded(
          child: GestureDetector(
            onTap: () {
              StoreProvider.of<AppState>(context).dispatch(SetThemeAction(mode));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.theme.colors.activeButton
                    : context.theme.colors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: context.theme.colors.activeButton.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? context.theme.colors.textWhite
                        : context.theme.colors.textPrimary,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? context.theme.colors.textWhite
                          : context.theme.colors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }''';
      break;

    default:
      themeButton = '''
  Widget _buildThemeModeButton(ThemeModeEnum mode, IconData icon, String label) {
    final isSelected = themeManager.currentTheme == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          themeManager.setTheme(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? context.theme.colors.activeButton
                : context.theme.colors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: context.theme.colors.activeButton.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? context.theme.colors.textWhite
                    : context.theme.colors.textPrimary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? context.theme.colors.textWhite
                      : context.theme.colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }''';
  }

  // Generate the theme section widget
  String themeText = hasLocalization ? 'context.l10n.theme' : "'Theme'";
  String lightText =
      hasLocalization ? 'context.l10n.lightMode' : "'Light Mode'";
  String darkText = hasLocalization ? 'context.l10n.darkMode' : "'Dark Mode'";

  return '''
  Widget _buildThemeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.palette_outlined,
              color: context.theme.colors.activeButton,
              size: 26,
            ),
            const SizedBox(width: 12),
            Text(
           $themeText,
              style: context.theme.fonts.headerLarger.copyWith(
                fontSize: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: context.theme.colors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildThemeModeButton(
                  ThemeModeEnum.light,
                  Icons.light_mode,
                  context.l10n.lightMode,
                ),
                const SizedBox(width: 12),
                _buildThemeModeButton(
                  ThemeModeEnum.dark,
                  Icons.dark_mode,
                 $lightText,
                ),
                const SizedBox(width: 12),
                _buildThemeModeButton(
                  ThemeModeEnum.system,
                  Icons.brightness_auto,
                 $darkText,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  $themeButton
''';
}

/// Generates the notification section
String _generateNotificationSection(
    bool hasThemeManager, bool hasLocalization) {
  final colorStr =
      hasThemeManager ? 'context.theme.colors.activeButton' : 'Colors.blue';
  final titleStyle = hasThemeManager
      ? 'context.theme.fonts.headerLarger.copyWith(fontSize: 20)'
      : 'Theme.of(context).textTheme.titleLarge';
  final headerStyle = hasThemeManager
      ? 'context.theme.fonts.headerSmall'
      : 'Theme.of(context).textTheme.titleMedium';
  final subtitleStyle = hasThemeManager
      ? 'context.theme.fonts.subHeader'
      : 'Theme.of(context).textTheme.bodyMedium';
  final surfaceColor =
      hasThemeManager ? 'context.theme.colors.surfaceCard' : 'Colors.grey[200]';
  final textColor =
      hasThemeManager ? 'context.theme.colors.textPrimary' : 'Colors.black';
  final blueColor =
      hasThemeManager ? 'context.theme.colors.iconBlue' : 'Colors.blue';

  return '''
  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.notifications_outlined,
              color: $colorStr,
              size: 26,
            ),
            const SizedBox(width: 12),
            Text(
              ${hasLocalization ? 'context.l10n.notifications' : "'Notifications'"},
              style: $titleStyle,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: $surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: Text(
                  ${hasLocalization ? 'context.l10n.enableNotifications' : "'Enable Notifications'"},
                  style: $headerStyle,
                ),
                subtitle: Text(
                  ${hasLocalization ? 'context.l10n.receiveNotifications' : "'Receive push notifications'"},
                  style: $subtitleStyle,
                ),
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
                activeColor: $colorStr,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),

              const Divider(height: 1),

              // Test notification button
              ListTile(
                leading: Icon(
                  Icons.send_outlined,
                  color: $blueColor,
                ),
                title: Text(
                  ${hasLocalization ? 'context.l10n.sendTestNotification' : "'Send Test Notification'"},
                  style: $headerStyle,
                ),
                onTap: _sendTestNotification,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),

              // FCM token (collapsible)
              ExpansionTile(
                title: Text(
                  ${hasLocalization ? 'context.l10n.deviceToken' : "'Device Token'"},
                  style: $headerStyle,
                ),
                leading: Icon(
                  Icons.vpn_key_outlined,
                  color: $colorStr,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: ${hasThemeManager ? 'context.theme.colors.surface' : 'Colors.white'},
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ${hasThemeManager ? 'context.theme.colors.inactiveButton' : 'Colors.grey'},
                          width: 1,
                        ),
                      ),
                      child: SelectableText(
                        fcmToken ?? ${hasLocalization ? 'context.l10n.loading' : "'Loading...'"},
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: fcmToken == ${hasLocalization ? 'context.l10n.notAvailable' : "'Not available'"}
                              ? ${hasThemeManager ? 'context.theme.colors.iconRed' : 'Colors.red'}
                              : $textColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
''';
}

/// This is a continuation of the Flutter Bunny Screen Generator
/// Focusing on the language selection functionality and navigation update

/// Generates the language action button for the AppBar
String _generateLanguageActionButton(
    String stateManagement, bool hasThemeManager) {
  final String themeColor =
      hasThemeManager ? 'context.theme.colors.textPrimary' : 'Colors.black';

  switch (stateManagement) {
    case 'BLoC':
    case 'Bloc':
      return '''
        actions: [
          BlocBuilder<LocaleBloc, LocaleState>(
            builder: (context, state) {
              return TextButton.icon(
                onPressed: _showLanguagePicker,
                icon: Text(
                  Localization.getLanguageFlag(state.locale.languageCode),
                  style: const TextStyle(fontSize: 20),
                ),
                label: const Icon(Icons.arrow_drop_down, size: 20),
                style: TextButton.styleFrom(
                  foregroundColor: $themeColor,
                ),
              );
            },
          ),
        ],''';

    case 'Provider':
      return '''
        actions: [
          Consumer<LocalizationProvider>(
            builder: (context, provider, _) {
              return TextButton.icon(
                onPressed: _showLanguagePicker,
                icon: Text(
                  Localization.getLanguageFlag(provider.locale.languageCode),
                  style: const TextStyle(fontSize: 20),
                ),
                label: const Icon(Icons.arrow_drop_down, size: 20),
                style: TextButton.styleFrom(
                 
                ),
              );
            },
          ),
        ],''';

    case 'Riverpod':
      return '''
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final locale = ref.watch(localeProvider);
              return TextButton.icon(
                onPressed: _showLanguagePicker,
                icon: Text(
                  Localization.getLanguageFlag(locale.languageCode),
                  style: const TextStyle(fontSize: 20),
                ),
                label: const Icon(Icons.arrow_drop_down, size: 20),
                style: TextButton.styleFrom(
                 
                ),
              );
            },
          ),
        ],''';

    case 'GetX':
      return '''
        actions: [
          GetBuilder<LocalizationController>(
            builder: (controller) {
              return TextButton.icon(
                onPressed: _showLanguagePicker,
                icon: Text(
                  Localization.getLanguageFlag(controller.locale.languageCode),
                  style: const TextStyle(fontSize: 20),
                ),
                label: const Icon(Icons.arrow_drop_down, size: 20),
                style: TextButton.styleFrom(
                 
                ),
              );
            },
          ),
        ],''';

    case 'MobX':
      return '''
        actions: [
          Observer(
            builder: (_) {
              return TextButton.icon(
                onPressed: _showLanguagePicker,
                icon: Text(
                  Localization.getLanguageFlag(localizationStore.languageCode),
                  style: const TextStyle(fontSize: 20),
                ),
                label: const Icon(Icons.arrow_drop_down, size: 20),
                style: TextButton.styleFrom(
                 
                ),
              );
            },
          ),
        ],''';

    case 'Redux':
      return '''
        actions: [
          StoreConnector<AppState, Locale>(
            converter: (store) => store.state.localeState.locale,
            builder: (context, locale) {
              return TextButton.icon(
                onPressed: _showLanguagePicker,
                icon: Text(
                  Localization.getLanguageFlag(locale.languageCode),
                  style: const TextStyle(fontSize: 20),
                ),
                label: const Icon(Icons.arrow_drop_down, size: 20),
                style: TextButton.styleFrom(
                 
                ),
              );
            },
          ),
        ],''';

    default:
      return '''
        actions: [
          StatefulBuilder(
            builder: (context, setState) {
              return TextButton.icon(
                onPressed: _showLanguagePicker,
                icon: Text(
                  Localization.getLanguageFlag(localeManager.locale.languageCode),
                  style: const TextStyle(fontSize: 20),
                ),
                label: const Icon(Icons.arrow_drop_down, size: 20),
                style: TextButton.styleFrom(
                 
                ),
              );
            },
          ),
        ],''';
  }
}

/// Generates the language section call based on state management
String _generateLanguageSectionCall(String stateManagement) {
  switch (stateManagement) {
    case 'BLoC':
    case 'Bloc':
      return '''
      BlocBuilder<LocaleBloc, LocaleState>(
        builder: (context, state) {
          return _buildLanguageSection(state.locale);
        },
      ),''';

    case 'Provider':
      return '''
      Consumer<LocalizationProvider>(
        builder: (context, provider, _) {
          return _buildLanguageSection(provider.locale);
        },
      ),''';

    case 'Riverpod':
      return '''
      Consumer(
        builder: (context, ref, _) {
          final locale = ref.watch(localeProvider);
          return _buildLanguageSection(locale);
        },
      ),''';

    case 'GetX':
      return '''
      GetBuilder<LocalizationController>(
        builder: (controller) {
          return _buildLanguageSection(controller.locale);
        },
      ),''';

    case 'MobX':
      return '''
      Observer(
        builder: (_) {
          return _buildLanguageSection(localizationStore.locale);
        },
      ),''';

    case 'Redux':
      return '''
      StoreConnector<AppState, Locale>(
        converter: (store) => store.state.localeState.locale,
        builder: (context, locale) {
          return _buildLanguageSection(locale);
        },
      ),''';

    default:
      return '''
      StatefulBuilder(
        builder: (context, setState) {
          localeManager.addListener((locale) => setState(() {}));
          return _buildLanguageSection(localeManager.locale);
        },
      ),''';
  }
}

/// Generates the language section widget
String _generateLanguageSection(String stateManagement, bool hasThemeManager) {
  final surfaceColor =
      hasThemeManager ? 'context.theme.colors.surfaceCard' : 'Colors.grey[200]';
  final titleStyle = hasThemeManager
      ? 'context.theme.fonts.headerLarger.copyWith(fontSize: 20)'
      : 'Theme.of(context).textTheme.titleLarge';
  final headerStyle = hasThemeManager
      ? 'context.theme.fonts.headerSmall'
      : 'Theme.of(context).textTheme.titleMedium';
  final colorStr =
      hasThemeManager ? 'context.theme.colors.activeButton' : 'Colors.blue';

  String languageTile;

  switch (stateManagement) {
    case 'Bloc':
    case 'BLoC':
      languageTile = '''
      return RadioListTile<String>(
        title: Row(
          children: [
            Text(
              Localization.getLanguageFlag(locale.languageCode),
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 12),
            Text(
              Localization.getLanguageName(locale.languageCode),
              style: $headerStyle,
            ),
          ],
        ),
        value: locale.languageCode,
        groupValue: currentLocale.languageCode,
        onChanged: (value) {
          if (value != null) {
            context.read<LocaleBloc>().add(ChangeLocaleEvent(value));
          }
        },
        activeColor: $colorStr,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      );''';
      break;

    case 'Provider':
      languageTile = '''
      return RadioListTile<String>(
        title: Row(
          children: [
            Text(
              Localization.getLanguageFlag(locale.languageCode),
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 12),
            Text(
              Localization.getLanguageName(locale.languageCode),
              style: $headerStyle,
            ),
          ],
        ),
        value: locale.languageCode,
        groupValue: currentLocale.languageCode,
        onChanged: (value) {
          if (value != null) {
            context.changeLocale(value);
          }
        },
        activeColor: $colorStr,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      );''';
      break;

    case 'Riverpod':
      languageTile = '''
      return RadioListTile<String>(
        title: Row(
          children: [
            Text(
              Localization.getLanguageFlag(locale.languageCode),
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 12),
            Text(
              Localization.getLanguageName(locale.languageCode),
              style: $headerStyle,
            ),
          ],
        ),
        value: locale.languageCode,
        groupValue: currentLocale.languageCode,
        onChanged: (value) {
          if (value != null) {
            context.read(localeProvider.notifier).setLocale(value);
          }
        },
        activeColor: $colorStr,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      );''';
      break;

    case 'GetX':
      languageTile = '''
      return RadioListTile<String>(
        title: Row(
          children: [
            Text(
              Localization.getLanguageFlag(locale.languageCode),
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 12),
            Text(
              Localization.getLanguageName(locale.languageCode),
              style: $headerStyle,
            ),
          ],
        ),
        value: locale.languageCode,
        groupValue: currentLocale.languageCode,
        onChanged: (value) {
          if (value != null) {
            Get.find<LocalizationController>().setLocale(value);
          }
        },
        activeColor: $colorStr,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      );''';
      break;

    case 'MobX':
      languageTile = '''
      return RadioListTile<String>(
        title: Row(
          children: [
            Text(
              Localization.getLanguageFlag(locale.languageCode),
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 12),
            Text(
              Localization.getLanguageName(locale.languageCode),
              style: $headerStyle,
            ),
          ],
        ),
        value: locale.languageCode,
        groupValue: currentLocale.languageCode,
        onChanged: (value) {
          if (value != null) {
            localizationStore.setLocale(value);
          }
        },
        activeColor: $colorStr,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      );''';
      break;

    case 'Redux':
      languageTile = '''
      return RadioListTile<String>(
        title: Row(
          children: [
            Text(
              Localization.getLanguageFlag(locale.languageCode),
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 12),
            Text(
              Localization.getLanguageName(locale.languageCode),
              style: $headerStyle,
            ),
          ],
        ),
        value: locale.languageCode,
        groupValue: currentLocale.languageCode,
        onChanged: (value) {
          if (value != null) {
            StoreProvider.of<AppState>(context).dispatch(setLocale(value));
          }
        },
        activeColor: $colorStr,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      );''';
      break;

    default:
      languageTile = '''
      return RadioListTile<String>(
        title: Row(
          children: [
            Text(
              Localization.getLanguageFlag(locale.languageCode),
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 12),
            Text(
              Localization.getLanguageName(locale.languageCode),
              style: $headerStyle,
            ),
          ],
        ),
        value: locale.languageCode,
        groupValue: currentLocale.languageCode,
        onChanged: (value) {
          if (value != null) {
            localeManager.setLocaleByLanguageCode(value);
          }
        },
        activeColor: $colorStr,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      );''';
  }

  return '''
  Widget _buildLanguageSection(Locale currentLocale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.language_outlined,
              color: $colorStr,
              size: 26,
            ),
            const SizedBox(width: 12),
            Text(
              context.l10n.language,
              style: $titleStyle,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: $surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: Localization.supportedLocales.map((locale) {
              $languageTile
            }).toList(),
          ),
        ),
      ],
    );
  }
''';
}

/// Generate the language picker bottom sheet
String _generateLanguagePickerMethod(
    bool hasThemeManager, String stateManagement) {
  final surfaceColor =
      hasThemeManager ? 'context.theme.colors.surfaceCard' : 'Colors.grey[200]';
  final titleStyle = hasThemeManager
      ? 'context.theme.fonts.headerLarger.copyWith(fontSize: 20)'
      : 'Theme.of(context).textTheme.titleLarge';
  final headerStyle = hasThemeManager
      ? 'context.theme.fonts.headerSmall'
      : 'Theme.of(context).textTheme.titleMedium';
  final colorStr =
      hasThemeManager ? 'context.theme.colors.activeButton' : 'Colors.blue';

  String languageListTiles;

  switch (stateManagement) {
    case 'Bloc':
    case 'BLoC':
      languageListTiles = '''
        return BlocBuilder<LocaleBloc, LocaleState>(
          builder: (context, state) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    context.l10n.language,
                    style: $titleStyle,
                  ),
                  const SizedBox(height: 20),
                  ...Localization.supportedLocales.map((locale) {
                    final isSelected = state.locale.languageCode == locale.languageCode;
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? $colorStr.withOpacity(0.1)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          Localization.getLanguageFlag(locale.languageCode),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      title: Text(
                        Localization.getLanguageName(locale.languageCode),
                        style: $headerStyle,
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: $colorStr,
                            )
                          : null,
                      onTap: () {
                        context.read<LocaleBloc>().add(
                              ChangeLocaleEvent(locale.languageCode),
                            );
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );''';
      break;

    case 'Provider':
      languageListTiles = '''
        return Consumer<LocalizationProvider>(
          builder: (context, provider, _) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    context.l10n.language,
                    style: $titleStyle,
                  ),
                  const SizedBox(height: 20),
                  ...Localization.supportedLocales.map((locale) {
                    final isSelected = provider.locale.languageCode == locale.languageCode;
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? $colorStr.withOpacity(0.1)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          Localization.getLanguageFlag(locale.languageCode),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      title: Text(
                        Localization.getLanguageName(locale.languageCode),
                        style: $headerStyle,
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: $colorStr,
                            )
                          : null,
                      onTap: () {
                        context.changeLocale(locale.languageCode);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );''';
      break;

    case 'Riverpod':
      languageListTiles = '''
        return Consumer(
          builder: (context, ref, _) {
            final currentLocale = ref.watch(localeProvider);
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    context.l10n.language,
                    style: $titleStyle,
                  ),
                  const SizedBox(height: 20),
                  ...Localization.supportedLocales.map((locale) {
                    final isSelected = currentLocale.languageCode == locale.languageCode;
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? $colorStr.withOpacity(0.1)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          Localization.getLanguageFlag(locale.languageCode),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      title: Text(
                        Localization.getLanguageName(locale.languageCode),
                        style: $headerStyle,
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: $colorStr,
                            )
                          : null,
                      onTap: () {
                        ref.read(localeProvider.notifier).setLocale(locale.languageCode);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );''';
      break;

    case 'GetX':
      languageListTiles = '''
        return GetBuilder<LocalizationController>(
          builder: (controller) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    context.l10n.language,
                    style: $titleStyle,
                  ),
                  const SizedBox(height: 20),
                  ...Localization.supportedLocales.map((locale) {
                    final isSelected = controller.locale.languageCode == locale.languageCode;
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? $colorStr.withOpacity(0.1)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          Localization.getLanguageFlag(locale.languageCode),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      title: Text(
                        Localization.getLanguageName(locale.languageCode),
                        style: $headerStyle,
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: $colorStr,
                            )
                          : null,
                      onTap: () {
                        controller.setLocale(locale.languageCode);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );''';
      break;

    case 'MobX':
      languageListTiles = '''
        return Observer(
          builder: (_) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    context.l10n.language,
                    style: $titleStyle,
                  ),
                  const SizedBox(height: 20),
                  ...Localization.supportedLocales.map((locale) {
                    final isSelected = localizationStore.locale.languageCode == locale.languageCode;
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? $colorStr.withOpacity(0.1)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          Localization.getLanguageFlag(locale.languageCode),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      title: Text(
                        Localization.getLanguageName(locale.languageCode),
                        style: $headerStyle,
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: $colorStr,
                            )
                          : null,
                      onTap: () {
                        localizationStore.setLocale(locale.languageCode);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );''';
      break;

    case 'Redux':
      languageListTiles = '''
        return StoreConnector<AppState, Locale>(
          converter: (store) => store.state.localeState.locale,
          builder: (context, currentLocale) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    context.l10n.language,
                    style: $titleStyle,
                  ),
                  const SizedBox(height: 20),
                  ...Localization.supportedLocales.map((locale) {
                    final isSelected = currentLocale.languageCode == locale.languageCode;
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? $colorStr.withOpacity(0.1)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          Localization.getLanguageFlag(locale.languageCode),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      title: Text(
                        Localization.getLanguageName(locale.languageCode),
                        style: $headerStyle,
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: $colorStr,
                            )
                          : null,
                      onTap: () {
                        StoreProvider.of<AppState>(context).dispatch(setLocale(locale.languageCode));
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );''';
      break;

    default:
      languageListTiles = '''
        return StatefulBuilder(
          builder: (context, setState) {
            localeManager.addListener((locale) => setState(() {}));
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    context.l10n.language,
                    style: $titleStyle,
                  ),
                  const SizedBox(height: 20),
                  ...Localization.supportedLocales.map((locale) {
                    final isSelected = localeManager.locale.languageCode == locale.languageCode;
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? $colorStr.withOpacity(0.1)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          Localization.getLanguageFlag(locale.languageCode),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      title: Text(
                        Localization.getLanguageName(locale.languageCode),
                        style: $headerStyle,
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: $colorStr,
                            )
                          : null,
                      onTap: () {
                        localeManager.setLocaleByLanguageCode(locale.languageCode);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );''';
  }

  return '''
  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: $surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        $languageListTiles
      },
    );
  }
''';
}

/// Update navigation to include FlutterBunnyScreen
void _updateNavigationForFlutterBunnyScreen(
    HookContext context, String projectName) {
  // Try to update navigation in app.dart or main.dart
  _updateAppDartForNavigation(context, projectName);

  // Create a route constants file if it doesn't exist
  _createRouteConstantsFile(context, projectName);
}

/// Update app.dart to include the FlutterBunnyScreen in navigation
void _updateAppDartForNavigation(HookContext context, String projectName) {
  final appDartPaths = [
    '$projectName/lib/app.dart',
    '$projectName/lib/core/app.dart',
    '$projectName/lib/presentation/app.dart',
  ];

  File? appDartFile;

  // Find the app.dart file
  for (final path in appDartPaths) {
    final file = File(path);
    if (file.existsSync()) {
      appDartFile = file;
      break;
    }
  }

  // If app.dart wasn't found, try main.dart
  if (appDartFile == null) {
    final mainDartFile = File('$projectName/lib/main.dart');
    if (mainDartFile.existsSync()) {
      appDartFile = mainDartFile;
    }
  }

  if (appDartFile == null) {
    context.logger
        .warn('Could not find app.dart or main.dart to update navigation');
    return;
  }

  String content = appDartFile.readAsStringSync();
  bool modified = false;

  // Look for different navigation patterns and update accordingly
  if (content.contains('routes: {') && !content.contains("'/flutter_bunny'")) {
    // GoRouter or Router pattern
    final routePattern = RegExp(r'routes: \{([^}]*)\}', dotAll: true);
    final routeMatch = routePattern.firstMatch(content);

    if (routeMatch != null) {
      final routesContent = routeMatch.group(1)!;
      final insertPoint = routesContent.lastIndexOf(',') + 1;

      final newRoute = '''
        
        '/flutter_bunny': (context) => const FlutterBunnyScreen(),''';

      content = content.replaceFirst(
        routesContent,
        routesContent.substring(0, insertPoint) +
            newRoute +
            routesContent.substring(insertPoint),
      );

      modified = true;
    }
  } else if (content.contains('getPages: [') &&
      !content.contains("name: '/flutter_bunny'")) {
    // GetX pattern
    final pagesPattern = RegExp(r'getPages: \[([^\]]*)\]', dotAll: true);
    final pagesMatch = pagesPattern.firstMatch(content);

    if (pagesMatch != null) {
      final pagesContent = pagesMatch.group(1)!;
      final insertPoint = pagesContent.lastIndexOf(',') + 1;

      final newPage = '''
        
        GetPage(
          name: '/flutter_bunny',
          page: () => const FlutterBunnyScreen(),
        ),''';

      content = content.replaceFirst(
        pagesContent,
        pagesContent.substring(0, insertPoint) +
            newPage +
            pagesContent.substring(insertPoint),
      );

      modified = true;
    }
  } else if (content.contains('onGenerateRoute:') &&
      !content.contains("case '/flutter_bunny'")) {
    // onGenerateRoute pattern
    final onGeneratePattern =
        RegExp(r'onGenerateRoute:.*?\{(.*?)\}', dotAll: true);
    final onGenerateMatch = onGeneratePattern.firstMatch(content);

    if (onGenerateMatch != null) {
      final routerContent = onGenerateMatch.group(1)!;
      final defaultCaseIndex = routerContent.indexOf('default:');

      if (defaultCaseIndex != -1) {
        final newCase = '''
        case '/flutter_bunny':
          return MaterialPageRoute(
            builder: (_) => const FlutterBunnyScreen(),
          );
        ''';

        content = content.replaceFirst(
          'default:',
          newCase + 'default:',
        );

        modified = true;
      }
    }
  } else {
    // Look for a home: property to potentially add a drawer navigation or bottom bar
    final homePattern = RegExp(r'home:\s*(const\s*)?\w+\(');
    final homeMatch = homePattern.firstMatch(content);

    if (homeMatch != null) {
      context.logger.info(
          'Found home widget, consider adding a drawer or bottom navigation bar manually to access FlutterBunnyScreen');
    }
  }

  // Write back modified content
  if (modified) {
    appDartFile.writeAsStringSync(content);
    context.logger.success(
        'Updated ${appDartFile.path} with FlutterBunnyScreen navigation');
  } else {
    context.logger.info(
        'Could not automatically add navigation for FlutterBunnyScreen. Consider adding it manually.');
  }
}

/// Create a route constants file if it doesn't exist
void _createRouteConstantsFile(HookContext context, String projectName) {
  final routesDirPaths = [
    '$projectName/lib/core/routes',
    '$projectName/lib/routes',
    '$projectName/lib/navigation',
  ];

  String targetDir = routesDirPaths[0];
  bool dirExists = false;

  // Check if one of the directory paths exists
  for (final path in routesDirPaths) {
    final dir = Directory(path);
    if (dir.existsSync()) {
      targetDir = path;
      dirExists = true;
      break;
    }
  }

  // Create directory if none exists
  if (!dirExists) {
    Directory(targetDir).createSync(recursive: true);
    context.logger.info('Created routes directory: $targetDir');
  }

  final routeConstantsFile = File('$targetDir/route_constants.dart');

  // Only create the file if it doesn't exist
  if (!routeConstantsFile.existsSync()) {
    final content = '''
/// Constants for app routes
class RouteConstants {
  RouteConstants._();
  
  /// Home route
  static const String home = '/';
  
  /// FlutterBunny showcase screen
  static const String flutterBunny = '/flutter_bunny';
  
  // Add other routes here
}
''';

    routeConstantsFile.writeAsStringSync(content);
    context.logger
        .success('Created route constants file: ${routeConstantsFile.path}');
  } else {
    // If file exists, try to update it with the flutter_bunny route
    String content = routeConstantsFile.readAsStringSync();

    if (!content.contains('flutterBunny') &&
        !content.contains('flutter_bunny')) {
      final lastConstPattern = RegExp(r'static const String \w+ = .*?;');
      final matches = lastConstPattern.allMatches(content).toList();

      if (matches.isNotEmpty) {
        final lastMatch = matches.last;
        final insertPoint = lastMatch.end;

        final newRoute = '''
  
  /// FlutterBunny showcase screen
  static const String flutterBunny = '/flutter_bunny';''';

        content = content.substring(0, insertPoint) +
            newRoute +
            content.substring(insertPoint);
        routeConstantsFile.writeAsStringSync(content);
        context.logger
            .success('Updated route constants file with FlutterBunny route');
      }
    }
  }
}

/// Main generator function that calls all the other functions to create a complete FlutterBunnyScreen implementation
void generateFlutterBunnyScreen(HookContext context, String projectName,
    String stateManagement, List<dynamic> modules) {
  context.logger.info('Generating FlutterBunnyScreen for $projectName');

  // Check which modules are enabled
  final hasThemeManager = modules.contains('Theme Manager');
  final hasLocalization = modules.contains('Localization');
  final hasPushNotification = modules.contains('Push Notification');

  // Generate the FlutterBunnyScreen file
  _generateFlutterBunnyScreenFile(context, projectName, stateManagement,
      hasThemeManager, hasLocalization, hasPushNotification);

  // Update navigation to include FlutterBunnyScreen
  _updateNavigationForFlutterBunnyScreen(context, projectName);

  // Generate a README.md with documentation if a drawer needs to be added manually
  // _generateReadmeFile(context, projectName, hasThemeManager, hasLocalization,
  //     hasPushNotification);

  context.logger.success('FlutterBunnyScreen generated successfully!');
}

/// Generate a README.md file with documentation
void _generateReadmeFile(HookContext context, String projectName,
    bool hasThemeManager, bool hasLocalization, bool hasPushNotification) {
  final filePath = '$projectName/README_FLUTTER_BUNNY.md';

  final enabledModules = <String>[];
  if (hasThemeManager) enabledModules.add('Theme Manager');
  if (hasLocalization) enabledModules.add('Localization');
  if (hasPushNotification) enabledModules.add('Push Notification');

  final modulesText = enabledModules.isEmpty
      ? 'No modules are enabled.'
      : 'The following modules are enabled:\n' +
          enabledModules.map((m) => '- $m').join('\n');

  final content = '''# FlutterBunny Screen

This is a showcase screen that demonstrates the capabilities of your Flutter app, focusing on the modules you've selected during project generation.

## Enabled Modules

$modulesText

## How to Access

The FlutterBunnyScreen is registered at the route `/flutter_bunny`. You can navigate to it using:

```dart
Navigator.of(context).pushNamed('/flutter_bunny');
```

### Adding to Drawer or Bottom Navigation

If your app uses a drawer or bottom navigation bar, you can add the FlutterBunnyScreen as follows:

#### Drawer Example

```dart
Drawer(
  child: ListView(
    children: [
      // Other drawer items...
      ListTile(
        leading: Icon(Icons.pets),
        title: Text('Flutter Bunny'),
        onTap: () {
          Navigator.of(context).pushNamed('/flutter_bunny');
        },
      ),
    ],
  ),
)
```

#### Bottom Navigation Example

```dart
BottomNavigationBar(
  items: [
    // Other items...
    BottomNavigationBarItem(
      icon: Icon(Icons.pets),
      label: 'Flutter Bunny',
    ),
  ],
  onTap: (index) {
    if (index == /* your index */) {
      Navigator.of(context).pushNamed('/flutter_bunny');
    }
  },
)
```

## Features

${hasThemeManager ? '- **Theme Manager**: Allows switching between light, dark, and system themes\n' : ''}${hasLocalization ? '- **Localization**: Demonstrates language switching functionality\n' : ''}${hasPushNotification ? '- **Push Notifications**: Shows sending test notifications and viewing device token\n' : ''}

''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created documentation file: $filePath');
}

/// Main function for testing
void main(List<String> args) {
  // This is a placeholder main method
  print('Mason pre-generation hook for Flutter Bunny Screen');
}
