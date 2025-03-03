import 'dart:io';

import 'package:mason/mason.dart';

/// Integrates the theme system with the main.dart file
void integrateThemeManager(HookContext context, String projectName,
    String stateManagement, List<dynamic> modules) {
  // Only proceed if Theme Manager is selected
  if (!modules.contains('Theme Manager')) {
    return;
  }

  // Get the main.dart file
  final mainDartFile = File('$projectName/lib/main.dart');
  if (!mainDartFile.existsSync()) {
    context.logger
        .warn('main.dart not found, skipping theme manager integration');
    return;
  }

  // Read the existing content
  String content = mainDartFile.readAsStringSync();

  // Add theme-related imports
  if (!content.contains('app_theme_extension.dart')) {
    final importPattern = RegExp(r'import .*;\n');
    final lastImportMatch = importPattern.allMatches(content).lastOrNull;

    if (lastImportMatch != null) {
      final insertPosition = lastImportMatch.end;
      content = content.substring(0, insertPosition) +
          "import 'package:$projectName/core/design_system/theme_extension/app_theme_extension.dart';\n" +
          "import 'package:$projectName/core/design_system/theme_extension/theme_manager.dart';\n" +
          content.substring(insertPosition);
    }
  }

  // Update MaterialApp with theme settings based on state management
  switch (stateManagement) {
    case 'BLoC':
    case 'Bloc':
      _integrateWithBloc(context, projectName, content, mainDartFile);
      break;
    case 'Provider':
      _integrateWithProvider(context, projectName, content, mainDartFile);
      break;
    case 'Riverpod':
      _integrateWithRiverpod(context, projectName, content, mainDartFile);
      break;
    case 'GetX':
      _integrateWithGetX(context, projectName, content, mainDartFile);
      break;
    case 'MobX':
      _integrateWithMobX(context, projectName, content, mainDartFile);
      break;
    case 'Redux':
      _integrateWithRedux(context, projectName, content, mainDartFile);
      break;
    default:
      _integrateWithDefault(context, projectName, content, mainDartFile);
      break;
  }

  context.logger.success('Theme manager integrated with main.dart');
}

/// Integrates theme manager with BLoC state management
void _integrateWithBloc(HookContext context, String projectName, String content,
    File mainDartFile) {
  // Add BlocProvider for ThemeCubit
  if (content.contains('MultiBlocProvider(')) {
    // If MultiBlocProvider exists, add ThemeCubit to the providers list
    final providerPattern = RegExp(r'providers: \[\s*// Add your BLoCs here');
    if (providerPattern.hasMatch(content)) {
      content = content.replaceFirst(providerPattern,
          'providers: [\n        // Theme management\n        BlocProvider(create: (_) => ThemeCubit()),\n        // Add your BLoCs here');
    }
  } else if (content.contains('BlocProvider(')) {
    // If there's a single BlocProvider, convert it to MultiBlocProvider
    content = content.replaceFirst('BlocProvider(',
        'MultiBlocProvider(\n      providers: [\n        // Theme management\n        BlocProvider(create: (_) => ThemeCubit()),\n        ');
    content = content.replaceFirst(
        'child: const App(),', '],\n      child: const App(),');
  } else if (content.contains('runApp(const App())')) {
    // If no BlocProvider exists, add one
    content = content.replaceFirst('runApp(const App())',
        'runApp(\n    BlocProvider(\n      create: (_) => ThemeCubit(),\n      child: const App(),\n    )');
  }

  // Update App widget to use ThemeCubit
  _updateAppWidget(context, projectName, 'bloc');

  // Write updated content back to file
  mainDartFile.writeAsStringSync(content);
}

/// Integrates theme manager with Provider state management
void _integrateWithProvider(HookContext context, String projectName,
    String content, File mainDartFile) {
  // Add ChangeNotifierProvider for ThemeProvider
  if (content.contains('MultiProvider(')) {
    // If MultiProvider exists, add ThemeProvider to the providers list
    final providerPattern =
        RegExp(r'providers: \[\s*// Add your providers here');
    if (providerPattern.hasMatch(content)) {
      content = content.replaceFirst(providerPattern,
          'providers: [\n        // Theme management\n        ChangeNotifierProvider(create: (_) => ThemeProvider()),\n        // Add your providers here');
    }
  } else if (content.contains('ChangeNotifierProvider(')) {
    // If there's a single ChangeNotifierProvider, convert it to MultiProvider
    content = content.replaceFirst('ChangeNotifierProvider(',
        'MultiProvider(\n      providers: [\n        // Theme management\n        ChangeNotifierProvider(create: (_) => ThemeProvider()),\n        ');
    content = content.replaceFirst(
        'child: const App(),', '],\n      child: const App(),');
  } else if (content.contains('runApp(const App())')) {
    // If no ChangeNotifierProvider exists, add one
    content = content.replaceFirst('runApp(const App())',
        'runApp(\n    ChangeNotifierProvider(\n      create: (_) => ThemeProvider(),\n      child: const App(),\n    )');
  }

  // Update App widget to use ThemeProvider
  _updateAppWidget(context, projectName, 'provider');

  // Write updated content back to file
  mainDartFile.writeAsStringSync(content);
}

/// Integrates theme manager with Riverpod state management
void _integrateWithRiverpod(HookContext context, String projectName,
    String content, File mainDartFile) {
  // Add initialization for theme in ProviderScope
  if (content.contains('ProviderScope(')) {
    // Ensure themeProvider is imported
    content = content.replaceFirst('child: const App(),',
        'child: Consumer(\n        builder: (context, ref, child) {\n          final themeMode = ref.watch(flutterThemeModeProvider);\n          return App(themeMode: themeMode);\n        },\n      ),');
  } else if (content.contains('runApp(const App())')) {
    // If no ProviderScope exists, add one
    content = content.replaceFirst('runApp(const App())',
        'runApp(\n    ProviderScope(\n      child: Consumer(\n        builder: (context, ref, child) {\n          final themeMode = ref.watch(flutterThemeModeProvider);\n          return App(themeMode: themeMode);\n        },\n      ),\n    )');
  }

  // Update App widget to use Riverpod theme
  _updateAppWidget(context, projectName, 'riverpod');

  // Write updated content back to file
  mainDartFile.writeAsStringSync(content);
}

/// Integrates theme manager with GetX state management
void _integrateWithGetX(HookContext context, String projectName, String content,
    File mainDartFile) {
  // Initialize theme controller in main
  if (content.contains('void main() async {')) {
    final mainPosition =
        content.indexOf('void main() async {') + 'void main() async {'.length;
    content = content.substring(0, mainPosition) +
        "\n  // Initialize theme controller\n  Get.put(ThemeController());" +
        content.substring(mainPosition);
  }

  // Update GetMaterialApp for theme
  if (content.contains('GetMaterialApp(')) {
    content = content.replaceAll('GetMaterialApp(',
        'GetMaterialApp(\n      theme: AppTheme.light,\n      darkTheme: AppTheme.dark,\n      themeMode: Get.find<ThemeController>().themeMode,');
  } else if (content.contains('MaterialApp(')) {
    content = content.replaceAll('MaterialApp(',
        'GetMaterialApp(\n      theme: AppTheme.light,\n      darkTheme: AppTheme.dark,\n      themeMode: Get.find<ThemeController>().themeMode,');
  }

  // Write updated content back to file
  mainDartFile.writeAsStringSync(content);
}

/// Integrates theme manager with MobX state management
void _integrateWithMobX(HookContext context, String projectName, String content,
    File mainDartFile) {
  // Add Observer for theme
  if (content.contains('runApp(const App())')) {
    content = content.replaceFirst('runApp(const App())',
        'runApp(\n    Observer(\n      builder: (_) => App(\n        themeMode: themeStore.flutterThemeMode,\n      ),\n    )');
  }

  // Update App widget to use MobX theme
  _updateAppWidget(context, projectName, 'mobx');

  // Write updated content back to file
  mainDartFile.writeAsStringSync(content);

  // Import flutter_mobx
  if (!content.contains('flutter_mobx')) {
    final importPosition = content.indexOf('import ');
    content = content.substring(0, importPosition) +
        "import 'package:flutter_mobx/flutter_mobx.dart';\n" +
        content.substring(importPosition);
    mainDartFile.writeAsStringSync(content);
  }
}

/// Integrates theme manager with Redux state management
void _integrateWithRedux(HookContext context, String projectName,
    String content, File mainDartFile) {
  // Add theme middleware to store creation
  if (content.contains('middleware: [thunkMiddleware]')) {
    content = content.replaceAll('middleware: [thunkMiddleware]',
        'middleware: [thunkMiddleware, ...createThemeMiddleware()]');
  }

  // Dispatch load theme action
  if (content.contains('void main() async {')) {
    final storePattern = RegExp(r'final store = Store<AppState>\(');
    if (storePattern.hasMatch(content)) {
      final dispatchPosition = content.indexOf('runApp(');
      content = content.substring(0, dispatchPosition) +
          "  // Load theme when app starts\n  store.dispatch(LoadThemeAction());\n\n" +
          content.substring(dispatchPosition);
    }
  }

  // Update StoreProvider to handle theme
  if (content.contains('StoreProvider<AppState>(')) {
    content = content.replaceAll('child: const App(),',
        'child: StoreConnector<AppState, ThemeState>(\n        converter: (store) => store.state.themeState,\n        builder: (context, themeState) {\n          return App(\n            themeMode: themeState.flutterThemeMode,\n          );\n        },\n      ),');
  }

  // Update App widget to use Redux theme
  _updateAppWidget(context, projectName, 'redux');

  // Write updated content back to file
  mainDartFile.writeAsStringSync(content);
}

/// Integrates theme manager with default implementation
void _integrateWithDefault(HookContext context, String projectName,
    String content, File mainDartFile) {
  // Initialize theme manager
  if (content.contains('void main() async {')) {
    final mainPosition =
        content.indexOf('void main() async {') + 'void main() async {'.length;
    content = content.substring(0, mainPosition) +
        "\n  // Initialize theme manager\n  await themeManager.initialize();" +
        content.substring(mainPosition);
  }

  // Create simple theme listener setup and modify App parameters
  final appWidgetFile = File('$projectName/lib/app/app.dart');
  if (appWidgetFile.existsSync()) {
    String appContent = appWidgetFile.readAsStringSync();

    // Check if already modified
    if (!appContent.contains('themeMode:')) {
      // Add a StatefulWidget version that listens to theme changes
      appContent = '''
import 'package:flutter/material.dart';
import 'package:$projectName/core/design_system/theme_extension/app_theme_extension.dart';
import 'package:$projectName/core/design_system/theme_extension/theme_manager.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  ThemeModeEnum _currentTheme = ThemeModeEnum.system;

  @override
  void initState() {
    super.initState();
    _currentTheme = themeManager.currentTheme;
    themeManager.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeManager.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged(ThemeModeEnum theme) {
    setState(() {
      _currentTheme = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _currentTheme.toThemeMode(),
      home: const HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              // Toggle between light, dark, and system theme
              final newTheme = _getNextTheme(themeManager.currentTheme);
              themeManager.setTheme(newTheme);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '\$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  ThemeModeEnum _getNextTheme(ThemeModeEnum current) {
    switch (current) {
      case ThemeModeEnum.light:
        return ThemeModeEnum.dark;
      case ThemeModeEnum.dark:
        return ThemeModeEnum.system;
      case ThemeModeEnum.system:
        return ThemeModeEnum.light;
    }
  }
}
''';

      appWidgetFile.writeAsStringSync(appContent);
      context.logger.info('Updated app.dart with theme functionality');
    }
  }

  // Write updated content back to file
  mainDartFile.writeAsStringSync(content);
}

/// Updates the App widget to use the correct theme implementation
void _updateAppWidget(
    HookContext context, String projectName, String stateManagement) {
  final appWidgetFile = File('$projectName/lib/app/app.dart');
  if (!appWidgetFile.existsSync()) {
    context.logger.warn('app.dart not found, skipping app widget update');
    return;
  }

  String appContent = appWidgetFile.readAsStringSync();

  // Add theme imports if not present
  if (!appContent.contains('app_theme_extension.dart')) {
    final importPattern = RegExp(r'import .*;\n');
    final lastImportMatch = importPattern.allMatches(appContent).lastOrNull;

    if (lastImportMatch != null) {
      final insertPosition = lastImportMatch.end;
      appContent = appContent.substring(0, insertPosition) +
          "import 'package:$projectName/core/design_system/theme_extension/app_theme_extension.dart';\n" +
          "import 'package:$projectName/core/design_system/theme_extension/theme_manager.dart';\n" +
          appContent.substring(insertPosition);
    }
  }

  // Update the build method based on state management
  if (appContent.contains('class App extends StatelessWidget')) {
    // First add ThemeMode parameter to App constructor
    if (!appContent.contains('final ThemeMode?')) {
      appContent = appContent.replaceFirst(
          'class App extends StatelessWidget {',
          'class App extends StatelessWidget {\n  final ThemeMode? themeMode;\n');

      appContent = appContent.replaceFirst(
          'const App({Key? key}) : super(key: key);',
          'const App({Key? key, this.themeMode}) : super(key: key);');
    }

    // Update MaterialApp with theme properties
    if (appContent.contains('return MaterialApp(')) {
      appContent = appContent.replaceAll('return MaterialApp(',
          'return MaterialApp(\n      theme: AppTheme.light,\n      darkTheme: AppTheme.dark,\n      themeMode: themeMode ?? ThemeMode.system,');
    }
  }

  // State management-specific modifications
  switch (stateManagement) {
    case 'bloc':
      // Add BlocBuilder for theme if not already added
      if (!appContent.contains('BlocBuilder<ThemeCubit, ThemeState>')) {
        if (appContent.contains('Widget build(BuildContext context) {')) {
          appContent = appContent.replaceFirst(
              'Widget build(BuildContext context) {',
              'Widget build(BuildContext context) {\n    return BlocBuilder<ThemeCubit, ThemeState>(\n      builder: (context, themeState) {');

          appContent = appContent.replaceFirst(
              'return MaterialApp(', '        return MaterialApp(');

          // Find the end of the MaterialApp and add closing brackets
          final materialAppEndMatch = RegExp(r';\s*\}').firstMatch(appContent);
          if (materialAppEndMatch != null) {
            final position = materialAppEndMatch.start;
            appContent = appContent.substring(0, position) +
                ';\n      },\n    );\n  ' +
                appContent.substring(position);
          }
        }
      }
      break;

    case 'provider':
      // Add Consumer for theme if not already added
      if (!appContent.contains('Consumer<ThemeProvider>')) {
        if (appContent.contains('Widget build(BuildContext context) {')) {
          appContent = appContent.replaceFirst(
              'Widget build(BuildContext context) {',
              'Widget build(BuildContext context) {\n    return Consumer<ThemeProvider>(\n      builder: (context, themeProvider, _) {');

          appContent = appContent.replaceFirst(
              'return MaterialApp(', '        return MaterialApp(');

          // Update themeMode to use themeProvider
          appContent = appContent.replaceAll(
              'themeMode: themeMode ?? ThemeMode.system,',
              'themeMode: themeProvider.flutterThemeMode,');

          // Find the end of the MaterialApp and add closing brackets
          final materialAppEndMatch = RegExp(r';\s*\}').firstMatch(appContent);
          if (materialAppEndMatch != null) {
            final position = materialAppEndMatch.start;
            appContent = appContent.substring(0, position) +
                ';\n      },\n    );\n  ' +
                appContent.substring(position);
          }
        }
      }
      break;

    case 'riverpod':
      // For Riverpod, the themeMode parameter passed to App is already correctly handled
      // No need for additional changes here, as we're passing the themeMode from the Consumer
      break;

    case 'mobx':
      // For MobX, the themeMode parameter passed to App is already correctly handled
      // from the Observer widget in the main.dart file
      break;

    case 'redux':
      // For Redux, the themeMode parameter passed to App is already correctly handled
      // from the StoreConnector in the main.dart file
      break;
  }

  // Write updated content back to file
  appWidgetFile.writeAsStringSync(appContent);
  context.logger.info('Updated app.dart with theme support');
}
