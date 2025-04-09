import 'dart:io';

import 'package:mason/mason.dart';

/// Generates a FlutterBunny showcase screen based on the selected state management approach
void generateFlutterBunnyScreen(
    HookContext context, String projectName, String stateManagement, List<dynamic> modules) {
  // Check if necessary modules are present
  final hasThemeManager = modules.contains('Theme Manager');
  final hasLocalization = modules.contains('Localization');
  final hasPushNotification = modules.contains('Push Notification');

  // Only generate the showcase screen if at least one feature is available
  if (!hasThemeManager && !hasLocalization && !hasPushNotification) {
    context.logger.info(
        'No showcase features (Theme Manager, Localization, Push Notification) selected, skipping FlutterBunny screen generation');
    return;
  }

  context.logger.info('Generating FlutterBunny showcase screen for $projectName');

  // Create directory if it doesn't exist
  final directory = Directory('$projectName/lib/app');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
    context.logger.info('Created directory: lib/app');
  }

  // Generate different implementations based on state management
  final filePath = '$projectName/lib/app/flutter_bunny_screen.dart';
  String content = '';

  switch (stateManagement) {
    case 'Bloc':
    case 'BLoC':
      content = _generateBlocImplementation(
          projectName, hasThemeManager, hasLocalization, hasPushNotification);
      break;
    case 'Provider':
      content = _generateProviderImplementation(
          projectName, hasThemeManager, hasLocalization, hasPushNotification);
      break;
    case 'Riverpod':
      content = _generateRiverpodImplementation(
          projectName, hasThemeManager, hasLocalization, hasPushNotification);
      break;
    case 'GetX':
      content = _generateGetXImplementation(
          projectName, hasThemeManager, hasLocalization, hasPushNotification);
      break;
    case 'MobX':
      content = _generateMobXImplementation(
          projectName, hasThemeManager, hasLocalization, hasPushNotification);
      break;
    case 'Redux':
      content = _generateReduxImplementation(
          projectName, hasThemeManager, hasLocalization, hasPushNotification);
      break;
    default:
      content = _generateDefaultImplementation(
          projectName, hasThemeManager, hasLocalization, hasPushNotification);
  }

  // Create the file
  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created FlutterBunny showcase screen: $filePath');

  // Update app.dart to use the screen
  _updateAppDartToUseFlutterBunnyScreen(context, projectName);

  context.logger.success('FlutterBunny showcase screen generated successfully!');
}

/// Update app.dart to use FlutterBunnyScreen as home widget
void _updateAppDartToUseFlutterBunnyScreen(HookContext context, String projectName) {
  final appDartPath = '$projectName/lib/app/app.dart';
  final appDartFile = File(appDartPath);
  
  if (!appDartFile.existsSync()) {
    context.logger.warn('app.dart not found, skipping update for FlutterBunnyScreen');
    return;
  }

  String content = appDartFile.readAsStringSync();
  
  // Add import if not already present
  if (!content.contains('flutter_bunny_screen.dart')) {
    final importPattern = RegExp(r'import .*;\n');
    final lastImportMatch = importPattern.allMatches(content).lastOrNull;
    
    if (lastImportMatch != null) {
      final insertPosition = lastImportMatch.end;
      content = content.substring(0, insertPosition) +
          "import 'flutter_bunny_screen.dart';\n" +
          content.substring(insertPosition);
    }
  }
  
  // Update home: property to use FlutterBunnyScreen
  final homePattern = RegExp(r'home:\s*[^,]*,');
  if (homePattern.hasMatch(content)) {
    content = content.replaceFirst(
      homePattern, 
      'home: const FlutterBunnyScreen(),'
    );
    
    // Write updated content back to file
    appDartFile.writeAsStringSync(content);
    context.logger.info('Updated app.dart to use FlutterBunnyScreen');
  } else {
    context.logger.warn('Could not find home: property in app.dart');
  }
}

/// Generate BLoC implementation of FlutterBunnyScreen
String _generateBlocImplementation(String projectName, bool hasThemeManager,
    bool hasLocalization, bool hasPushNotification) {
  // Determine imports based on selected modules
  List<String> imports = [
    'package:flutter/material.dart',
    'package:flutter_bloc/flutter_bloc.dart',
  ];

  if (hasThemeManager) {
    imports.add('../core/design_system/theme_extension/app_theme_extension.dart');
    imports.add('../core/design_system/theme_extension/theme_manager.dart');
  }

  if (hasLocalization) {
    imports.add('../core/localization/localization.dart');
  }

  if (hasPushNotification) {
    imports.add('../core/notifications/models/push_notification_model.dart');
    imports.add('../core/notifications/notification_handler.dart');
  }

  final importsSection = imports.map((i) => 'import \'$i\';').join('\n');

  return '''$importsSection

/// A showcase screen for FlutterBunny that demonstrates themes, localization, and notifications
/// This implementation uses BLoC for state management
class FlutterBunnyScreen extends StatefulWidget {
  const FlutterBunnyScreen({Key? key}) : super(key: key);

  @override
  State<FlutterBunnyScreen> createState() => _FlutterBunnyScreenState();
}

class _FlutterBunnyScreenState extends State<FlutterBunnyScreen> {
  ${hasPushNotification ? '''
  String? fcmToken;
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadFCMToken();
  }

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
        content: Text(${hasLocalization ? 'context.strings.notificationSent' : "'Notification sent'"}),
        backgroundColor: ${hasThemeManager ? 'context.theme.colors.activeButton' : 'Colors.blue'},
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  ''' : ''}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ${hasThemeManager ? 'context.theme.colors.surface' : 'Colors.white'},
      appBar: AppBar(
        title: Text(
          'FlutterBunny',
          style: ${hasThemeManager ? 'context.theme.fonts.headerLarger.copyWith(fontSize: 20,)' : 'const TextStyle(fontSize: 20,)'},
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        ${hasLocalization ? '''
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
                  foregroundColor: ${hasThemeManager ? 'context.theme.colors.textPrimary' : 'Colors.black'},
                ),
              );
            },
          ),
        ],
        ''' : ''}
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

              ${hasPushNotification && hasLocalization ? 'const SizedBox(height: 30),' : ''}

              ${hasLocalization ? '''
              // Language Section
              BlocBuilder<LocaleBloc, LocaleState>(
                builder: (context, state) {
                  return _buildLanguageSection(state.locale);
                },
              ),
              ''' : ''}
            ],
          ),
        ),
      ),
    );
  }

  ${hasThemeManager ? '''
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
              ${hasLocalization ? 'context.strings.theme' : "'Theme'"},
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
                  ${hasLocalization ? 'context.strings.lightMode' : "'Light'"},
                ),
                const SizedBox(width: 12),
                _buildThemeModeButton(
                  ThemeModeEnum.dark,
                  Icons.dark_mode,
                  ${hasLocalization ? 'context.strings.darkMode' : "'Dark'"},
                ),
                const SizedBox(width: 12),
                _buildThemeModeButton(
                  ThemeModeEnum.system,
                  Icons.brightness_auto,
                  ${hasLocalization ? 'context.strings.systemMode' : "'System'"},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeModeButton(
      ThemeModeEnum mode, IconData icon, String label) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isSelected = state.themeMode == mode;
        
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
      },
    );
  }
  ''' : ''}

  ${hasPushNotification ? '''
  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.notifications_outlined,
              color: ${hasThemeManager ? 'context.theme.colors.activeButton' : 'Colors.blue'},
              size: 26,
            ),
            const SizedBox(width: 12),
            Text(
              ${hasLocalization ? 'context.strings.notifications' : "'Notifications'"},
              style: ${hasThemeManager ? 'context.theme.fonts.headerLarger.copyWith(fontSize: 20,)' : 'const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)'},
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: ${hasThemeManager ? 'context.theme.colors.surfaceCard' : 'Colors.grey[100]'},
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
                  ${hasLocalization ? 'context.strings.enableNotifications' : "'Enable Notifications'"},
                  style: ${hasThemeManager ? 'context.theme.fonts.headerSmall' : 'const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)'},
                ),
                subtitle: Text(
                  ${hasLocalization ? 'context.strings.receiveNotifications' : "'Receive push notifications'"},
                  style: ${hasThemeManager ? 'context.theme.fonts.subHeader' : 'TextStyle(fontSize: 14, color: Colors.grey[600])'},
                ),
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
                activeColor: ${hasThemeManager ? 'context.theme.colors.activeButton' : 'Colors.blue'},
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),

              const Divider(height: 1),

              // Test notification button
              ListTile(
                leading: Icon(
                  Icons.send_outlined,
                  color: ${hasThemeManager ? 'context.theme.colors.iconBlue' : 'Colors.blue'},
                ),
                title: Text(
                  ${hasLocalization ? 'context.strings.sendTestNotification' : "'Send Test Notification'"},
                  style: ${hasThemeManager ? 'context.theme.fonts.headerSmall' : 'const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)'},
                ),
                onTap: _sendTestNotification,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),

              // FCM token (collapsible)
              ExpansionTile(
                title: Text(
                  ${hasLocalization ? 'context.strings.deviceToken' : "'Device Token'"},
                  style: ${hasThemeManager ? 'context.theme.fonts.headerSmall' : 'const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)'},
                ),
                leading: Icon(
                  Icons.vpn_key_outlined,
                  color: ${hasThemeManager ? 'context.theme.colors.activeButton' : 'Colors.blue'},
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
                          color: ${hasThemeManager ? 'context.theme.colors.inactiveButton' : 'Colors.grey[300]!'},
                          width: 1,
                        ),
                      ),
                      child: SelectableText(
                        fcmToken ?? ${hasLocalization ? 'context.strings.loading' : "'Loading...'"},
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: fcmToken == ${hasLocalization ? 'context.strings.notAvailable' : "'Not available'"} 
                            ? ${hasThemeManager ? 'context.theme.colors.iconRed' : 'Colors.red'} 
                            : ${hasThemeManager ? 'context.theme.colors.textPrimary' : 'Colors.black'},
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
  ''' : ''}

  ${hasLocalization ? '''
  Widget _buildLanguageSection(Locale currentLocale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.language_outlined,
              color: ${hasThemeManager ? 'context.theme.colors.activeButton' : 'Colors.blue'},
              size: 26,
            ),
            const SizedBox(width: 12),
            Text(
              context.strings.language,
              style: ${hasThemeManager ? 'context.theme.fonts.headerLarger.copyWith(fontSize: 20,)' : 'const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)'},
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: ${hasThemeManager ? 'context.theme.colors.surfaceCard' : 'Colors.grey[100]'},
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
                      style: ${hasThemeManager ? 'context.theme.fonts.headerSmall' : 'const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)'},
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
                activeColor: ${hasThemeManager ? 'context.theme.colors.activeButton' : 'Colors.blue'},
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ${hasThemeManager ? 'context.theme.colors.surfaceCard' : 'Colors.white'},
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                    context.strings.language,
                    style: ${hasThemeManager ? 'context.theme.fonts.headerLarger.copyWith(fontSize: 20,)' : 'const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)'},
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
                              ? ${hasThemeManager ? 'context.theme.colors.activeButton.withOpacity(0.1)' : 'Colors.blue.withOpacity(0.1)'}
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
                        style: ${hasThemeManager ? 'context.theme.fonts.headerSmall' : 'const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)'},
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: ${hasThemeManager ? 'context.theme.colors.activeButton' : 'Colors.blue'},
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
        );
      },
    );
  }
  ''' : ''}
}
''';
}

/// Generate Provider implementation of FlutterBunnyScreen
String _generateProviderImplementation(String projectName, bool hasThemeManager,
    bool hasLocalization, bool hasPushNotification) {
  // Determine imports based on selected modules
  List<String> imports = [
    'package:flutter/material.dart',
    'package:provider/provider.dart',
  ];

  if (hasThemeManager) {
    imports
        .add('../core/design_system/theme_extension/app_theme_extension.dart');
    imports.add('../core/design_system/theme_extension/theme_manager.dart');
  }

  if (hasLocalization) {
    imports.add('../core/localization/localization.dart');
  }

  if (hasPushNotification) {
    imports.add('../core/notifications/models/push_notification_model.dart');
    imports.add('../core/notifications/notification_handler.dart');
  }

  final importsSection = imports.map((i) => 'import \'$i\';').join('\n');

  return '''$importsSection

/// A showcase screen for FlutterBunny that demonstrates themes, localization, and notifications
/// This implementation uses Provider for state management
class FlutterBunnyScreen extends StatefulWidget {
  const FlutterBunnyScreen({Key? key}) : super(key: key);

  @override
  State<FlutterBunnyScreen> createState() => _FlutterBunnyScreenState();
}

class _FlutterBunnyScreenState extends State<FlutterBunnyScreen> {
  ${hasPushNotification ? '''
  String? fcmToken;
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadFCMToken();
  }

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
        content: Text(${hasLocalization ? 'context.strings.notificationSent' : "'Notification sent'"}),
        backgroundColor: ${hasThemeManager ? 'context.theme.colors.activeButton' : 'Colors.blue'},
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  ''' : ''}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ${hasThemeManager ? 'context.theme.colors.surface' : 'Colors.white'},
      appBar: AppBar(
        title: Text(
          'FlutterBunny',
          style: ${hasThemeManager ? 'context.theme.fonts.headerLarger.copyWith(fontSize: 20,)' : 'const TextStyle(fontSize: 20,)'},
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        ${hasLocalization ? '''
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
                  foregroundColor: ${hasThemeManager ? 'context.theme.colors.textPrimary' : 'Colors.black'},
                ),
              );
            },
          ),
        ],
        ''' : ''}
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

              ${hasPushNotification && hasLocalization ? 'const SizedBox(height: 30),' : ''}

              ${hasLocalization ? '''
              // Language Section
              Consumer<LocalizationProvider>(
                builder: (context, provider, _) {
                  return _buildLanguageSection(provider.locale);
                },
              ),
              ''' : ''}
            ],
          ),
        ),
      ),
    );
  }

  ${hasThemeManager ? '''
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
              ${hasLocalization ? 'context.strings.theme' : "'Theme'"},
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
                  ${hasLocalization ? 'context.strings.lightMode' : "'Light'"},
                ),
                const SizedBox(width: 12),
                _buildThemeModeButton(
                  ThemeModeEnum.dark,
                  Icons.dark_mode,
                  ${hasLocalization ? 'context.strings.darkMode' : "'Dark'"},
                ),
                const SizedBox(width: 12),
                _buildThemeModeButton(
                  ThemeModeEnum.system,
                  Icons.brightness_auto,
                  ${hasLocalization ? 'context.strings.systemMode' : "'System'"},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeModeButton(
      ThemeModeEnum mode, IconData icon, String label) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isSelected = themeProvider.themeMode == mode;
        
        return Expanded(
          child: GestureDetector(
            onTap: () {
              context.read<ThemeProvider>().setThemeMode(mode);
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
      },
    );
  }
  ''' : ''}

  ${hasPushNotification ? '''
  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.notifications_outlined,
              color: ${hasThemeManager ? 'context.theme.colors.activeButton' : 'Colors.blue'},
              size: 26,
            ),
            const SizedBox(width: 12),
            Text(
              ${hasLocalization ? 'context.strings.notifications' : "'Notifications'"},
              style: ${hasThemeManager ? 'context.theme.fonts.headerLarger.copyWith(fontSize: 20,)' : 'const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)'},
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: ${hasThemeManager ? 'context.theme.colors.surfaceCard' : 'Colors.grey[100]'},
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
                  ${hasLocalization ? 'context.strings.enableNotifications' : "'Enable Notifications'"},
                  style: ${hasThemeManager ? 'context.theme.fonts.headerSmall' : 'const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)'},
                ),
                subtitle: Text(
                  ${hasLocalization ? 'context.strings.receiveNotifications' : "'Receive push notifications'"},
                  style: ${hasThemeManager ? 'context.theme.fonts.subHeader' : 'TextStyle(fontSize: 14, color: Colors.grey[600])'},
                ),
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
                activeColor: ${hasThemeManager ? 'context.theme.colors.activeButton' : 'Colors.blue'},
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),

              const Divider(height: 1),

              // Test notification button
              ListTile(
                leading: Icon(
                  Icons.send_outlined,
                  color: ${hasThemeManager ? 'context.theme.colors.iconBlue' : 'Colors.blue'},
                ),
                title: Text(
                  ${hasLocalization ? 'context.strings.sendTestNotification' : "'Send Test Notification'"},
                  style: ${hasThemeManager ? 'context.theme.fonts.headerSmall' : 'const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)'},
                ),
                onTap: _sendTestNotification,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),

              // FCM token (collapsible)
              ExpansionTile(
                title: Text(
                  ${hasLocalization ? 'context.strings.deviceToken' : "'Device Token'"},
                  style: ${hasThemeManager ? 'context.theme.fonts.headerSmall' : 'const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)'},
                ),
                leading: Icon(
                  Icons.vpn_key_outlined,
                  color: ${hasThemeManager ? 'context.theme.colors.activeButton' : 'Colors.blue'},
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
                          color: ${hasThemeManager ? 'context.theme.colors.inactiveButton' : 'Colors.grey[300]!'},
                          width: 1,
                        ),
                      ),
                      child: SelectableText(
                        fcmToken ?? ${hasLocalization ? 'context.strings.loading' : "'Loading...'"},
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: fcmToken == ${hasLocalization ? 'context.strings.notAvailable' : "'Not available'"} 
                            ? ${hasThemeManager ? 'context.theme.colors.iconRed' : 'Colors.red'} 
                            : ${hasThemeManager ? 'context.theme.colors.textPrimary' : 'Colors.black'},
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
  ''' : ''}

  ${hasLocalization ? '''
  Widget _buildLanguageSection(Locale currentLocale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.language_outlined,
              color: ${hasThemeManager ? 'context.theme.colors.activeButton' : 'Colors.blue'},
              size: 26,
            ),
            const SizedBox(width: 12),
            Text(
              context.strings.language,
              style: ${hasThemeManager ? 'context.theme.fonts.headerLarger.copyWith(fontSize: 20,)' : 'const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)'},
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: ${hasThemeManager ? 'context.theme.colors.surfaceCard' : 'Colors.grey[100]'},
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
                      style: ${hasThemeManager ? 'context.theme.fonts.headerSmall' : 'const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)'},
                    ),
                  ],
                ),
                value: locale.languageCode,
                groupValue: currentLocale.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    context.read<LocalizationProvider>().setLocale(Locale(value));
                  }
                },
                activeColor: ${hasThemeManager ? 'context.theme.colors.activeButton' : 'Colors.blue'},
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ${hasThemeManager ? 'context.theme.colors.surfaceCard' : 'Colors.white'},
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                    context.strings.language,
                    style: ${hasThemeManager ? 'context.theme.fonts.headerLarger.copyWith(fontSize: 20,)' : 'const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)'},
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
                              ? ${hasThemeManager ? 'context.theme.colors.activeButton.withOpacity(0.1)' : 'Colors.blue.withOpacity(0.1)'}
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
                        style: ${hasThemeManager ? 'context.theme.fonts.headerSmall' : 'const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)'},
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: ${hasThemeManager ? 'context.theme.colors.activeButton' : 'Colors.blue'},
                            )
                          : null,
                      onTap: () {
                        context.read<LocalizationProvider>().setLocale(Locale(locale.languageCode));
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }
  ''' : ''}
}
''';
}

/// Generate placeholder implementations for the remaining state management approaches
/// These could be implemented fully like the BLoC and Provider examples above
String _generateRiverpodImplementation(String projectName, bool hasThemeManager,
    bool hasLocalization, bool hasPushNotification) {
  // Implementation would be similar to Provider but using Riverpod's Consumer
  return "// TODO: Implement Riverpod-specific FlutterBunnyScreen";
}

String _generateGetXImplementation(String projectName, bool hasThemeManager,
    bool hasLocalization, bool hasPushNotification) {
  // Implementation using GetX's controller pattern
  return "// TODO: Implement GetX-specific FlutterBunnyScreen";
}

String _generateMobXImplementation(String projectName, bool hasThemeManager,
    bool hasLocalization, bool hasPushNotification) {
  // Implementation using MobX's Observer pattern
  return "// TODO: Implement MobX-specific FlutterBunnyScreen";
}

String _generateReduxImplementation(String projectName, bool hasThemeManager,
    bool hasLocalization, bool hasPushNotification) {
  // Implementation using Redux's StoreConnector pattern
  return "// TODO: Implement Redux-specific FlutterBunnyScreen";
}

String _generateDefaultImplementation(String projectName, bool hasThemeManager,
    bool hasLocalization, bool hasPushNotification) {
  // Simple implementation without state management
  return "// TODO: Implement default FlutterBunnyScreen without specific state management";
}
