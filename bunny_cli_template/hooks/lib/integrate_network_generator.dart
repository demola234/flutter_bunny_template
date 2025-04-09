import 'dart:io';

import 'package:mason/mason.dart';

/// Integrate the network layer with the main run function and update pubspec.yaml
void integrateNetworkLayer(HookContext context, String projectName) {
  // Update the run function in main.dart to import and include the network layer
  final mainDartFile = File('$projectName/lib/main.dart');
  
  if (mainDartFile.existsSync()) {
    String content = mainDartFile.readAsStringSync();
    
    // Add imports if not already present
    if (!content.contains('connectivity_service.dart')) {
      final importPattern = RegExp(r'import .*;\n');
      final lastImportMatch = importPattern.allMatches(content).lastOrNull;
      
      if (lastImportMatch != null) {
        final insertPosition = lastImportMatch.end;
        content = content.substring(0, insertPosition) +
                "import 'package:$projectName/core/network/services/connectivity_service.dart';\n" +
                "import 'package:$projectName/core/network/network_info.dart';\n" +
                "import 'package:internet_connection_checker/internet_connection_checker.dart';\n" +
                content.substring(insertPosition);
      }
    }
    
    // Add network initialization if not already present
    if (!content.contains('ConnectivityService()')) {
      // Find a good position to insert the initialization
      final setupPosition = content.indexOf('void main() async {') + 'void main() async {'.length;
      
      if (setupPosition > 0) {
        // Insert network initialization
        content = content.substring(0, setupPosition) + 
              "\n  // Initialize network services\n" +
              "  final connectivityService = ConnectivityService();\n" +
              "  final networkInfo = NetworkInfoImpl(InternetConnectionChecker());\n\n" +
              content.substring(setupPosition);
      }
    }
    
    // Write updated content back to file
    mainDartFile.writeAsStringSync(content);
    context.logger.success('Updated main.dart with network layer initialization');
  }
}

/// Update pubspec.yaml to add network-related dependencies
void updatePubspecForNetwork(HookContext context, String projectName) {
  final pubspecFile = File('$projectName/pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    context.logger.warn('pubspec.yaml not found, skipping adding network dependencies');
    return;
  }

  String content = pubspecFile.readAsStringSync();
  
  // Check if the dependencies are already added
  if (!content.contains('dio:') || !content.contains('connectivity_plus:')) {
    // Find the end of the dependencies section
    final dependenciesMatch = RegExp(r'dependencies:\s*\n((\s{2}[\w_]+:.*\n)+)').firstMatch(content);
    
    if (dependenciesMatch != null) {
      final endOfDependencies = dependenciesMatch.end;
      
      // Network dependencies to add
      final networkDependencies = '''

  # Network dependencies
  dio: ^5.3.3
  connectivity_plus: ^6.0.0
  internet_connection_checker: ^3.0.1
''';
      
      // Insert dependencies
      content = content.substring(0, endOfDependencies) + 
               networkDependencies + 
               content.substring(endOfDependencies);
      
      // Write updated content back to file
      pubspecFile.writeAsStringSync(content);
      context.logger.success('Added network dependencies to pubspec.yaml');
    } else {
      context.logger.warn('Could not find dependencies section in pubspec.yaml');
    }
  } else {
    context.logger.info('Network dependencies already exist in pubspec.yaml');
  }
}

/// Create a sample model to demonstrate API usage with network layer
void createSampleModel(HookContext context, String projectName) {
  final directory = Directory('$projectName/lib/core/network/models');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }
  
  final filePath = '$projectName/lib/core/network/models/user_model.dart';
  final content = '''
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// Sample user model to demonstrate API integration
@JsonSerializable()
class UserModel {
  final int id;
  final String name;
  final String email;
  
  @JsonKey(name: 'profile_image')
  final String? profileImage;
  
  @JsonKey(defaultValue: false)
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _\$UserModelFromJson(json);
      
  Map<String, dynamic> toJson() => _\$UserModelToJson(this);
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  
  // Create the associated .g.dart file
  final generatedFilePath = '$projectName/lib/core/network/models/user_model.g.dart';
  final generatedContent = '''
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _\$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImage: json['profile_image'] as String?,
      isActive: json['isActive'] as bool? ?? false,
    );

Map<String, dynamic> _\$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'profile_image': instance.profileImage,
      'isActive': instance.isActive,
    };
''';

  final generatedFile = File(generatedFilePath);
  generatedFile.writeAsStringSync(generatedContent);
  
  context.logger.info('Created sample model files to demonstrate API usage');
}

/// Setup NetworkModule with dependency injection (example for GetIt if used)
void setupNetworkModuleForDI(HookContext context, String projectName, String architecture) {
  // Only proceed with this for Clean Architecture which likely uses dependency injection
  if (architecture != 'Clean Architecture') {
    return;
  }
  
  final directory = Directory('$projectName/lib/core/di');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }
  
  final filePath = '$projectName/lib/core/di/network_module.dart';
  final content = '''
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../network/network_info.dart';
import '../network/services/connectivity_service.dart';

/// Register network-related dependencies
void registerNetworkDependencies(GetIt sl) {
  // Core network components
  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker(),
  );
  
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<InternetConnectionChecker>()),
  );
  
  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(),
  );
  
  // API client
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: ApiConstants.baseUrl,
      timeout: ApiConstants.timeout,
      useAuth: true,
    ),
  );
  
  // Register individual API services
  // TODO: Add your API services here
  // Example:
  // sl.registerLazySingleton<UserApiService>(
  //   () => UserApiService(),
  // );
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  
  // Update the main DI file if it exists
  final diFilePath = '$projectName/lib/core/di/injection.dart';
  final diFile = File(diFilePath);
  
  if (diFile.existsSync()) {
    String diContent = diFile.readAsStringSync();
    
    // Add import if not present
    if (!diContent.contains('network_module.dart')) {
      final importPattern = RegExp(r'import .*;\n');
      final lastImportMatch = importPattern.allMatches(diContent).lastOrNull;
      
      if (lastImportMatch != null) {
        final insertPosition = lastImportMatch.end;
        diContent = diContent.substring(0, insertPosition) +
                 "import 'network_module.dart';\n" +
                 diContent.substring(insertPosition);
      }
    }
    
    // Add network registration function call if not present
    if (!diContent.contains('registerNetworkDependencies')) {
      final configPattern = RegExp(r'void configureDependencies\(\) async \{');
      final configMatch = configPattern.firstMatch(diContent);
      
      if (configMatch != null) {
        final insertPosition = configMatch.end;
        diContent = diContent.substring(0, insertPosition) +
                 "\n  // Register network dependencies\n" +
                 "  registerNetworkDependencies(sl);\n" +
                 diContent.substring(insertPosition);
      }
    }
    
    // Write updated content back to file
    diFile.writeAsStringSync(diContent);
  }
  
  context.logger.info('Created network module for dependency injection');
}
