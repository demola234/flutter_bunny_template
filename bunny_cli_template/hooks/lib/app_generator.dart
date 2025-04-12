import 'dart:io';

import 'package:mason/mason.dart';

/// Generates the App widget and required files
void generateAppWidget(
    HookContext context,
    String projectName,
    String architecture,
    String stateManagement,
    List<dynamic> features,
    List<dynamic> modules) {
  context.logger.info('Generating App widget for $projectName');

  // Create app directory if it doesn't exist
  final appDirectory = Directory('$projectName/lib/app');
  if (!appDirectory.existsSync()) {
    appDirectory.createSync(recursive: true);
    context.logger.info('Created directory: lib/app');
  }

  // Generate app.dart file
  _generateAppDartFile(
      context, projectName, architecture, stateManagement, features, modules);

  // Generate app_router.dart if needed based on architecture
  if (architecture == 'Feature-Driven' || modules.contains('Routing')) {
    _generateAppRouterFile(context, projectName, features, architecture);
  }

  // Generate app_module.dart for Feature-Driven architecture
  if (architecture == 'Feature-Driven') {
    _generateAppModuleFile(context, projectName, features);
  }

  // Generate app_widget.dart for Feature-Driven architecture
  if (architecture == 'Feature-Driven') {
    _generateAppWidgetFile(context, projectName, stateManagement, modules);
  }

  context.logger.success('App widget generated successfully!');
}

/// Generate the main app.dart file
/// Generate the main app.dart file
void _generateAppDartFile(
    HookContext context,
    String projectName,
    String architecture,
    String stateManagement,
    List<dynamic> features,
    List<dynamic> modules) {
  final filePath = '$projectName/lib/app/app.dart';

  // Only generate app.dart for non-Feature-Driven architectures
  if (architecture == 'Feature-Driven') {
    return;
  }

  // Determine imports based on modules and features
  final themeImport = modules.contains('Theme Manager')
      ? "import 'package:$projectName/core/design_system/theme_extension/app_theme_extension.dart';\n" +
          "import 'package:$projectName/core/design_system/theme_extension/theme_manager.dart';\n"
      : '';

  final localizationImport = modules.contains('Localization')
      ? "import 'package:$projectName/core/localization/localization.dart';\n" +
          "import 'package:flutter_localizations/flutter_localizations.dart';\n" +
          "import 'package:$projectName/core/localization/generated/app_localizations.dart';\n"
      : '';

  final pushNotificationImport = modules.contains('Push Notification')
      ? "import 'package:$projectName/core/notifications/notification_handler.dart';\n"
      : '';

  // Import specific state management libraries
  String stateManagementImport = '';
  switch (stateManagement) {
    case 'Bloc':
    case 'BLoC':
      stateManagementImport =
          "import 'package:flutter_bloc/flutter_bloc.dart';\n";
      // if (modules.contains('Theme Manager')) {
      //   stateManagementImport +=
      //       "import 'package:$projectName/core/design_system/theme_extension/theme_cubit.dart';\n";
      // }
      if (modules.contains('Localization')) {
        stateManagementImport +=
            "import 'package:$projectName/core/localization/bloc/locale_bloc.dart';\n";
      }
      break;
    case 'Provider':
      stateManagementImport = "import 'package:provider/provider.dart';\n";
      if (modules.contains('Theme Manager')) {
        stateManagementImport +=
            "import 'package:$projectName/core/design_system/theme_extension/theme_provider.dart';\n";
      }
      if (modules.contains('Localization')) {
        stateManagementImport +=
            "import 'package:$projectName/core/localization/providers/localization_provider.dart';\n";
      }
      break;
    case 'Riverpod':
      stateManagementImport =
          "import 'package:flutter_riverpod/flutter_riverpod.dart';\n";
      break;
    case 'GetX':
      stateManagementImport = "import 'package:get/get.dart';\n";
      break;
    case 'MobX':
      stateManagementImport =
          "import 'package:flutter_mobx/flutter_mobx.dart';\nimport 'package:mobx/mobx.dart';\n";
      break;
    case 'Redux':
      stateManagementImport =
          "import 'package:flutter_redux/flutter_redux.dart';\nimport 'package:redux/redux.dart';\n";
      break;
  }

  // Always import the FlutterBunnyScreen
  final bunnyScreenImport =
      "import 'package:$projectName/app/app_flutter_bunny.dart';\n";

  // Generate App class based on state management
  String appClass = '';
  String appInitInMain = ''; // For initialization needed in main.dart

  switch (stateManagement) {
    case 'Bloc':
    case 'BLoC':
      appClass = _generateBlocAppClass(projectName, modules);
      break;
    case 'Provider':
      appClass = _generateProviderAppClass(projectName, modules);
      break;
    case 'Riverpod':
      appClass = _generateRiverpodAppClass(projectName, modules);
      break;
    case 'GetX':
      appClass = _generateGetXAppClass(projectName, modules);
      appInitInMain = "// Initialize GetX controllers\n" +
          "${modules.contains('Theme Manager') ? "Get.put(ThemeController());\n" : ""}" +
          "${modules.contains('Localization') ? "Get.put(LocalizationController());\n" : ""}";
      break;
    case 'MobX':
      appClass = _generateMobXAppClass(projectName, modules);
      break;
    case 'Redux':
      appClass = _generateReduxAppClass(projectName, modules);
      break;
    default:
      appClass = _generateDefaultAppClass(projectName, modules);
      break;
  }

  final content = '''
import 'package:flutter/material.dart';
$stateManagementImport
$themeImport
$localizationImport
$pushNotificationImport
$bunnyScreenImport

$appClass

$appInitInMain
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generate BLoC implementation of App
String _generateBlocAppClass(String projectName, List<dynamic> modules) {
  final hasTheme = modules.contains('Theme Manager');
  final hasLocalization = modules.contains('Localization');
  final hasPushNotification = modules.contains('Push Notification');

  final blocProviders = [
    hasTheme ? 'BlocProvider(create: (_) => ThemeCubit()),' : '',
    hasLocalization ? 'BlocProvider(create: (_) => LocaleBloc()),' : '',
  ].where((provider) => provider.isNotEmpty).join('\n        ');



  final themeConfig = hasTheme
      ? '''
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: context.watch<ThemeCubit>().state.themeMode.toThemeMode(),'''
      : '''
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),''';

  final localizationConfig = hasLocalization
      ? '''
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: context.watch<LocaleBloc>().state.locale,'''
      : '';

  return '''
/// Main App widget that configures the application using BLoC pattern.
class App extends StatelessWidget {
  /// Creates a new App instance.
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        $blocProviders
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: '$projectName',
            debugShowCheckedModeBanner: false,
$themeConfig
$localizationConfig
            home: const FlutterBunnyScreen(),
          );
        },
      ),
    );
  }
}
''';
}

/// Generate Provider implementation of App
String _generateProviderAppClass(String projectName, List<dynamic> modules) {
  final hasTheme = modules.contains('Theme Manager');
  final hasLocalization = modules.contains('Localization');
  final hasPushNotification = modules.contains('Push Notification');

  final providers = [
    hasTheme ? 'ChangeNotifierProvider(create: (_) => ThemeProvider()),' : '',
    hasLocalization
        ? 'ChangeNotifierProvider(create: (_) => LocalizationProvider()),'
        : '',
  ].where((provider) => provider.isNotEmpty).join('\n        ');

  final themeConfig = hasTheme
      ? '''
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: Provider.of<ThemeProvider>(context).themeMode,'''
      : '''
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),''';

  final localizationConfig = hasLocalization
      ? '''
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: Provider.of<LocalizationProvider>(context).locale,'''
      : '';

  return '''
/// Main App widget that configures the application using Provider pattern.
class App extends StatelessWidget {
  /// Creates a new App instance.
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        $providers
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: '$projectName',
            debugShowCheckedModeBanner: false,
$themeConfig
$localizationConfig
            home: const FlutterBunnyScreen(),
          );
        },
      ),
    );
  }
}
''';
}

/// Generate Riverpod implementation of App
String _generateRiverpodAppClass(String projectName, List<dynamic> modules) {
  final hasTheme = modules.contains('Theme Manager');
  final hasLocalization = modules.contains('Localization');
  final hasPushNotification = modules.contains('Push Notification');

  final themeConfig = hasTheme
      ? '''
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(flutterThemeModeProvider),'''
      : '''
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),''';

  final localizationConfig = hasLocalization
      ? '''
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: ref.watch(localeProvider),'''
      : '';

  return '''
/// Main App widget that configures the application using Riverpod.
class App extends StatelessWidget {
  /// Creates a new App instance.
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          return MaterialApp(
            title: '$projectName',
            debugShowCheckedModeBanner: false,
$themeConfig
$localizationConfig
            home: const FlutterBunnyScreen(),
          );
        },
      ),
    );
  }
}
''';
}

/// Generate GetX implementation of App
String _generateGetXAppClass(String projectName, List<dynamic> modules) {
  final hasTheme = modules.contains('Theme Manager');
  final hasLocalization = modules.contains('Localization');
  final hasPushNotification = modules.contains('Push Notification');

  final themeConfig = hasTheme
      ? '''
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: Get.find<ThemeController>().themeMode,'''
      : '''
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),''';

  final localizationConfig = hasLocalization
      ? '''
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: Get.find<LocalizationController>().locale,
      translations: AppTranslations(),'''
      : '';

  return '''
/// Main App widget that configures the application using GetX.
class App extends StatelessWidget {
  /// Creates a new App instance.
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '$projectName',
      debugShowCheckedModeBanner: false,
$themeConfig
$localizationConfig
      home: const FlutterBunnyScreen(),
    );
  }
}
''';
}

/// Generate MobX implementation of App
String _generateMobXAppClass(String projectName, List<dynamic> modules) {
  final hasTheme = modules.contains('Theme Manager');
  final hasLocalization = modules.contains('Localization');
  final hasPushNotification = modules.contains('Push Notification');

  final themeConfig = hasTheme
      ? '''
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeStore.flutterThemeMode,'''
      : '''
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),''';

  final localizationConfig = hasLocalization
      ? '''
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: localizationStore.locale,'''
      : '';

  return '''
/// Main App widget that configures the application using MobX.
class App extends StatelessWidget {
  /// Creates a new App instance.
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return MaterialApp(
          title: '$projectName',
          debugShowCheckedModeBanner: false,
$themeConfig
$localizationConfig
          home: const FlutterBunnyScreen(),
        );
      },
    );
  }
}
''';
}

/// Generate Redux implementation of App
String _generateReduxAppClass(String projectName, List<dynamic> modules) {
  final hasTheme = modules.contains('Theme Manager');
  final hasLocalization = modules.contains('Localization');
  final hasPushNotification = modules.contains('Push Notification');

  String themeBuilder = hasTheme
      ? '''StoreConnector<AppState, ThemeMode>(
        converter: (store) => store.state.themeState.flutterThemeMode,
        builder: (context, themeMode) {'''
      : '';

  String localeBuilder = hasLocalization
      ? '''StoreConnector<AppState, Locale>(
          converter: (store) => store.state.localeState.locale,
          builder: (context, locale) {'''
      : '';

  String endBuilders = '';
  if (hasTheme) endBuilders += '        })';
  if (hasLocalization) endBuilders += '          })';

  final themeConfig = hasTheme
      ? '''
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,'''
      : '''
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),''';

  final localizationConfig = hasLocalization
      ? '''
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            locale: locale,'''
      : '';

  return '''
/// Main App widget that configures the application using Redux.
class App extends StatelessWidget {
  final Store<AppState> store;

  /// Creates a new App instance with the Redux store.
  const App({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: ${themeBuilder}
        ${localeBuilder}
          return MaterialApp(
            title: '$projectName',
            debugShowCheckedModeBanner: false,
$themeConfig
$localizationConfig
            home: const FlutterBunnyScreen(),
          );
        ${endBuilders}
      ),
    );
  }
}
''';
}

/// Generate default implementation of App with internal state management
String _generateDefaultAppClass(String projectName, List<dynamic> modules) {
  final hasTheme = modules.contains('Theme Manager');
  final hasLocalization = modules.contains('Localization');
  final hasPushNotification = modules.contains('Push Notification');

  String themeInit = hasTheme
      ? '''
  ThemeMode _themeMode = ThemeMode.system;
  
  @override
  void initState() {
    super.initState();
    _initializeTheme();
    ${hasLocalization ? '_initializeLocale();' : ''}
  }
  
  Future<void> _initializeTheme() async {
    await themeManager.initialize();
    setState(() {
      _themeMode = themeManager.themeMode;
    });
    
    // Listen for theme changes
    themeManager.addListener(_onThemeChanged);
  }
  
  void _onThemeChanged(ThemeModeEnum theme) {
    setState(() {
      _themeMode = theme.toThemeMode();
    });
  }
  
  @override
  void dispose() {
    themeManager.removeListener(_onThemeChanged);
    super.dispose();
  }'''
      : '';

  String localeInit = hasLocalization
      ? '''
  Locale _locale = const Locale('en');

  ${!hasTheme ? '@override\n  void initState() {\n    super.initState();\n    _initializeLocale();\n  }\n' : ''}
  
  Future<void> _initializeLocale() async {
    // Implementation depends on how locale is stored
    if (localeManager != null) {
      setState(() {
        _locale = localeManager.locale;
      });
      
      localeManager.addListener((locale) {
        setState(() {
          _locale = locale;
        });
      });
    }
  }'''
      : '';

  final themeConfig = hasTheme
      ? '''
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,'''
      : '''
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),''';

  final localizationConfig = hasLocalization
      ? '''
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: _locale,'''
      : '';

  return '''
/// Main App widget that configures the application with internal state management.
class App extends StatefulWidget {
  /// Creates a new App instance.
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
$themeInit
$localeInit

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '$projectName',
      debugShowCheckedModeBanner: false,
$themeConfig
$localizationConfig
      home: const FlutterBunnyScreen(),
    );
  }
}
''';
}

/// Generate app_router.dart file for routing
void _generateAppRouterFile(HookContext context, String projectName,
    List<dynamic> features, String architecture) {
  final filePath = '$projectName/lib/app/app_router.dart';

  // this import changes based on the architecture you choose

  // Generate imports for feature pages
  final importStatements = features.map((feature) {
    final featureName = feature.toString().toLowerCase().replaceAll(' ', '_');
    return "import 'package:$projectName/features/$featureName/presentation/pages/${featureName}_page.dart';";
  }).join('\n');

  // Generate route cases for features
  final routeCases = features.map((feature) {
    final featureName = feature.toString().toLowerCase().replaceAll(' ', '_');
    final className = toClassName(featureName);
    return '''
      case '/$featureName':
        return MaterialPageRoute(builder: (_) => const ${className}Page());''';
  }).join('\n');

  final content = '''
import 'package:flutter/material.dart';
$importStatements

/// Handles application routing
class AppRouter {
  /// Generates routes based on route name
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        // Determine the home route based on features
        ${features.contains('Authentication') ? "return MaterialPageRoute(builder: (_) => const AuthenticationPage());" : features.contains('Dashboard') ? "return MaterialPageRoute(builder: (_) => const DashboardPage());" : features.contains('Home') ? "return MaterialPageRoute(builder: (_) => const HomePage());" : "return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Welcome'))));"}
$routeCases
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for \${settings.name}'),
            ),
          ),
        );
    }
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generate app_module.dart file for Feature-Driven architecture
void _generateAppModuleFile(
    HookContext context, String projectName, List<dynamic> features) {
  final filePath = '$projectName/lib/app/app_module.dart';

  // Generate imports for feature modules
  final importStatements = features.map((feature) {
    final featureName = feature.toString().toLowerCase().replaceAll(' ', '_');
    return "import 'package:$projectName/features/$featureName/${featureName}_module.dart';";
  }).join('\n');

  // Generate module routes for features
  final moduleRoutes = features.map((feature) {
    final featureName = feature.toString().toLowerCase().replaceAll(' ', '_');
    final className = toClassName(featureName);
    return '''
        ModuleRoute('/$featureName', module: ${className}Module()),''';
  }).join('\n');

  final content = '''
import 'package:flutter_modular/flutter_modular.dart';
$importStatements

/// Main application module for Feature-Driven architecture
class AppModule extends Module {
  @override
  List<Bind> get binds => [
    // Register your global dependencies here
  ];

  @override
  List<ModularRoute> get routes => [
    // Default route
    ${features.contains('Authentication') ? "ModuleRoute('/', module: AuthenticationModule())," : features.contains('Dashboard') ? "ModuleRoute('/', module: DashboardModule())," : features.contains('Home') ? "ModuleRoute('/', module: HomeModule())," : "ChildRoute('/', child: (_, __) => const Scaffold(body: Center(child: Text('Welcome')))),"}
    
    // Feature module routes
$moduleRoutes
  ];
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generate app_widget.dart file for Feature-Driven architecture
void _generateAppWidgetFile(HookContext context, String projectName,
    String stateManagement, List<dynamic> modules) {
  final filePath = '$projectName/lib/app/app_widget.dart';

  // Determine imports based on modules
  final themeImport = modules.contains('Theme Manager')
      ? "import 'package:$projectName/core/design_system/theme_extension/app_theme_extension.dart';" +
          "\nimport 'package:$projectName/core/design_system/theme_extension/theme_manager.dart';"
      : '';

  final localizationImport = modules.contains('Localization')
      ? "import 'package:$projectName/core/localization/generated/app_localizations.dart';" +
          "\nimport 'package:$projectName/core/localization/localization.dart';"
      : '';

  // Add state management imports
  String stateManagementImport = '';
  if (stateManagement == 'Provider') {
    stateManagementImport = "import 'package:provider/provider.dart';";
  } else if (stateManagement == 'Bloc' || stateManagement == 'BLoC') {
    stateManagementImport = "import 'package:flutter_bloc/flutter_bloc.dart';";
  } else if (stateManagement == 'Riverpod') {
    stateManagementImport =
        "import 'package:flutter_riverpod/flutter_riverpod.dart';";
  } else if (stateManagement == 'GetX') {
    stateManagementImport = "import 'package:get/get.dart';";
  } else if (stateManagement == 'MobX') {
    stateManagementImport = "import 'package:flutter_mobx/flutter_mobx.dart';";
  } else if (stateManagement == 'Redux') {
    stateManagementImport =
        "import 'package:flutter_redux/flutter_redux.dart';\nimport 'package:redux/redux.dart';";
  }

  // Get content based on state management
  String content = '';

  // Different implementations based on state management
  if (stateManagement == 'Provider') {
    content = '''
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
$stateManagementImport
$themeImport
$localizationImport

/// Main app widget for Feature-Driven architecture that works with Modular and Provider
class AppWidget extends StatelessWidget {
  /// Creates a new AppWidget instance
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ${modules.contains('Theme Manager') ? 'ChangeNotifierProvider(create: (_) => ThemeProvider()),' : ''}
        ${modules.contains('Localization') ? 'ChangeNotifierProvider(create: (_) => LocalizationProvider()),' : ''}
        // Add other providers here
      ],
      child: Consumer<${modules.contains('Theme Manager') ? 'ThemeProvider' : 'ChangeNotifier'}>(
        builder: (context, themeProvider, _) {
          ${modules.contains('Localization') ? 'final localeProvider = Provider.of<LocalizationProvider>(context);' : ''}
          return MaterialApp.router(
            title: '$projectName',
            debugShowCheckedModeBanner: false,
            ${modules.contains('Theme Manager') ? '// Theme configuration\ntheme: AppTheme.light,\ndarkTheme: AppTheme.dark,\nthemeMode: themeProvider.themeMode,' : '// Default theme configuration\ntheme: ThemeData.light(useMaterial3: true),\ndarkTheme: ThemeData.dark(useMaterial3: true),'}
            ${modules.contains('Localization') ? '// Localization configuration\nsupportedLocales: Strings.supportedLocales,\nlocalizationsDelegates: Strings.localizationsDelegates,\nlocale: localeProvider.locale,' : '// Default localization configuration\nsupportedLocales: const [Locale(\'en\', \'\')],\nlocalizationsDelegates: const [\n  GlobalMaterialLocalizations.delegate,\n  GlobalWidgetsLocalizations.delegate,\n  GlobalCupertinoLocalizations.delegate,\n],'}
            // Routing handled by flutter_modular
            routeInformationParser: Modular.routeInformationParser,
            routerDelegate: Modular.routerDelegate,
          );
        },
      ),
    );
  }
}
''';
  } else if (stateManagement == 'Bloc' || stateManagement == 'BLoC') {
    content = '''
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
$stateManagementImport
$themeImport
$localizationImport

/// Main app widget for Feature-Driven architecture that works with Modular and BLoC
class AppWidget extends StatelessWidget {
  /// Creates a new AppWidget instance
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        ${modules.contains('Theme Manager') ? 'BlocProvider(create: (_) => ThemeCubit()),' : ''}
        ${modules.contains('Localization') ? 'BlocProvider(create: (_) => LocalizationBloc()),' : ''}
        // Add other BLoCs here
      ],
      child: BlocBuilder<${modules.contains('Theme Manager') ? 'ThemeCubit, ThemeState' : 'Cubit, Object'}>(
        builder: (context, themeState) {
          ${modules.contains('Localization') ? 'return BlocBuilder<LocalizationBloc, LocalizationState>(\n            builder: (context, localizationState) {' : ''}
          return MaterialApp.router(
            title: '$projectName',
            debugShowCheckedModeBanner: false,
            ${modules.contains('Theme Manager') ? '// Theme configuration\ntheme: AppTheme.light,\ndarkTheme: AppTheme.dark,\nthemeMode: themeState.themeMode.toThemeMode(),' : '// Default theme configuration\ntheme: ThemeData.light(useMaterial3: true),\ndarkTheme: ThemeData.dark(useMaterial3: true),'}
            ${modules.contains('Localization') ? '// Localization configuration\nsupportedLocales: Strings.supportedLocales,\nlocalizationsDelegates: Strings.localizationsDelegates,\nlocale: localizationState.locale,' : '// Default localization configuration\nsupportedLocales: const [Locale(\'en\', \'\')],\nlocalizationsDelegates: const [\n  GlobalMaterialLocalizations.delegate,\n  GlobalWidgetsLocalizations.delegate,\n  GlobalCupertinoLocalizations.delegate,\n],'}
            // Routing handled by flutter_modular
            routeInformationParser: Modular.routeInformationParser,
            routerDelegate: Modular.routerDelegate,
          );
          ${modules.contains('Localization') ? '});' : ''}
        },
      ),
    );
  }
}
''';
  } else if (stateManagement == 'Riverpod') {
    content = '''
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
$stateManagementImport
$themeImport
$localizationImport

/// Main app widget for Feature-Driven architecture that works with Modular and Riverpod
class AppWidget extends StatelessWidget {
  /// Creates a new AppWidget instance
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          ${modules.contains('Theme Manager') ? 'final themeMode = ref.watch(flutterThemeModeProvider);' : ''}
          ${modules.contains('Localization') ? 'final locale = ref.watch(localeProvider);' : ''}
          return MaterialApp.router(
            title: '$projectName',
            debugShowCheckedModeBanner: false,
            ${modules.contains('Theme Manager') ? '// Theme configuration\ntheme: AppTheme.light,\ndarkTheme: AppTheme.dark,\nthemeMode: themeMode,' : '// Default theme configuration\ntheme: ThemeData.light(useMaterial3: true),\ndarkTheme: ThemeData.dark(useMaterial3: true),'}
            ${modules.contains('Localization') ? '// Localization configuration\nsupportedLocales: Strings.supportedLocales,\nlocalizationsDelegates: Strings.localizationsDelegates,\nlocale: locale,' : '// Default localization configuration\nsupportedLocales: const [Locale(\'en\', \'\')],\nlocalizationsDelegates: const [\n  GlobalMaterialLocalizations.delegate,\n  GlobalWidgetsLocalizations.delegate,\n  GlobalCupertinoLocalizations.delegate,\n],'}
// Routing handled by flutter_modular
            routeInformationParser: Modular.routeInformationParser,
            routerDelegate: Modular.routerDelegate,
          );
        },
      ),
    );
  }
}
''';
  } else if (stateManagement == 'GetX') {
    content = '''
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


$stateManagementImport
$themeImport
$localizationImport

/// Main app widget for Feature-Driven architecture that works with Modular and GetX
class AppWidget extends StatelessWidget {
  /// Creates a new AppWidget instance
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize GetX controllers if they haven't been initialized yet
    ${modules.contains('Theme Manager') ? 'if (!Get.isRegistered<ThemeController>()) {\n      Get.put(ThemeController());\n    }' : ''}
    ${modules.contains('Localization') ? 'if (!Get.isRegistered<LocalizationController>()) {\n      Get.put(LocalizationController());\n    }' : ''}
    
    return GetMaterialApp.router(
      title: '$projectName',
      debugShowCheckedModeBanner: false,
      ${modules.contains('Theme Manager') ? '// Theme configuration\ntheme: AppTheme.light,\ndarkTheme: AppTheme.dark,\nthemeMode: Get.find<ThemeController>().themeMode,' : '// Default theme configuration\ntheme: ThemeData.light(useMaterial3: true),\ndarkTheme: ThemeData.dark(useMaterial3: true),'}
      ${modules.contains('Localization') ? '// Localization configuration\nsupportedLocales: Strings.supportedLocales,\nlocalizationsDelegates: Strings.localizationsDelegates,\nlocale: Get.find<LocalizationController>().locale,' : '// Default localization configuration\nsupportedLocales: const [Locale(\'en\', \'\')],\nlocalizationsDelegates: const [\n  GlobalMaterialLocalizations.delegate,\n  GlobalWidgetsLocalizations.delegate,\n  GlobalCupertinoLocalizations.delegate,\n],'}
      // Routing delegated to Modular
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    );
  }
}
''';
  } else if (stateManagement == 'MobX') {
    content = '''
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
$stateManagementImport
$themeImport
$localizationImport

/// Main app widget for Feature-Driven architecture that works with Modular and MobX
class AppWidget extends StatelessWidget {
  /// Creates a new AppWidget instance
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return MaterialApp.router(
          title: '$projectName',
          debugShowCheckedModeBanner: false,
          ${modules.contains('Theme Manager') ? '// Theme configuration\ntheme: AppTheme.light,\ndarkTheme: AppTheme.dark,\nthemeMode: themeStore.flutterThemeMode,' : '// Default theme configuration\ntheme: ThemeData.light(useMaterial3: true),\ndarkTheme: ThemeData.dark(useMaterial3: true),'}
          ${modules.contains('Localization') ? '// Localization configuration\nsupportedLocales: Strings.supportedLocales,\nlocalizationsDelegates: Strings.localizationsDelegates,\nlocale: localizationStore.currentLocale,' : '// Default localization configuration\nsupportedLocales: const [Locale(\'en\', \'\')],\nlocalizationsDelegates: const [\n  GlobalMaterialLocalizations.delegate,\n  GlobalWidgetsLocalizations.delegate,\n  GlobalCupertinoLocalizations.delegate,\n],'}
          // Routing handled by flutter_modular
          routeInformationParser: Modular.routeInformationParser,
          routerDelegate: Modular.routerDelegate,
        );
      },
    );
  }
}
''';
  } else if (stateManagement == 'Redux') {
    content = '''
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
$stateManagementImport
$themeImport
$localizationImport

/// Main app widget for Feature-Driven architecture that works with Modular and Redux
class AppWidget extends StatelessWidget {
  /// Creates a new AppWidget instance
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store, // Global store instance
      child: StoreConnector<AppState, ThemeState>(
        converter: (store) => store.state.themeState,
        builder: (context, themeState) {
          ${modules.contains('Localization') ? 'return StoreConnector<AppState, LocalizationState>(\n            converter: (store) => store.state.localizationState,\n            builder: (context, localizationState) {' : ''}
          return MaterialApp.router(
            title: '$projectName',
            debugShowCheckedModeBanner: false,
            ${modules.contains('Theme Manager') ? '// Theme configuration\ntheme: AppTheme.light,\ndarkTheme: AppTheme.dark,\nthemeMode: themeState.flutterThemeMode,' : '// Default theme configuration\ntheme: ThemeData.light(useMaterial3: true),\ndarkTheme: ThemeData.dark(useMaterial3: true),'}
            ${modules.contains('Localization') ? '// Localization configuration\nsupportedLocales: Strings.supportedLocales,\nlocalizationsDelegates: Strings.localizationsDelegates,\nlocale: localizationState.currentLocale,' : '// Default localization configuration\nsupportedLocales: const [Locale(\'en\', \'\')],\nlocalizationsDelegates: const [\n  GlobalMaterialLocalizations.delegate,\n  GlobalWidgetsLocalizations.delegate,\n  GlobalCupertinoLocalizations.delegate,\n],'}
            // Routing handled by flutter_modular
            routeInformationParser: Modular.routeInformationParser,
            routerDelegate: Modular.routerDelegate,
          );
          ${modules.contains('Localization') ? '});' : ''}
        },
      ),
    );
  }
}
''';
  } else {
    // Default implementation for internal state management
    content = '''
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
$themeImport
$localizationImport

/// Main app widget for Feature-Driven architecture that works with Modular
class AppWidget extends StatefulWidget {
  /// Creates a new AppWidget instance
  const AppWidget({Key? key}) : super(key: key);

  @override
  _AppWidgetState createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  ${modules.contains('Theme Manager') ? 'ThemeMode _themeMode = ThemeMode.system;' : ''}
  ${modules.contains('Localization') ? 'Locale _locale = const Locale(\'en\');' : ''}

  @override
  void initState() {
    super.initState();
    ${modules.contains('Theme Manager') ? '// Initialize theme\n    _initializeTheme();' : ''}
    ${modules.contains('Localization') ? '// Initialize locale\n    _initializeLocale();' : ''}
  }

  ${modules.contains('Theme Manager') ? 'Future<void> _initializeTheme() async {\n    await themeManager.initialize();\n    setState(() {\n      _themeMode = themeManager.themeMode;\n    });\n    \n    // Listen for theme changes\n    themeManager.addListener(_onThemeChanged);\n  }\n\n  void _onThemeChanged(ThemeModeEnum theme) {\n    setState(() {\n      _themeMode = theme.toThemeMode();\n    });\n  }' : ''}

  ${modules.contains('Localization') ? 'Future<void> _initializeLocale() async {\n    // Implementation would depend on how you\'re storing locale preferences\n    // This is just a placeholder\n    setState(() {\n      _locale = const Locale(\'en\');\n    });\n  }' : ''}

  @override
  void dispose() {
    ${modules.contains('Theme Manager') ? '// Remove theme listener\n    themeManager.removeListener(_onThemeChanged);' : ''}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '$projectName',
      debugShowCheckedModeBanner: false,
      ${modules.contains('Theme Manager') ? '// Theme configuration\ntheme: AppTheme.light,\ndarkTheme: AppTheme.dark,\nthemeMode: _themeMode,' : '// Default theme configuration\ntheme: ThemeData.light(useMaterial3: true),\ndarkTheme: ThemeData.dark(useMaterial3: true),'}
      ${modules.contains('Localization') ? '// Localization configuration\nsupportedLocales: Strings.supportedLocales,\nlocalizationsDelegates: Strings.localizationsDelegates,\nlocale: _locale,' : '// Default localization configuration\nsupportedLocales: const [Locale(\'en\', \'\')],\nlocalizationsDelegates: const [\n  GlobalMaterialLocalizations.delegate,\n  GlobalWidgetsLocalizations.delegate,\n  GlobalCupertinoLocalizations.delegate,\n],'}
      // Routing handled by flutter_modular
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    );
  }
}
''';
  }

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Helper function to convert string to class name (PascalCase)
String toClassName(String name) {
  final parts = name.split('_');
  return parts
      .map((part) =>
          part.isNotEmpty ? part[0].toUpperCase() + part.substring(1) : '')
      .join('');
}
