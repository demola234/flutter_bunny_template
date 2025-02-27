import 'dart:io';
import 'package:mason/mason.dart';

void run(HookContext context) {
  // Validate project name
  final projectName = context.vars['project_name'] as String;
  final architecture = context.vars['architecture'] as String;
  final stateManagement = context.vars['state_management'] as String;
  final features = context.vars['features'] as List<dynamic>;
  final modules = context.vars['modules'] as List<dynamic>;

  // Validate project name
  if (!_isValidProjectName(projectName)) {
    throw ArgumentError(
      'Invalid project name. Must start with a letter or underscore, '
      'contain only lowercase letters, numbers, and underscores.'
    );
  }

  // Log project details
  context.logger.info('Generating project: $projectName');
  context.logger.info('Architecture: $architecture');
  context.logger.info('State Management: $stateManagement');
  context.logger.info('Features: $features');
  context.logger.info('Modules: $modules');

  // Create project structure
  _createProjectStructure(context, projectName);
  _createArchitectureStructure(context, projectName, architecture);
  _createFeatureStructures(context, projectName, features, architecture);
  _createModuleStructures(context, projectName, modules, architecture);

  context.logger.success('Project structure created successfully!');
}

// Main method required for kernel compilation
void main(List<String> args) {
  // This is a placeholder main method
  print('Mason pre-generation hook');
}

bool _isValidProjectName(String name) {
  final projectNameRegex = RegExp(r'^[a-z_][a-z0-9_]*$');
  return projectNameRegex.hasMatch(name);
}

void _createProjectStructure(HookContext context, String projectName) {
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

void _createArchitectureStructure(
  HookContext context, 
  String projectName, 
  String architecture
) {
  List<String> directories = [];

  switch (architecture) {
    case 'Clean Architecture':
      directories = [
        'lib/core',
        'lib/domain/entities',
        'lib/domain/repositories',
        'lib/domain/usecases',
        'lib/data/models',
        'lib/data/repositories',
        'lib/data/datasources',
        'lib/presentation/pages',
        'lib/presentation/widgets',
        'lib/presentation/bloc',
        'lib/di'
      ];
      break;
    case 'MVVM':
      directories = [
        'lib/models',
        'lib/views',
        'lib/viewmodels',
        'lib/services',
        'lib/utils'
      ];
      break;
    case 'MVC':
      directories = [
        'lib/models',
        'lib/views',
        'lib/controllers',
        'lib/utils'
      ];
      break;
    case 'Feature-Driven':
      directories = [
        'lib/features',
        'lib/shared/widgets',
        'lib/shared/services',
        'lib/core'
      ];
      break;
    default:
      context.logger.warn('Unknown architecture: $architecture');
      return;
  }

  for (final dir in directories) {
    final directory = Directory('$projectName/$dir');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      context.logger.info('Created architecture directory: $dir');
    }
  }
}

void _createFeatureStructures(
  HookContext context, 
  String projectName, 
  List<dynamic> features,
  String architecture
) {
  for (final feature in features) {
    final featureName = feature.toString().toLowerCase().replaceAll(' ', '_');
    List<String> directories = [];

    switch (architecture) {
      case 'Clean Architecture':
        directories = [
          'lib/domain/entities/$featureName',
          'lib/domain/repositories/$featureName',
          'lib/domain/usecases/$featureName',
          'lib/data/models/$featureName',
          'lib/data/repositories/$featureName',
          'lib/data/datasources/$featureName',
          'lib/presentation/pages/$featureName',
          'lib/presentation/widgets/$featureName',
          'lib/presentation/bloc/$featureName',
        ];
        break;
      case 'MVVM':
        directories = [
          'lib/models/$featureName',
          'lib/views/$featureName',
          'lib/viewmodels/$featureName',
        ];
        break;
      case 'MVC':
        directories = [
          'lib/models/$featureName',
          'lib/views/$featureName',
          'lib/controllers/$featureName',
        ];
        break;
      case 'Feature-Driven':
        directories = [
          'lib/features/$featureName/data',
          'lib/features/$featureName/domain',
          'lib/features/$featureName/presentation',
          'lib/features/$featureName/presentation/widgets',
        ];
        break;
      default:
        context.logger.warn('Unknown architecture for feature: $architecture');
        continue;
    }

    for (final dir in directories) {
      final directory = Directory('$projectName/$dir');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
        context.logger.info('Created feature directory: $dir');
      }
    }
  }
}

void _createModuleStructures(
  HookContext context, 
  String projectName, 
  List<dynamic> modules,
  String architecture
) {
  for (final module in modules) {
    final moduleName = module.toString().toLowerCase().replaceAll(' ', '_');
    String baseDir;

    switch (architecture) {
      case 'Clean Architecture':
        baseDir = 'core';
        break;
      case 'MVVM':
      case 'MVC':
        baseDir = 'services';
        break;
      case 'Feature-Driven':
        baseDir = 'shared/services';
        break;
      default:
        baseDir = 'services';
    }

    final directory = Directory('$projectName/lib/$baseDir/$moduleName');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      context.logger.info('Created module directory: lib/$baseDir/$moduleName');
    }
  }
}