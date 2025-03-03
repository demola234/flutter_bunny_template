import 'dart:io';

import 'package:flutter_bunny_cli/main_configurator.dart';
import 'package:flutter_bunny_cli/pubsec_configurator.dart';
import 'package:mason/mason.dart';

// Import helper files
import 'lib/architecture_handler.dart';
import 'lib/feature_generator.dart';
import 'lib/utils.dart';

void run(HookContext context) {
  // Validate project name
  final projectName = context.vars['project_name'] as String;
  final architecture = context.vars['architecture'] as String;
  final organizationName = context.vars['org_name'] as String;
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

  // Create project structure
  createProjectStructure(context, projectName);

  // Create architecture-specific structure
  createArchitectureStructure(context, projectName, architecture);

  // Create feature structures based on architecture and state management
  createFeatureStructures(
      context, projectName, features, architecture, stateManagement);

  // Configure pubspec.yaml based on project requirements

  configurePubspec(context, projectName, organizationName, architecture,
      stateManagement, features, modules);

  // Create module structures
  createModuleStructures(context, projectName, modules, architecture);

  // Generate main.dart file based on architecture, state management, features, and modules
  generateMainDart(context, projectName, organizationName, architecture,
      stateManagement, features, modules);

  context.logger.success('Project structure created successfully!');
}

// Main method required for kernel compilation
void main(List<String> args) {
  // This is a placeholder main method
  print('Mason pre-generation hook');
}

void createProjectStructure(HookContext context, String projectName) {
  final directories = [
    'lib',
    'test',
    'assets',
    'assets/images',
    'assets/fonts',
    'assets/translations',
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
      case 'MVC':
        baseDir = 'shared/services';
        break;
      case 'Feature-Driven':
        baseDir = 'shared/services';
        break;
      default:
        baseDir = 'shared/services';
    }

    final directory = Directory('$projectName/lib/$baseDir/$moduleName');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      context.logger.info('Created module directory: lib/$baseDir/$moduleName');

      // Create a base file for the module
      createFile(
          '$projectName/lib/$baseDir/$moduleName/${moduleName}_service.dart',
          generateServiceTemplate(moduleName),
          context);
    }
  }
}
