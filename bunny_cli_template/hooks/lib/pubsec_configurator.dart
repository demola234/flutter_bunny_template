import 'dart:io';

import 'package:mason/mason.dart';

/// Configures the pubspec.yaml file based on the selected architecture, state management,
/// features, and modules
void configurePubspec(
    HookContext context,
    String projectName,
    String organization,
    String architecture,
    String stateManagement,
    List<dynamic> features,
    List<dynamic> modules) {
  final pubspecFile = File('$projectName/pubspec.yaml');
  String pubspecContent = '';

  // Create pubspec template content
  pubspecContent = '''
name: $projectName
description: A Flutter project was generated by Bunny CLI.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev
version: 1.0.0+1

environment:
  sdk: ^3.6.0

dependencies:
  flutter:
    sdk: flutter

  # Core packages
  cupertino_icons: ^1.0.6
  intl: any
  equatable: ^2.0.5
  path_provider: ^2.1.1
  shared_preferences: ^2.5.2
  flutter_secure_storage: ^9.0.0
  cached_network_image: ^3.3.0
  url_launcher: ^6.1.14
  
  flutter_svg: ^2.0.9
  flutter_dotenv: ^5.1.0
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1
  shimmer: ^3.0.0
  dio: ^5.3.3
  logger: ^2.0.2
''';

  // Add state management dependencies
  if (stateManagement == 'Bloc' || stateManagement == 'BLoC') {
    pubspecContent += '''
  # BLoC state management
  flutter_bloc: ^8.1.3
  bloc: ^8.1.2
  hydrated_bloc: ^8.0.0
''';
  } else if (stateManagement == 'Provider') {
    pubspecContent += '''
  # Provider state management
  provider: ^6.0.5
''';
  } else if (stateManagement == 'Riverpod') {
    pubspecContent += '''
  # Riverpod state management
  flutter_riverpod: ^2.6.1
''';
  } else if (stateManagement == 'GetX') {
    pubspecContent += '''
  # GetX state management
  get: ^4.7.2
''';
  } else if (stateManagement == 'MobX') {
    pubspecContent += '''
  # MobX state management
  mobx: ^2.5.0
  flutter_mobx: ^2.1.0
''';
  } else if (stateManagement == 'Redux') {
    pubspecContent += '''
  # Redux state management
  redux: ^5.0.0
  flutter_redux: ^0.10.0
  redux_thunk: ^0.4.0
''';
  }

  // Add architecture-specific dependencies
  if (architecture == 'Clean Architecture') {
    pubspecContent += '''
  # Clean Architecture dependencies
  dartz: ^0.10.1
  injectable: ^2.3.0
  get_it: ^7.6.4
''';
  } else if (architecture == 'MVVM') {
    pubspecContent += '''
  # MVVM Architecture dependencies
  stacked: ^3.4.1
  stacked_services: ^1.3.0
''';
  } else if (architecture == 'Feature-Driven') {
    pubspecContent += '''
  # Feature-Driven Architecture dependencies
  go_router: ^12.1.1
  flutter_modular: ^6.3.2
''';
  }

  if (features.contains('User Profile')) {
    pubspecContent += '''
  # User Profile dependencies
  image_picker: ^1.0.4
  image_cropper: ^5.0.1
''';
  }

  if (features.contains('Products')) {
    pubspecContent += '''
  # Products feature dependencies
  carousel_slider: ^4.2.1
  infinite_scroll_pagination: ^4.0.0
''';
  }

  // Add dev dependencies
  pubspecContent += '''

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.6
  flutter_gen_runner: ^5.3.2
  flutter_launcher_icons: ^0.13.1
  source_gen: ^1.4.0
''';

  // Add state management-specific dev dependencies
  if (stateManagement == 'Bloc' || stateManagement == 'BLoC') {
    pubspecContent += '''
  bloc_test: ^9.1.4
''';
  } else if (stateManagement == 'Riverpod') {
    pubspecContent += '''
  riverpod_generator: ^2.3.5
''';
  } else if (stateManagement == 'MobX') {
    pubspecContent += '''
  mobx_codegen: ^2.7.0
''';
  }

  // Add feature-specific dev dependencies
  pubspecContent += '''
  json_serializable: ^6.7.1
  freezed: ^2.4.5
''';

  if (modules.contains('Network Layer')) {
    pubspecContent += '''
  internet_connection_checker: ^3.0.1
''';
  }

  if (modules.contains('Local Storage')) {
    pubspecContent += '''
  hive_generator: ^2.0.1
''';
  }

  if (architecture == 'Clean Architecture') {
    pubspecContent += '''
  injectable_generator: ^2.4.0
''';
  }
//   else if (architecture == 'MVVM') {
//     pubspecContent += '''
//   stacked_generator: ^1.5.1
// ''';
//   }

  // Add Flutter configuration
  pubspecContent += '''

# Flutter configuration
flutter:
  uses-material-design: true
  generate: true

  assets:
    - assets/images/
''';

//   // Add conditional assets based on features and modules
//   if (modules.contains('Localization')) {
//     pubspecContent += '''
//     - assets/translations/
// ''';
//   }

  pubspecContent += '''
    - .env

  
''';

  // Flutter native splash configuration if dashboard feature is included
  if (features.contains('Dashboard')) {
    pubspecContent += '''

# Flutter native splash configuration
flutter_native_splash:
  color: "#FFFFFF"
  image: assets/images/splash.png
  android_12:
    image: assets/images/splash_android12.png
    icon_background_color: "#FFFFFF"
  web: false
''';
  }

  // Create directory if it doesn't exist
  final directory = Directory(projectName);
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
    context.logger.info('Created project directory: $projectName');
  }

  // Write the pubspec.yaml file
  pubspecFile.writeAsStringSync(pubspecContent);
  context.logger
      .success('Generated pubspec.yaml with appropriate dependencies');
}
