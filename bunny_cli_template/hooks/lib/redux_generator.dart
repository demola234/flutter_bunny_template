import 'dart:io';

import 'package:mason/mason.dart';

/// Generates the necessary Redux files for state management
void generateReduxFiles(
    HookContext context, String projectName, String stateManagement) {
  context.logger.info('Generating Redux files for $projectName');

  if (stateManagement != 'Redux') {
    context.logger
        .warn('State management is not Redux, skipping Redux file generation');
    return;
  }

  // Create directory structure
  final directories = [
    'lib/core/redux',
    'lib/core/redux/actions',
    'lib/core/redux/reducers',
    'lib/core/redux/middleware',
    'lib/core/redux/models',
    'lib/core/redux/store',
  ];

  for (final dir in directories) {
    final directory = Directory('$projectName/$dir');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      context.logger.info('Created directory: $dir');
    }
  }

  // Generate the core Redux files
  _generateAppStateFile(context, projectName);
  _generateAppReducerFile(context, projectName);
  _generateMiddlewareFile(context, projectName);
  _generateStoreFile(context, projectName);

  // Generate some sample feature-specific Redux files
  _generateAuthStateFile(context, projectName);
  _generateThemeStateFile(context, projectName);

  context.logger.success('Redux files generated successfully!');
}

/// Generates the main app state file
void _generateAppStateFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/redux/app_state.dart';
  final content = '''
import 'package:equatable/equatable.dart';

import 'models/auth_state.dart';
import 'models/theme_state.dart';

/// Main application state for Redux
class AppState extends Equatable {
  final AuthState authState;
  final ThemeState themeState;
  
  const AppState({
    required this.authState,
    required this.themeState,
  });
  
  /// Creates the initial state with default values
  factory AppState.initial() {
    return AppState(
      authState: AuthState.initial(),
      themeState: ThemeState.initial(),
    );
  }
  
  /// Creates a new AppState with only the specified fields updated
  AppState copyWith({
    AuthState? authState,
    ThemeState? themeState,
  }) {
    return AppState(
      authState: authState ?? this.authState,
      themeState: themeState ?? this.themeState,
    );
  }
  
  @override
  List<Object> get props => [authState, themeState];
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the main app reducer file
void _generateAppReducerFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/redux/app_reducer.dart';
  final content = '''
import 'app_state.dart';
import 'reducers/auth_reducer.dart';
import 'reducers/theme_reducer.dart';

/// Main app reducer that combines all individual reducers
AppState appReducer(AppState state, dynamic action) {
  return AppState(
    authState: authReducer(state.authState, action),
    themeState: themeReducer(state.themeState, action),
  );
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the Redux middleware file
void _generateMiddlewareFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/redux/middleware/middleware.dart';
  final content = '''
import 'package:redux/redux.dart';

import '../app_state.dart';
import 'logger_middleware.dart';

/// Creates and returns all middleware for the app
List<Middleware<AppState>> createMiddleware() {
  return [
    // Add thunk middleware for async actions
    _createThunkMiddleware(),
    // Add custom logging middleware
    LoggerMiddleware().createMiddleware(),
    // Add more middleware here
  ];
}

/// Creates a thunk middleware that allows dispatching functions
Middleware<AppState> _createThunkMiddleware() {
  return (Store<AppState> store, dynamic action, NextDispatcher next) {
    if (action is Function) {
      return action(store);
    }
    return next(action);
  };
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');

  // Create logger middleware
  _generateLoggerMiddlewareFile(context, projectName);
}

/// Generates a logger middleware file
void _generateLoggerMiddlewareFile(HookContext context, String projectName) {
  final filePath =
      '$projectName/lib/core/redux/middleware/logger_middleware.dart';
  final content = '''
import 'package:redux/redux.dart';
import 'package:flutter/foundation.dart';

import '../app_state.dart';

/// Middleware for logging Redux actions and state changes
class LoggerMiddleware {
  /// Creates the middleware function
  Middleware<AppState> createMiddleware() {
    return (Store<AppState> store, dynamic action, NextDispatcher next) {
      if (kDebugMode) {
        print('\\n═══════════════════════════════════════');
        print('Action: \${action.runtimeType}');
        print('Previous state: \${_getStateSummary(store.state)}');
      }
      
      next(action);
      
      if (kDebugMode) {
        print('New state: \${_getStateSummary(store.state)}');
        print('═══════════════════════════════════════\\n');
      }
    };
  }
  
  /// Creates a summary of the state for logging
  String _getStateSummary(AppState state) {
    return '{auth: \${state.authState.isAuthenticated ? 'Authenticated' : 'Not authenticated'}, '
        'theme: \${state.themeState.themeMode.name}}';
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the store configuration file
void _generateStoreFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/redux/store/store.dart';
  final content = '''
import 'package:redux/redux.dart';

import '../app_state.dart';
import '../app_reducer.dart';
import '../middleware/middleware.dart';

/// Configures and creates the Redux store
Store<AppState> createStore() {
  return Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: createMiddleware(),
  );
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates a sample auth state file
void _generateAuthStateFile(HookContext context, String projectName) {
  // Generate the auth state model
  final stateFilePath = '$projectName/lib/core/redux/models/auth_state.dart';
  final stateContent = '''
import 'package:equatable/equatable.dart';

/// Authentication state for Redux
class AuthState extends Equatable {
  final bool isAuthenticated;
  final String? token;
  final String? userId;
  final bool isLoading;
  final String? error;
  
  const AuthState({
    required this.isAuthenticated,
    this.token,
    this.userId,
    this.isLoading = false,
    this.error,
  });
  
  /// Creates the initial auth state
  factory AuthState.initial() {
    return const AuthState(isAuthenticated: false);
  }
  
  /// Creates a new AuthState with only the specified fields updated
  AuthState copyWith({
    bool? isAuthenticated,
    String? token,
    String? userId,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
  
  @override
  List<Object?> get props => [isAuthenticated, token, userId, isLoading, error];
}
''';

  final stateFile = File(stateFilePath);
  stateFile.writeAsStringSync(stateContent);
  context.logger.info('Created file: $stateFilePath');

  // Generate auth actions
  final actionsFilePath =
      '$projectName/lib/core/redux/actions/auth_actions.dart';
  final actionsContent = '''
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import '../app_state.dart';

/// Action when login process starts
class LoginRequestAction {
  final String email;
  
  LoginRequestAction(this.email);
}

/// Action when login is successful
class LoginSuccessAction {
  final String token;
  final String userId;
  
  LoginSuccessAction(this.token, this.userId);
}

/// Action when login fails
class LoginFailureAction {
  final String error;
  
  LoginFailureAction(this.error);
}

/// Action when logout occurs
class LogoutAction {}

/// Async action creator for login
Function login(String email, String password) {
  return (Store<AppState> store) async {
    // Dispatch action to update state to loading
    store.dispatch(LoginRequestAction(email));
    
    try {
      // Simulate API call with delay
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, you would make an actual API call here
      // For this example, we'll just simulate a successful login
      if (email == 'test@example.com' && password == 'password') {
        store.dispatch(LoginSuccessAction('fake-token-123', 'user-123'));
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      store.dispatch(LoginFailureAction(e.toString()));
    }
  };
}

/// Async action creator for logout
Function logout() {
  return (Store<AppState> store) async {
    // In a real app, you might need to clear tokens or do other cleanup here
    store.dispatch(LogoutAction());
  };
}
''';

  final actionsFile = File(actionsFilePath);
  actionsFile.writeAsStringSync(actionsContent);
  context.logger.info('Created file: $actionsFilePath');

  // Generate auth reducer
  final reducerFilePath =
      '$projectName/lib/core/redux/reducers/auth_reducer.dart';
  final reducerContent = '''
import '../models/auth_state.dart';
import '../actions/auth_actions.dart';

/// Reducer for authentication state
AuthState authReducer(AuthState state, dynamic action) {
  if (action is LoginRequestAction) {
    return state.copyWith(
      isLoading: true,
      error: null,
    );
  } else if (action is LoginSuccessAction) {
    return state.copyWith(
      isAuthenticated: true,
      token: action.token,
      userId: action.userId,
      isLoading: false,
    );
  } else if (action is LoginFailureAction) {
    return state.copyWith(
      isAuthenticated: false,
      isLoading: false,
      error: action.error,
    );
  } else if (action is LogoutAction) {
    return const AuthState(isAuthenticated: false);
  }
  
  return state;
}
''';

  final reducerFile = File(reducerFilePath);
  reducerFile.writeAsStringSync(reducerContent);
  context.logger.info('Created file: $reducerFilePath');
}

/// Generates a sample theme state file
void _generateThemeStateFile(HookContext context, String projectName) {
  // Generate the theme state model
  final stateFilePath = '$projectName/lib/core/redux/models/theme_state.dart';
  final stateContent = '''
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Theme mode enum for Redux state
enum ThemeMode {
  light,
  dark,
  system;
  
  /// Convert to Flutter's ThemeMode
  ThemeMode toFlutterThemeMode() {
    switch (this) {
      case ThemeMode.light:
        return ThemeMode.light;
      case ThemeMode.dark:
        return ThemeMode.dark;
      case ThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// Theme state for Redux
class ThemeState extends Equatable {
  final ThemeMode themeMode;
  
  const ThemeState({
    this.themeMode = ThemeMode.system,
  });
  
  /// Creates the initial theme state
  factory ThemeState.initial() {
    return const ThemeState();
  }
  
  /// Creates a new ThemeState with only the specified fields updated
  ThemeState copyWith({
    ThemeMode? themeMode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }
  
  @override
  List<Object> get props => [themeMode];
}
''';

  final stateFile = File(stateFilePath);
  stateFile.writeAsStringSync(stateContent);
  context.logger.info('Created file: $stateFilePath');

  // Generate theme actions
  final actionsFilePath =
      '$projectName/lib/core/redux/actions/theme_actions.dart';
  final actionsContent = '''
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_state.dart';
import '../models/theme_state.dart';

/// Action to set theme mode
class SetThemeModeAction {
  final ThemeMode themeMode;
  
  SetThemeModeAction(this.themeMode);
}

/// Action to load theme from storage
class LoadThemeAction {}

/// Action when theme is loaded from storage
class ThemeLoadedAction {
  final ThemeMode themeMode;
  
  ThemeLoadedAction(this.themeMode);
}

/// Async action creator to set theme
Function setThemeMode(ThemeMode themeMode) {
  return (Store<AppState> store) async {
    // Save theme preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', themeMode.index);
    
    // Update state
    store.dispatch(SetThemeModeAction(themeMode));
  };
}

/// Async action creator to load theme from storage
Function loadTheme() {
  return (Store<AppState> store) async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('theme_mode');
    
    if (themeModeIndex != null) {
      final themeMode = ThemeMode.values[themeModeIndex.clamp(0, ThemeMode.values.length - 1)];
      store.dispatch(ThemeLoadedAction(themeMode));
    }
  };
}
''';

  final actionsFile = File(actionsFilePath);
  actionsFile.writeAsStringSync(actionsContent);
  context.logger.info('Created file: $actionsFilePath');

  // Generate theme reducer
  final reducerFilePath =
      '$projectName/lib/core/redux/reducers/theme_reducer.dart';
  final reducerContent = '''
import '../models/theme_state.dart';
import '../actions/theme_actions.dart';

/// Reducer for theme state
ThemeState themeReducer(ThemeState state, dynamic action) {
  if (action is SetThemeModeAction) {
    return state.copyWith(themeMode: action.themeMode);
  } else if (action is ThemeLoadedAction) {
    return state.copyWith(themeMode: action.themeMode);
  }
  
  return state;
}
''';

  final reducerFile = File(reducerFilePath);
  reducerFile.writeAsStringSync(reducerContent);
  context.logger.info('Created file: $reducerFilePath');
}

/// Updates the main.dart file to use Redux
void updateMainDartForRedux(HookContext context, String projectName) {
  final mainDartFile = File('$projectName/lib/main.dart');
  if (!mainDartFile.existsSync()) {
    context.logger.warn('main.dart not found, skipping Redux integration');
    return;
  }

  String content = mainDartFile.readAsStringSync();

  // Add the necessary imports
  final imports = '''
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'core/redux/app_state.dart';
import 'core/redux/app_reducer.dart';
import 'core/redux/middleware/middleware.dart';
import 'core/redux/store/store.dart';
''';

  // Find a good position to insert imports
  final importPattern = RegExp(r'import .*;\n');
  final lastImportMatch = importPattern.allMatches(content).lastOrNull;

  if (lastImportMatch != null) {
    final insertPosition = lastImportMatch.end;
    content = content.substring(0, insertPosition) +
        imports +
        content.substring(insertPosition);
  }

  // Replace the runApp section with Redux store provider
  final runAppPattern = RegExp(r'runApp\(\s*[^;]*\);');
  if (runAppPattern.hasMatch(content)) {
    content = content.replaceFirst(runAppPattern, '''
runApp(
  StoreProvider<AppState>(
    store: createStore(),
    child: const App(),
  ),
);''');
  }

  // Create the Redux store before runApp if it's not already there
  if (!content.contains('createStore()')) {
    final mainFunctionPattern = RegExp(r'void main\(\) async \{');
    final storeInitCode = '''
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
''';

    if (content.contains(mainFunctionPattern)) {
      // Add store initialization code
      final appInitPattern =
          RegExp(r'WidgetsFlutterBinding.ensureInitialized\(\);');
      if (appInitPattern.hasMatch(content)) {
        content = content.replaceFirst(appInitPattern, '''
WidgetsFlutterBinding.ensureInitialized();

// Load environment variables
await dotenv.load(fileName: ".env");

// Initialize state
final store = createStore();

// Load saved theme
store.dispatch(loadTheme());
''');
      } else {
        // If no WidgetsFlutterBinding, replace the main function start
        content = content.replaceFirst(mainFunctionPattern, storeInitCode);
      }
    }
  }

  // Write updated content back to file
  mainDartFile.writeAsStringSync(content);
  context.logger.success('Updated main.dart with Redux configuration');
}

/// Updates the App widget to handle Redux state
void updateAppWidgetForRedux(HookContext context, String projectName) {
  final appFile = File('$projectName/lib/app/app.dart');
  if (!appFile.existsSync()) {
    context.logger.warn('app.dart not found, skipping Redux integration');
    return;
  }

  String content = appFile.readAsStringSync();

  // Add Redux imports
  final imports = '''
import 'package:flutter_redux/flutter_redux.dart';
import '../core/redux/app_state.dart';
import '../core/redux/models/theme_state.dart' as theme;
import '../core/redux/actions/auth_actions.dart';
import '../core/redux/actions/theme_actions.dart';
''';

  // Find a good position to insert imports
  final importPattern = RegExp(r'import .*;\n');
  final lastImportMatch = importPattern.allMatches(content).lastOrNull;

  if (lastImportMatch != null) {
    final insertPosition = lastImportMatch.end;
    content = content.substring(0, insertPosition) +
        imports +
        content.substring(insertPosition);
  }

  // Update the app class to use StoreConnector
  final appClassPattern =
      RegExp(r'class App extends StatelessWidget \{[^}]*\}', dotAll: true);
  if (appClassPattern.hasMatch(content)) {
    content = content.replaceFirst(appClassPattern, '''
class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, theme.ThemeMode>(
      converter: (store) => store.state.themeState.themeMode,
      builder: (context, themeMode) {
        return MaterialApp(
          title: 'Flutter Redux App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: themeMode.toFlutterThemeMode(),
          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redux Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_4),
            onPressed: () {
              // Toggle theme
              final store = StoreProvider.of<AppState>(context);
              final currentMode = store.state.themeState.themeMode;
              final newMode = currentMode == theme.ThemeMode.light
                      ? theme.ThemeMode.dark
                      : theme.ThemeMode.light;
              
              store.dispatch(SetThemeModeAction(newMode));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display auth state
            StoreConnector<AppState, bool>(
              converter: (store) => store.state.authState.isAuthenticated,
              builder: (context, isAuthenticated) {
                return Text(
                  'Auth Status: \${store.state.authState.isAuthenticated ? "Logged In" : "Logged Out"}',
                  style: Theme.of(context).textTheme.headlineSmall,
                );
              },
            ),
            const SizedBox(height: 20),
            // Login/Logout button
            StoreConnector<AppState, VoidCallback>(
              converter: (store) {
                return store.state.authState.isAuthenticated
                    ? () => store.dispatch(
                          (Store<AppState> store) async {
                            store.dispatch(LogoutAction());
                          },
                        )
                    : () => store.dispatch(
                          (Store<AppState> store) async {
                            store.dispatch(LoginRequestAction('test@example.com'));
                            await Future.delayed(const Duration(seconds: 1));
                            store.dispatch(LoginSuccessAction('fake-token-123', 'user-123'));
                          },
                        );
              },
              builder: (context, callback) {
                return ElevatedButton(
                  onPressed: callback,
                  child: StoreConnector<AppState, bool>(
                    converter: (store) => store.state.authState.isAuthenticated,
                    builder: (context, isAuthenticated) {
                      return Text(isAuthenticated ? 'Logout' : 'Login');
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
''');
  }

  // Write updated content back to file
  appFile.writeAsStringSync(content);
  context.logger.success('Updated app.dart to work with Redux');
}


