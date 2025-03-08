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
import 'package:flutter/services.dart';
''';

  // Add imports based on state management
  if (stateManagement == 'Bloc') {
    mainContent += '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:$projectName/core/utils/state_management_observability.dart';

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
import 'package:$projectName/core/redux/app_reducer.dart';
import 'package:$projectName/core/redux/app_state.dart';
import 'package:redux_thunk/redux_thunk.dart';
''';
  }

  // Add architecture specific imports
  if (architecture == 'Clean Architecture') {
    mainContent += '''
import 'package:flutter_dotenv/flutter_dotenv.dart';

''';
  } else if (architecture == 'MVVM') {
    mainContent += '''
import 'package:flutter_dotenv/flutter_dotenv.dart';
''';
  } else if (architecture == 'MVC') {
    mainContent += '''
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  // Main function declaration
  mainContent += '''

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
''';

  if (architecture == 'Clean Architecture') {
    mainContent += '''
  await dotenv.load(fileName: ".env");
''';
  } else if (architecture == 'MVVM') {
    mainContent += '''
  await dotenv.load(fileName: ".env");
''';
  }

  // Setup state management initialization
  if (stateManagement == 'Bloc') {
    mainContent += '''

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
