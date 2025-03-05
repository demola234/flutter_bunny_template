import 'dart:io';

import 'package:mason/mason.dart';

/// Creates the state management observability file and integrates it with the main.dart
void setupObservability(
    HookContext context, String projectName, String stateManagement) {
  // Create the directory path
  final corePath = '$projectName/lib/core/utils';
  final directory = Directory(corePath);
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
    context.logger.info('Created directory: $corePath');
  }

  // Create the observability file
  final observabilityFile =
      File('$projectName/lib/core/utils/state_management_observability.dart');
  final observabilityContent = _generateObservabilityContent(stateManagement);
  observabilityFile.writeAsStringSync(observabilityContent);
  context.logger.success(
      'Created ${stateManagement} state management observability utilities');

  // Update main.dart to integrate observability
  _updateMainDartForObservability(context, projectName, stateManagement);
}

/// Updates the main.dart file to integrate state management observability
void _updateMainDartForObservability(
    HookContext context, String projectName, String stateManagement) {
  final mainDartFile = File('$projectName/lib/main.dart');
  if (!mainDartFile.existsSync()) {
    context.logger
        .warn('main.dart not found, skipping observability integration');
    return;
  }

  // Read existing content
  String content = mainDartFile.readAsStringSync();

  // Add import statement if not already present
  if (!content.contains('state_management_observability.dart')) {
    final importPattern = RegExp(r'import .*;\n');
    final lastImportMatch = importPattern.allMatches(content).lastOrNull;

    if (lastImportMatch != null) {
      final insertPosition = lastImportMatch.end;
      content = content.substring(0, insertPosition) +
          "import 'package:$projectName/core/utils/state_management_observability.dart';\n" +
          content.substring(insertPosition);
    }
  }

  // Add observability setup based on state management
  if (stateManagement == 'BLoC' || stateManagement == 'Bloc') {
    // Add BLoC observer setup
    if (!content.contains('Bloc.observer')) {
      final setupPosition =
          content.indexOf('void main() async {') + 'void main() async {'.length;
      content = content.substring(0, setupPosition) +
          "\n  // Setup BLoC observer for state monitoring\n  Bloc.observer = AppBlocObserver();" +
          content.substring(setupPosition);
    }
  } else if (stateManagement == 'Riverpod') {
    // Add Riverpod observer
    if (content.contains('ProviderScope(')) {
      content = content.replaceAll('ProviderScope(',
          'ProviderScope(\n      observers: [StateObserver()],');
    }
  } else if (stateManagement == 'GetX') {
    // Add GetX observer configuration hint
    if (!content.contains('// GetX observer setup')) {
      final setupPosition =
          content.indexOf('void main() async {') + 'void main() async {'.length;
      content = content.substring(0, setupPosition) +
          "\n  // GetX observer setup - uncomment to enable\n  // Get.put(GetXObserver());" +
          content.substring(setupPosition);
    }
  } else if (stateManagement == 'MobX') {
    // Add MobX observability hint
    if (!content.contains('// MobX observability')) {
      final setupPosition =
          content.indexOf('void main() async {') + 'void main() async {'.length;
      content = content.substring(0, setupPosition) +
          "\n  // MobX observability is available through MobXObserver utility class" +
          content.substring(setupPosition);
    }
  } else if (stateManagement == 'Redux') {
    // Add Redux middleware
    if (content.contains('final store = Store<AppState>(')) {
      content = content.replaceAll('middleware: [thunkMiddleware],',
          'middleware: [thunkMiddleware, ReduxLoggingMiddleware<AppState>().createMiddleware()],');
    }
  } else if (stateManagement == 'Provider') {
    // Add Provider observability hint
    if (!content.contains('// Provider observability')) {
      final setupPosition =
          content.indexOf('void main() async {') + 'void main() async {'.length;
      content = content.substring(0, setupPosition) +
          "\n  // Provider observability is available through ObservableChangeNotifier class" +
          content.substring(setupPosition);
    }
  }

  // Add state observability setup function
  if (!content.contains('setupStateObservability')) {
    final setupPosition =
        content.indexOf('void main() async {') + 'void main() async {'.length;
    content = content.substring(0, setupPosition) +
        "\n  // Setup state management observability\n  setupStateObservability();" +
        content.substring(setupPosition);
  }

  // Write updated content back to file
  mainDartFile.writeAsStringSync(content);
  context.logger
      .success('Integrated state management observability in main.dart');
}

/// Generates the content for the state management observability file based on the selected approach
String _generateObservabilityContent(String stateManagement) {
  // Common imports
  String content = '''
import 'package:flutter/foundation.dart';
''';

  // Utility for logging
  String logUtility = '''
/// Utility function for formatted logging
void _log(String message) {
  if (kDebugMode) {
    print('╔═══════════════════════════════════════════════════════');
    print('║ \$message');
    print('╚═══════════════════════════════════════════════════════');
  }
}
''';

  // Add state management specific imports and classes
  switch (stateManagement) {
    case 'BLoC':
    case 'Bloc':
      content += '''
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC Observer for monitoring BLoC events and state changes
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
    debugPrint(
        'onTransition -- bloc: \${bloc.runtimeType}, transition: \$transition');
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

$logUtility

/// Setup function to initialize observability for BLoC
void setupStateObservability() {
  if (kDebugMode) {
    print('BLoC state observability configured!');
  }
}
''';
      break;

    case 'Riverpod':
      content += '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod Observer for monitoring provider state changes
class StateObserver extends ProviderObserver {
  final bool logChanges;
  final bool logCreations;
  final bool logDisposals;
  final bool logErrors;

  /// Creates a new StateObserver
  ///
  /// - [logChanges]: Log when a provider's state changes
  /// - [logCreations]: Log when a provider is initialized
  /// - [logDisposals]: Log when a provider is disposed
  /// - [logErrors]: Log when a provider throws an error
  StateObserver({
    this.logChanges = true,
    this.logCreations = true,
    this.logDisposals = true,
    this.logErrors = true,
  });

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (logChanges && previousValue != newValue) {
      _log(
        '📊 STATE UPDATED: \${provider.name ?? provider.runtimeType}\\n'
        '⬅️ FROM: \$previousValue\\n'
        '➡️ TO: \$newValue',
      );
    }
    super.didUpdateProvider(provider, previousValue, newValue, container);
  }

  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    if (logCreations) {
      _log(
        '🆕 PROVIDER CREATED: \${provider.name ?? provider.runtimeType}\\n'
        '📌 INITIAL VALUE: \$value',
      );
    }
    super.didAddProvider(provider, value, container);
  }

  @override
  void didDisposeProvider(
    ProviderBase provider,
    ProviderContainer container,
  ) {
    if (logDisposals) {
      _log('🗑️ PROVIDER DISPOSED: \${provider.name ?? provider.runtimeType}');
    }
    super.didDisposeProvider(provider, container);
  }

  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    if (logErrors) {
      _log(
        '❌ PROVIDER ERROR: \${provider.name ?? provider.runtimeType}\\n'
        '🔴 ERROR: \$error\\n'
        '📜 STACK TRACE: \$stackTrace',
      );
    }
    super.providerDidFail(provider, error, stackTrace, container);
  }

  $logUtility
}

/// Setup function to initialize observability for Riverpod
void setupStateObservability() {
  if (kDebugMode) {
    print('Riverpod state observability configured!');
    print('Note: Add observers: [StateObserver()] to your ProviderScope');
  }
}
''';
      break;

    case 'Provider':
      content += '''
/// Enhanced ChangeNotifier for Provider with logging capabilities
class ObservableChangeNotifier extends ChangeNotifier {
  void notifyListenersWithLog(String message,
      {dynamic oldValue, dynamic newValue}) {
    _log('State change in \$runtimeType: \$message');
    if (oldValue != null && newValue != null) {
      _log('  From: \$oldValue');
      _log('  To: \$newValue');
    }
    notifyListeners();
  }

  $logUtility
}

/// Setup function to initialize observability for Provider
void setupStateObservability() {
  if (kDebugMode) {
    print('Provider state observability configured!');
    print('Note: Use ObservableChangeNotifier instead of ChangeNotifier for better logging');
  }
}
''';
      break;

    case 'GetX':
      content += '''
import 'package:get/get.dart';

/// GetX observer implementation
class GetXObserver extends GetxController {
  @override
  void onInit() {
    _log('GetX controller initialized: \$runtimeType');
    super.onInit();
  }

  @override
  void onReady() {
    _log('GetX controller ready: \$runtimeType');
    super.onReady();
  }

  @override
  void onClose() {
    _log('GetX controller closed: \$runtimeType');
    super.onClose();
  }

  $logUtility
}

/// Setup function to initialize observability for GetX
void setupStateObservability() {
  if (kDebugMode) {
    print('GetX state observability configured!');
    print('Note: Create your controllers by extending GetXObserver instead of GetxController');
  }
}
''';
      break;

    case 'MobX':
      content += '''
/// MobX reactive state tracking helper
class MobXObserver {
  static void logAction(String actionName, {dynamic value}) {
    _log('MobX Action: \$actionName\${value != null ? ' - Value: \$value' : ''}');
  }

  static void logComputed(String computedName, dynamic value) {
    _log('MobX Computed: \$computedName - Value: \$value');
  }

  static void logObservable(String observableName, dynamic oldValue, dynamic newValue) {
    _log(
      'MobX Observable: \$observableName\\n'
      '  From: \$oldValue\\n'
      '  To: \$newValue'
    );
  }


}

  $logUtility

/// Setup function to initialize observability for MobX
void setupStateObservability() {
  if (kDebugMode) {
    print('MobX state observability configured!');
    print('Note: Use MobXObserver static methods to log actions, computed values, and observable changes');
  }
}
''';
      break;

    case 'Redux':
      content += '''
import 'package:redux/redux.dart';

/// Redux middleware for logging actions and state changes
class ReduxLoggingMiddleware<T> {
  Middleware<T> createMiddleware() {
    return (Store<T> store, dynamic action, NextDispatcher next) {
      _log('Redux Action: \${action.runtimeType}');
      _log('  Current State: \${store.state}');
      
      next(action);
      
      _log('  Next State: \${store.state}');
    };
  }

  $logUtility
}

/// Setup function to initialize observability for Redux
void setupStateObservability() {
  if (kDebugMode) {
    print('Redux state observability configured!');
    print('Note: Add ReduxLoggingMiddleware().createMiddleware() to your Store middleware list');
  }
}
''';
      break;

    default:
      // Default case - just add the logging utility
      content += '''
/// General utility for state management logging
class StateObserver {
  static void logState(String name, {dynamic value}) {
    _log('State change: \$name\${value != null ? ' - Value: \$value' : ''}');
  }

  $logUtility
}

/// Setup function for state observability
void setupStateObservability() {
  if (kDebugMode) {
    print('State observability utility configured!');
  }
}
''';
      break;
  }

  return content;
}
