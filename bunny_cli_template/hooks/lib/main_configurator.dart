import 'dart:io';

import 'package:mason/mason.dart';

/// Generates the main.dart file based on the selected architecture, state management,
/// features, and modules
void generateMainDart(
    HookContext context,
    String projectName,
    String organization,
    String architecture,
    String stateManagement,
    List<dynamic> features,
    List<dynamic> modules) {
  final mainFile = File('$projectName/lib/main.dart');
  String mainContent = '';

  // Determine if Firebase is needed based on modules
  final needsFirebase = modules.contains('Push Notification');

  // Start with imports in the correct order
  var imports = [
    // Firebase should be first if used
    needsFirebase ? "import 'package:firebase_core/firebase_core.dart';" : "",
    "import 'package:flutter/material.dart';",
    "import 'package:flutter/services.dart';",
  ];

  // Add architecture-specific imports
  if (architecture == 'Clean Architecture' ||
      architecture == 'MVVM' ||
      architecture == 'MVC') {
    imports.add("import 'package:flutter_dotenv/flutter_dotenv.dart';");
  }

  // Add state management imports
  if (stateManagement == 'Bloc') {
    imports.add("import 'package:flutter_bloc/flutter_bloc.dart';");
    imports.add("import 'package:hydrated_bloc/hydrated_bloc.dart';");
    imports.add(
        "import 'package:$projectName/core/utils/state_management_observability.dart';");
  } else if (stateManagement == 'Provider') {
    imports.add("import 'package:provider/provider.dart';");
  } else if (stateManagement == 'Riverpod') {
    imports.add("import 'package:flutter_riverpod/flutter_riverpod.dart';");
  } else if (stateManagement == 'GetX') {
    imports.add("import 'package:get/get.dart';");
  } else if (stateManagement == 'MobX') {
    imports.add("import 'package:flutter_mobx/flutter_mobx.dart';");
  } else if (stateManagement == 'Redux') {
    imports.add("import 'package:flutter_redux/flutter_redux.dart';");
    imports.add("import 'package:redux/redux.dart';");
    imports.add("import 'package:$projectName/core/redux/app_reducer.dart';");
    imports.add("import 'package:$projectName/core/redux/app_state.dart';");
    imports.add("import 'package:redux_thunk/redux_thunk.dart';");
  }

  // Feature-Driven architecture imports
  if (architecture == 'Feature-Driven') {
    imports.add("import 'package:flutter_modular/flutter_modular.dart';");
    imports.add("import 'package:$projectName/app/app_module.dart';");
    imports.add("import 'package:$projectName/app/app_widget.dart';");
  } else {
    imports.add("import 'package:$projectName/app/app.dart';");
  }

  // Add notification handler import if needed
  if (needsFirebase) {
    imports.add(
        "import 'package:$projectName/core/notifications/notification_handler.dart';");
  }

  // Filter out empty imports and join them
  mainContent =
      imports.where((import) => import.isNotEmpty).join('\n') + '\n\n';

  // Main function declaration
  mainContent += '''
void main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();
''';

  // Firebase initialization should come first if needed
  if (needsFirebase) {
    mainContent += '''
  // Initialize Firebase
  await Firebase.initializeApp(
// Uncomment the following line if you have a custom Firebase options file
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notification services
  await notificationHandler.initialize();

''';
  }

  // Environment variables loading
  if (architecture == 'Clean Architecture' ||
      architecture == 'MVVM' ||
      architecture == 'MVC') {
    mainContent += '''
  // Load environment variables
  await dotenv.load(fileName: ".env");
''';
  }

  // Setup state management initialization
  if (stateManagement == 'Bloc') {
    mainContent += '''
  // Initialize BLoC observer
  Bloc.observer = AppBlocObserver();
''';
  }

  // Platform-specific configurations
  mainContent += '''
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
''';

  // App launch based on architecture and state management
  if (architecture == 'Feature-Driven') {
    mainContent += '''
  runApp(ModularApp(module: AppModule(), child: const AppWidget()));
''';
  } else {
    // Run app based on state management
    if (stateManagement == 'Provider') {
      mainContent += '''
  runApp(
    MultiProvider(
      providers: [
        // Add your providers here
        // ChangeNotifierProvider(create: (_) => YourProvider()),
      ],
      child: const App(),
    ),
  );
''';
    } else if (stateManagement == 'Riverpod') {
      mainContent += '''
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
''';
    } else if (stateManagement == 'GetX') {
      mainContent += '''
  runApp(const App());
''';
    } else if (stateManagement == 'Bloc') {
      mainContent += '''
  runApp(
    MultiBlocProvider(
      providers: [
        // Add your BLoCs here
        // BlocProvider(create: (_) => YourBloc()),
      ],
      child: const App(),
    ),
  );
''';
    } else if (stateManagement == 'MobX') {
      mainContent += '''
  runApp(const App());
''';
    } else if (stateManagement == 'Redux') {
      mainContent += '''
  final store = Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: [thunkMiddleware],
  );
  
  runApp(
    StoreProvider<AppState>(
      store: store,
      child: const App(),
    ),
  );
''';
    } else {
      // Default
      mainContent += '''
  runApp(const App());
''';
    }
  }

  // Close main function
  mainContent += '''}
''';

  // Create parent directory if it doesn't exist
  final libDirectory = Directory('$projectName/lib');
  if (!libDirectory.existsSync()) {
    libDirectory.createSync(recursive: true);
    context.logger.info('Created lib directory: $projectName/lib');
  }

  // Write the main.dart file
  mainFile.writeAsStringSync(mainContent);
  context.logger.success('Generated main.dart based on project configuration');
}
