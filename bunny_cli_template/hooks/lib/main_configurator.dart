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
  
  // Start with imports based on architecture and state management
  mainContent = '''
import 'package:flutter/material.dart';
import 'dart:async';
''';

  // Add imports based on modules
  if (modules.contains('Localization')) {
    mainContent += '''
import 'package:easy_localization/easy_localization.dart';
''';
  }

  if (modules.contains('Local Storage')) {
    mainContent += '''
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
''';
  }

  if (modules.contains('Theme Manager')) {
    mainContent += '''
import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';
''';
  }

  // Add imports based on state management
  if (stateManagement == 'Bloc') {
    mainContent += '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
''';
  } else if (stateManagement == 'Provider') {
    mainContent += '''
import 'package:provider/provider.dart';
''';
  } else if (stateManagement == 'Riverpod') {
    mainContent += '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
''';
  } else if (stateManagement == 'GetX') {
    mainContent += '''
import 'package:get/get.dart';
''';
  } else if (stateManagement == 'MobX') {
    mainContent += '''
import 'package:flutter_mobx/flutter_mobx.dart';
''';
  } else if (stateManagement == 'Redux') {
    mainContent += '''
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
''';
  }

  // Add architecture specific imports
  if (architecture == 'Clean Architecture') {
    mainContent += '''
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:$projectName/core/di/injection.dart';
''';
  } else if (architecture == 'MVVM') {
    mainContent += '''
import 'package:stacked_services/stacked_services.dart';
import 'package:$projectName/app/app.locator.dart';
import 'package:$projectName/app/app.router.dart';
''';
  } else if (architecture == 'Feature-Driven') {
    mainContent += '''
import 'package:flutter_modular/flutter_modular.dart';
import 'package:$projectName/app/app_module.dart';
import 'package:$projectName/app/app_widget.dart';
''';
  }

  // Import app widget based on architecture
  if (architecture != 'Feature-Driven') {
    mainContent += '''
import 'package:$projectName/app/app.dart';
''';
  }

  if (features.contains('Authentication')) {
    mainContent += '''
import 'package:firebase_core/firebase_core.dart';
import 'package:$projectName/firebase_options.dart';
''';
  }

  // Main function declaration
  mainContent += '''

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
''';

  // Add initialization code based on modules
  if (modules.contains('Localization')) {
    mainContent += '''
  await EasyLocalization.ensureInitialized();
''';
  }

  if (features.contains('Authentication')) {
    mainContent += '''
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
''';
  }

  if (modules.contains('Local Storage')) {
    mainContent += '''
  final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDirectory.path);
  
  // Register your Hive adapters here
  // Hive.registerAdapter(YourModelAdapter());
''';
  }

  if (architecture == 'Clean Architecture') {
    mainContent += '''
  await dotenv.load(fileName: ".env");
  await configureDependencies();
''';
  } else if (architecture == 'MVVM') {
    mainContent += '''
  await setupLocator();
''';
  }

  // Setup state management initialization
  if (stateManagement == 'Bloc') {
    mainContent += '''
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await path_provider.getApplicationDocumentsDirectory(),
  );
  
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

  // Add BLoC observer if BLoC is selected
  if (stateManagement == 'Bloc') {
    mainContent += '''

/// Custom BLoC observer for logging BLoC events and transitions
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    debugPrint('onCreate -- bloc: \${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint('onEvent -- bloc: \${bloc.runtimeType}, event: \$event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('onChange -- bloc: \${bloc.runtimeType}, change: \$change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint('onTransition -- bloc: \${bloc.runtimeType}, transition: \$transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('onError -- bloc: \${bloc.runtimeType}, error: \$error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    debugPrint('onClose -- bloc: \${bloc.runtimeType}');
  }
}
''';
  }

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