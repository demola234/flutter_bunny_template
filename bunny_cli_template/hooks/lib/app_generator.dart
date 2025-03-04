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
    _generateAppRouterFile(context, projectName, features);
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
          "import 'package:$projectName/core/design_system/theme_extension/theme_manager.dart';"
      : '';

  final localizationImport = modules.contains('Localization')
      ? "import 'package:$projectName/core/localization/generated/strings.dart';" +
          (modules.contains('Localization') && stateManagement != 'default'
              ? "\nimport 'package:$projectName/core/localization/localization.dart';"
              : '')
      : '';

  // Determine home page based on features
  String homePageImport = '';
  String homePage = 'const Scaffold(body: Center(child: Text(\'Welcome\')))';

  if (features.contains('Authentication')) {
    homePageImport =
        "import 'package:$projectName/features/authentication/presentation/pages/authentication_page.dart';";
    homePage = 'const AuthenticationPage()';
  } else if (features.contains('Dashboard')) {
    homePageImport =
        "import 'package:$projectName/features/dashboard/presentation/pages/dashboard_page.dart';";
    homePage = 'const DashboardPage()';
  } else if (features.contains('Home')) {
    homePageImport =
        "import 'package:$projectName/features/home/presentation/pages/home_page.dart';";
    homePage = 'const HomePage()';
  } else if (features.isNotEmpty) {
    // Get the first feature if no priority features are present
    final firstFeature =
        features[0].toString().toLowerCase().replaceAll(' ', '_');
    homePageImport =
        "import 'package:$projectName/features/$firstFeature/presentation/pages/${firstFeature}_page.dart';";
    homePage = 'const ${toClassName(firstFeature)}Page()';
  }

  // Handle routing if needed
  final routerImport =
      modules.contains('Routing') ? "import 'app_router.dart';" : '';

  // Generate App class based on state management
  String appClass = '';

  // First determine if we need stateful or stateless widget
  // For Provider, BLoC, Redux, MobX, and Riverpod, we use a stateless widget since state is managed externally
  // For default or other state management solutions, we need to use a stateful widget to manage theme and locale
  bool isStatefulApp = stateManagement == 'default' ||
      (!['Provider', 'Bloc', 'BLoC', 'Redux', 'MobX', 'Riverpod', 'GetX']
          .contains(stateManagement));

  if (isStatefulApp) {
    // Stateful App for internal state management
    appClass = _generateStatefulAppClass(projectName, stateManagement, modules);
  } else {
    // Stateless App for external state management
    appClass = _generateStatelessAppClass(
        projectName, stateManagement, modules, homePage);
  }

  final content = '''
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
$themeImport
$localizationImport
$homePageImport
$routerImport

$appClass
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generate a stateless App class for external state management
String _generateStatelessAppClass(String projectName, String stateManagement,
    List<dynamic> modules, String homePage) {
  // Theme code based on state management
  String themeCode = '';
  if (modules.contains('Theme Manager')) {
    switch (stateManagement) {
      case 'Provider':
        themeCode = '''
      // Theme configured from Provider
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode ?? ThemeMode.system,''';
        break;
      case 'Bloc':
      case 'BLoC':
        themeCode = '''
      // Theme configured from BLoC
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode ?? ThemeMode.system,''';
        break;
      case 'Riverpod':
        themeCode = '''
      // Theme configured from Riverpod
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode ?? ThemeMode.system,''';
        break;
      case 'GetX':
        themeCode = '''
      // Theme is configured in GetMaterialApp through GetX controller''';
        break;
      case 'MobX':
        themeCode = '''
      // Theme configured from MobX store
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode ?? ThemeMode.system,''';
        break;
      case 'Redux':
        themeCode = '''
      // Theme configured from Redux store
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode ?? ThemeMode.system,''';
        break;
      default:
        themeCode = '''
      // Default theme configuration
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode ?? ThemeMode.system,''';
    }
  } else {
    // No Theme Manager module
    themeCode = '''
      // Default theme configuration
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeMode ?? ThemeMode.system,''';
  }

  // Localization code based on state management
  String localizationCode = '';
  if (modules.contains('Localization')) {
    switch (stateManagement) {
      case 'Provider':
      case 'Bloc':
      case 'BLoC':
      case 'Riverpod':
      case 'MobX':
      case 'Redux':
        localizationCode = '''
      // Localization configuration
      supportedLocales: Strings.supportedLocales,
      localizationsDelegates: Strings.localizationsDelegates,
      locale: locale,''';
        break;
      case 'GetX':
        // GetX handles localization differently through GetMaterialApp
        localizationCode = '''
      // Localization is configured in GetMaterialApp''';
        break;
      default:
        localizationCode = '''
      // Localization configuration
      supportedLocales: Strings.supportedLocales,
      localizationsDelegates: Strings.localizationsDelegates,''';
    }
  } else {
    // No Localization module
    localizationCode = '''
      // Default localization configuration
      supportedLocales: const [Locale('en', '')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],''';
  }

  String constructor = '';
  if (stateManagement == 'GetX') {
    // GetX doesn't need themeMode or locale in constructor
    constructor = '''
  /// Creates a new App instance.
  const App({Key? key}) : super(key: key);''';
  } else {
    // Other state management solutions need themeMode and potentially locale
    String localeParam =
        modules.contains('Localization') ? 'this.locale, ' : '';
    constructor = '''
  /// Creates a new App instance.
  const App({
    Key? key, 
    this.themeMode${modules.contains('Localization') ? ', this.locale' : ''}
  }) : super(key: key);''';
  }

  // For GetX, we need a different approach as it requires GetMaterialApp
  if (stateManagement == 'GetX') {
    return '''
/// Main App widget using GetX architecture.
///
/// This is the root widget of the application that sets up the GetMaterialApp
/// with appropriate theme, localization, and routing configurations.
class App extends StatelessWidget {
  $constructor

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '$projectName',
      debugShowCheckedModeBanner: false,
      ${modules.contains('Theme Manager') ? '// Theme is managed by GetX controller\ntheme: AppTheme.light,\ndarkTheme: AppTheme.dark,\nthemeMode: Get.find<ThemeController>().themeMode,' : ''}
      ${modules.contains('Localization') ? '// Localization is managed by GetX\nsupportedLocales: Strings.supportedLocales,\nlocalizationsDelegates: Strings.localizationsDelegates,\ntranslations: AppTranslations(),' : ''}
      ${modules.contains('Routing') ? '// Routing configuration\ninitialRoute: \'/\',\ngetPages: AppPages.routes,' : 'home: $homePage,'}
    );
  }
}''';
  }

  // For other state management approaches
  return '''
/// Main App widget that configures the application.
///
/// This is the root widget of the application that sets up the MaterialApp
/// with appropriate theme, localization, and routing configurations.
class App extends StatelessWidget {
  /// The theme mode to use for the app.
  final ThemeMode? themeMode;
  ${modules.contains('Localization') ? '\n  /// The locale to use for the app.\n  final Locale? locale;' : ''}

  $constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '$projectName',
      debugShowCheckedModeBanner: false,
$themeCode
$localizationCode
      ${modules.contains('Routing') ? '// Routing configuration\ninitialRoute: \'/\',\nonGenerateRoute: AppRouter.onGenerateRoute,' : '// Set the home page based on selected features\nhome: $homePage,'}
    );
  }
}''';
}

/// Generate a stateful App class for internal state management
String _generateStatefulAppClass(
    String projectName, String stateManagement, List<dynamic> modules) {
  // Get theme initialization code for stateful app
  String themeInitCode = modules.contains('Theme Manager')
      ? '''
  ThemeMode _themeMode = ThemeMode.system;
  
  @override
  void initState() {
    super.initState();
    // Initialize theme from theme manager
    _initializeTheme();
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
    // Remove theme listener
    themeManager.removeListener(_onThemeChanged);
    super.dispose();
  }'''
      : '''
  ThemeMode _themeMode = ThemeMode.system;
  
  @override
  void initState() {
    super.initState();
    // No theme manager module, using system default
  }''';

  // Get localization initialization code for stateful app
  String localizationInitCode = '';
  if (modules.contains('Localization')) {
    localizationInitCode = '''
  Locale _locale = const Locale('en');
  
  @override
  void initState() {
    super.initState();
    // Initialize locale from saved preference
    _initializeLocale();
  }
  
  Future<void> _initializeLocale() async {
    // Implementation would depend on how you're storing locale preferences
    // Example implementation with shared preferences:
    // final prefs = await SharedPreferences.getInstance();
    // final languageCode = prefs.getString('language_code') ?? 'en';
    // setState(() {
    //   _locale = Locale(languageCode);
    // });
  }
  
  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    // Save preference
    // final prefs = await SharedPreferences.getInstance();
    // prefs.setString('language_code', locale.languageCode);
  }''';
  }

  // Combine initState methods if both theme and localization are present
  if (modules.contains('Theme Manager') && modules.contains('Localization')) {
    themeInitCode = themeInitCode.replaceFirst(
        '@override\n  void initState() {\n    super.initState();\n    // Initialize theme from theme manager\n    _initializeTheme();\n  }',
        '@override\n  void initState() {\n    super.initState();\n    // Initialize theme and locale\n    _initializeTheme();\n    _initializeLocale();\n  }');

    // Remove duplicate initState from localizationInitCode
    localizationInitCode = localizationInitCode.replaceFirst(
        '@override\n  void initState() {\n    super.initState();\n    // Initialize locale from saved preference\n    _initializeLocale();\n  }',
        '');
  }

  // Build class with appropriate state variables
  return '''
/// Main App widget with internal state management.
///
/// This widget handles theme and localization state internally
/// since no external state management solution is used.
class App extends StatefulWidget {
  /// Creates a new App instance.
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
$themeInitCode
$localizationInitCode

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '$projectName',
      debugShowCheckedModeBanner: false,
      ${modules.contains('Theme Manager') ? '// Theme configuration\ntheme: AppTheme.light,\ndarkTheme: AppTheme.dark,\nthemeMode: _themeMode,' : '// Default theme configuration\ntheme: ThemeData.light(useMaterial3: true),\ndarkTheme: ThemeData.dark(useMaterial3: true),\nthemeMode: _themeMode,'}
      ${modules.contains('Localization') ? '// Localization configuration\nsupportedLocales: Strings.supportedLocales,\nlocalizationsDelegates: Strings.localizationsDelegates,\nlocale: _locale,' : '// Default localization configuration\nsupportedLocales: const [Locale(\'en\', \'\')],\nlocalizationsDelegates: const [\n  GlobalMaterialLocalizations.delegate,\n  GlobalWidgetsLocalizations.delegate,\n  GlobalCupertinoLocalizations.delegate,\n],'}
      ${modules.contains('Routing') ? '// Routing configuration\ninitialRoute: \'/\',\nonGenerateRoute: AppRouter.onGenerateRoute,' : '// Home page\nhome: _buildHomePage(),'}
    );
  }
  
  Widget _buildHomePage() {
    // Determine home page based on features
    // This would be dynamically generated based on selected features
    return const Scaffold(
      body: Center(
        child: Text('Welcome to $projectName'),
      ),
    );
  }
}''';
}

/// Generate app_router.dart file for routing
void _generateAppRouterFile(
    HookContext context, String projectName, List<dynamic> features) {
  final filePath = '$projectName/lib/app/app_router.dart';

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
      ? "import 'package:$projectName/core/localization/generated/strings.dart';" +
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
import 'package:flutter_modular/flutter_modular.dart';
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
