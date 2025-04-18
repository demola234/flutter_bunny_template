import 'dart:io';

import 'package:flutter_bunny_cli/app_bunny_screen_generator.dart';
import 'package:flutter_bunny_cli/app_generator.dart';
import 'package:flutter_bunny_cli/error_generator.dart';
import 'package:flutter_bunny_cli/localization_generator.dart';
import 'package:flutter_bunny_cli/main_configurator.dart';
import 'package:flutter_bunny_cli/network_layer_generator.dart';
import 'package:flutter_bunny_cli/pubsec_configurator.dart';
import 'package:flutter_bunny_cli/push_notification_generator.dart';
import 'package:flutter_bunny_cli/redux_generator.dart';
import 'package:flutter_bunny_cli/state_management_observablity.dart';
import 'package:flutter_bunny_cli/theme_manager_generator.dart';
import 'package:mason/mason.dart';

// Import helper files
import 'lib/architecture_handler.dart';
import 'lib/feature_generator.dart';
import 'lib/utils.dart';

void run(HookContext context) {
  // Validate project name
  final projectName = context.vars['project_name'] as String;
  final architecture = context.vars['architecture'] as String;
  final organizationName = context.vars['bundle_identifier'] as String;
  final stateManagement = context.vars['state_management'] as String;
  var features = context.vars['features'] as List<dynamic>;
  final modules = context.vars['modules'] as List<dynamic>;

  // Validate project name
  if (!isValidProjectName(projectName)) {
    throw ArgumentError(
        'Invalid project name. Must start with a letter or underscore, '
        'contain only lowercase letters, numbers, and underscores.');
  }

  // Make Authentication the default feature if none are selected
  if (features.isEmpty) {
    features = ['Authentication'];
    context.logger
        .info('No features selected, adding default feature: Authentication');
  } else if (!features.contains('Authentication')) {
    // Add Authentication if not already included
    features = [...features];
    context.logger.info('Adding default feature: Authentication');
  }

  // Log project details
  context.logger.info('Generating project: $projectName');
  context.logger.info('Architecture: $architecture');
  context.logger.info('State Management: $stateManagement');
  context.logger.info('Features: $features');
  context.logger.info('Modules: $modules');

  context.vars['application_id_android'] =
      _appId(context, platform: Platform.android);
  context.vars['application_id_ios'] = _appId(context, platform: Platform.ios);

  // Create project structure
  createProjectStructure(context, projectName);

  // Generate app widget based on selected features
  generateAppWidget(
      context, projectName, architecture, stateManagement, features, modules);

  // Create architecture-specific structure
  createArchitectureStructure(context, projectName, architecture);

  // Create feature structures based on architecture and state management
  createFeatureStructures(
      context, projectName, features, architecture, stateManagement);

  // Configure pubspec.yaml based on project requirements

  configurePubspec(context, projectName, organizationName, architecture,
      stateManagement, features, modules);

  // Setup state management observability
  setupObservability(context, projectName, stateManagement);

  // Setup theme system if Theme Manager is selected
  generateThemeSystem(context, projectName, modules);

  // Setup network module if Network Module is selected
  generateNetworkLayerService(context, projectName, modules);

  // Redux specific setup
  generateReduxFiles(context, projectName, stateManagement);

  generateFlutterBunnyScreen(context, projectName, stateManagement, modules);

  // Create module structures
  // createModuleStructures(context, projectName, modules, architecture);

  // Generate main.dart file based on architecture, state management, features, and modules
  generateMainDart(context, projectName, organizationName, architecture,
      stateManagement, features, modules);

  // Setup push notification system if Notifications is selected
  generatePushNotificationSystem(context, projectName, modules);

  // Generate error handling system
  generateErrorHandling(context, projectName, architecture);

  // Generate localization system if selected
  generateLocalizationSystem(context, projectName, modules, stateManagement);

  context.logger.success('Project structure created successfully!');
}

// Main method required for kernel compilation
void main(List<String> args) {
  // This is a placeholder main method
  print('Mason pre-generation hook');
}

enum Platform {
  android,
  ios,
}

String _appId(HookContext context, {Platform? platform}) {
  final applicationId = context.vars['bundle_identifier'] as String?;
  if (applicationId == null) {
    return '';
  }
  // Convert to a valid Android application ID
  if (platform == Platform.android) {
    return applicationId.replaceAll('_', '').toLowerCase();
  }

  // Convert to a valid iOS application ID
  if (platform == Platform.ios) {
    return applicationId.replaceAll('_', '').toLowerCase();
  }

  return applicationId;
}

void createProjectStructure(HookContext context, String projectName) {
  final directories = [
    'lib',
    'test',
    'assets',
    'assets/images',
    'assets/icons',
    'assets/fonts',
    'assets/json',
  ];

  for (final dir in directories) {
    final directory = Directory('$projectName/$dir');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      context.logger.info('Created directory: $dir');
    }
  }
}

void createModuleStructures(HookContext context, String projectName,
    List<dynamic> modules, String architecture) {
  for (final module in modules) {
    final moduleName = module.toString().toLowerCase().replaceAll(' ', '_');
    String baseDir;

    switch (architecture) {
      case 'Clean Architecture':
        baseDir = 'core';
        break;
      case 'MVVM':
        baseDir = 'core';
      case 'MVC':
        baseDir = 'core';
        break;
      case 'Feature-Driven':
        baseDir = 'shared/services';
        break;
      default:
        baseDir = 'core';
    }

    final directory = Directory('$projectName/lib/$baseDir/$moduleName');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      context.logger.info('Created module directory: lib/$baseDir/$moduleName');
    }
  }
}
