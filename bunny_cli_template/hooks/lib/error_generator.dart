import 'dart:io';
import 'package:mason/mason.dart';

/// Generates error handling classes for exceptions and failures
void generateErrorHandling(
    HookContext context, String projectName, String architecture) {
  context.logger.info('Generating error handling system for $projectName');

  // Create directory structure
  final directories = [
    'lib/core/error',
    'lib/core/error/exceptions',
    'lib/core/error/failures',
  ];

  for (final dir in directories) {
    final directory = Directory('$projectName/$dir');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      context.logger.info('Created directory: $dir');
    }
  }

  // Generate error files
  _generateBaseExceptionFile(context, projectName);
  _generateFailureFile(context, projectName);
  _generateErrorMapperFile(context, projectName);

  // Generate additional architecture-specific files if needed
  if (architecture == 'Clean Architecture') {
    _generateEitherExtensionsFile(context, projectName);
  }

  context.logger.success('Error handling system generated successfully!');
}

/// Generates the base exception file
void _generateBaseExceptionFile(HookContext context, String projectName) {
  final filePath =
      '$projectName/lib/core/error/exceptions/error_exception.dart';
  final content = '''
import 'package:equatable/equatable.dart';

/// Base exception class for application errors
class ErrorException extends Equatable implements Exception {
  final String? message;
  
  const ErrorException({required this.message});
  
  @override
  List<Object?> get props => [message];
}

/// Authentication related exception
class AuthException extends ErrorException {
  const AuthException([String? message]) : super(message: message ?? 'Authentication error occurred');
}

/// Server related exception
class ServerException extends ErrorException {
  const ServerException([String? message]) : super(message: message ?? 'Server error occurred');
}

/// Unauthorized access exception
class UnauthorizedException extends ErrorException {
  const UnauthorizedException([String? message]) : super(message: message ?? 'Unauthorized access');
}

/// Resource not found exception
class NotFoundException extends ErrorException {
  const NotFoundException([String? message]) : super(message: message ?? 'Resource not found');
}

/// Conflict exception for duplicate resources
class ConflictException extends ErrorException {
  const ConflictException([String? message]) : super(message: message ?? 'Conflict occurred');
}

/// Internal server error exception
class InternalServerErrorException extends ErrorException {
  const InternalServerErrorException([String? message]) : super(message: message ?? 'Internal server error occurred');
}

/// No internet connection exception
class NoInternetConnectionException extends ErrorException {
  const NoInternetConnectionException([String? message]) : super(message: message ?? 'No internet connection');
}

/// Cache related exception
class CacheException extends ErrorException {
  const CacheException([String? message]) : super(message: message ?? 'Cache error occurred');
}

/// Format exception for data parsing errors
class FormatErrorException extends ErrorException {
  const FormatErrorException([String? message]) : super(message: message ?? 'Format error occurred');
}

/// Validation exception for input validation errors
class ValidationException extends ErrorException {
  final Map<String, String>? fieldErrors;
  
  const ValidationException({
    String? message,
    this.fieldErrors,
  }) : super(message: message ?? 'Validation error occurred');
  
  @override
  List<Object?> get props => [message, fieldErrors];
}

/// Timeout exception for request timeouts
class TimeoutException extends ErrorException {
  const TimeoutException([String? message]) : super(message: message ?? 'Request timeout');
}

/// Cancellation exception for cancelled requests
class CancellationException extends ErrorException {
  const CancellationException([String? message]) : super(message: message ?? 'Request cancelled');
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the failure file
void _generateFailureFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/error/failures/failure.dart';
  final content = '''
import 'package:equatable/equatable.dart';

/// Base failure class for domain layer
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});
  
  @override
  List<Object> get props => [message];
}

/// Server-related failure
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

/// Cache-related failure
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Network-related failure
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

/// Validation-related failure
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;
  
  const ValidationFailure({
    required super.message,
    this.fieldErrors,
  });
  
  @override
  List<Object> get props => [message, if (fieldErrors != null) fieldErrors!];
}

/// Authentication-related failure
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// Resource not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

/// Permission-related failure
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message});
}

/// Timeout-related failure
class TimeoutFailure extends Failure {
  const TimeoutFailure({required super.message});
}

/// Unexpected error failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message});
}

/// Input data-related failure
class InputFailure extends Failure {
  const InputFailure({required super.message});
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the error mapper file
void _generateErrorMapperFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/error/error_mapper.dart';
  final content = '''
import 'exceptions/error_exception.dart';
import 'failures/failure.dart';

/// Maps exceptions to failures for use in repositories
class ErrorMapper {
  /// Maps an exception to the appropriate failure
  static Failure mapExceptionToFailure(Exception exception) {
    if (exception is ErrorException) {
      return _mapErrorExceptionToFailure(exception);
    }
    
    return UnexpectedFailure(
      message: exception.toString(),
    );
  }
  
  /// Maps an ErrorException to the appropriate failure
  static Failure _mapErrorExceptionToFailure(ErrorException exception) {
    final message = exception.message ?? 'An error occurred';
    
    if (exception is ServerException) {
      return ServerFailure(message: message);
    } else if (exception is CacheException) {
      return CacheFailure(message: message);
    } else if (exception is NoInternetConnectionException) {
      return NetworkFailure(message: message);
    } else if (exception is AuthException || exception is UnauthorizedException) {
      return AuthFailure(message: message);
    } else if (exception is ValidationException) {
      return ValidationFailure(
        message: message,
        fieldErrors: (exception as ValidationException).fieldErrors,
      );
    } else if (exception is NotFoundException) {
      return NotFoundFailure(message: message);
    } else if (exception is TimeoutException) {
      return TimeoutFailure(message: message);
    }
    
    return UnexpectedFailure(message: message);
  }
  
  /// Gets a user-friendly error message from a failure
  static String getErrorMessage(Failure failure) {
    return failure.message;
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the either extensions file for Clean Architecture
void _generateEitherExtensionsFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/error/either_extensions.dart';
  final content = '''
import 'package:dartz/dartz.dart';

import 'error_mapper.dart';
import 'failures/failure.dart';

/// Extension methods for Either type
extension EitherExtensions<L, R> on Either<L, R> {
  /// Maps the right value using the given mapper function
  Either<L, T> mapRight<T>(T Function(R right) mapper) {
    return fold(
      (left) => Left(left),
      (right) => Right(mapper(right)),
    );
  }
  
  /// Gets the right value or null if it's a Left
  R? getOrNull() {
    return fold(
      (_) => null,
      (right) => right,
    );
  }
  
  /// Gets the right value or throws an exception if it's a Left
  R getOrThrow() {
    return fold(
      (left) => throw Exception('Left value encountered: \$left'),
      (right) => right,
    );
  }
  
  /// Gets the right value or a default value if it's a Left
  R getOrDefault(R defaultValue) {
    return fold(
      (_) => defaultValue,
      (right) => right,
    );
  }
  
  /// Returns whether this is a Right containing the given value
  bool contains(R value) {
    return fold(
      (_) => false,
      (right) => right == value,
    );
  }
}

/// Extension methods for Future<Either> type
extension FutureEitherExtensions<L, R> on Future<Either<L, R>> {
  /// Maps the right value using the given mapper function
  Future<Either<L, T>> mapRight<T>(T Function(R right) mapper) async {
    final either = await this;
    return either.mapRight(mapper);
  }
  
  /// Maps a Future<Either<Failure, T>> to a Future<T> by handling the failure
  Future<T> handleFailure({
    Function(Failure)? onFailure,
    required T Function() onFailureReturn,
  }) async {
    final result = await this;
    return result.fold(
      (failure) {
        if (onFailure != null) {
          onFailure(failure as Failure);
        }
        return onFailureReturn();
      },
      (success) => success,
    );
  }
  
  /// Executes different callbacks based on Either result
  Future<void> handle({
    required Function(R) onSuccess,
    Function(L)? onFailure,
  }) async {
    final either = await this;
    return either.fold(
      (left) => onFailure?.call(left),
      (right) => onSuccess(right),
    );
  }
}

/// Utility functions for working with Either in repositories
class EitherHandler {
  /// Safely executes a function that might throw exceptions
  /// and returns an Either with the result or a Failure
  static Future<Either<Failure, T>> execute<T>(
    Future<T> Function() function,
  ) async {
    try {
      final result = await function();
      return Right(result);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(
        message: e.toString(),
      ));
    }
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates example usage file with clean architecture repository pattern
void _generateExampleUsageFile(HookContext context, String projectName) {
  final directory = Directory('$projectName/lib/core/error/examples');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  final filePath =
      '$projectName/lib/core/error/examples/example_repository.dart';
  final content = '''
import 'package:dartz/dartz.dart';

import '../either_extensions.dart';
import '../error_mapper.dart';
import '../exceptions/error_exception.dart';
import '../failures/failure.dart';

/// Example entity
class User {
  final int id;
  final String name;
  
  User({required this.id, required this.name});
}

/// Example repository interface
abstract class UserRepository {
  Future<Either<Failure, User>> getUser(int id);
  Future<Either<Failure, List<User>>> getUsers();
  Future<Either<Failure, void>> createUser(User user);
}

/// Example data source
abstract class UserDataSource {
  Future<User> getUser(int id);
  Future<List<User>> getUsers();
  Future<void> createUser(User user);
}

/// Example repository implementation 
class UserRepositoryImpl implements UserRepository {
  final UserDataSource dataSource;
  
  UserRepositoryImpl(this.dataSource);
  
  @override
  Future<Either<Failure, User>> getUser(int id) async {
    return EitherHandler.execute(() async {
      try {
        final user = await dataSource.getUser(id);
        return user;
      } on ServerException catch (e) {
        throw e;
      } catch (e) {
        throw ServerException('Failed to get user: \$e');
      }
    });
  }
  
  @override
  Future<Either<Failure, List<User>>> getUsers() async {
    try {
      final users = await dataSource.getUsers();
      return Right(users);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> createUser(User user) async {
    // Alternative implementation showing try/catch pattern
    try {
      await dataSource.createUser(user);
      return const Right(null);
    } on NetworkFailure catch (e) {
      return Left(NetworkFailure(message: 'Network error: \${e.message}'));
    } on Exception catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}

/// Example usage in a use case or service
class GetUserUseCase {
  final UserRepository repository;
  
  GetUserUseCase(this.repository);
  
  Future<Either<Failure, User>> execute(int id) {
    return repository.getUser(id);
  }
}

/// Example of how to use the UseCase in a controller or ViewModel
void exampleUsage() async {
  // This is just example code to demonstrate usage
  final repository = UserRepositoryImpl(FakeUserDataSource());
  final useCase = GetUserUseCase(repository);
  
  // Using handle extension
  await useCase.execute(1).handle(
    onSuccess: (user) {
      print('User found: \${user.name}');
    },
    onFailure: (failure) {
      print('Error: \${failure.message}');
    },
  );
  
  // Using fold directly
  final result = await useCase.execute(1);
  result.fold(
    (failure) {
      print('Error: \${failure.message}');
    },
    (user) {
      print('User found: \${user.name}');
    },
  );
  
  // Using getOrNull extension
  final user = (await useCase.execute(1)).getOrNull();
  if (user != null) {
    print('User found: \${user.name}');
  }
  
  // Using mapRight extension
  final userNameEither = await useCase.execute(1).mapRight((user) => user.name);
  userNameEither.fold(
    (failure) {
      print('Error: \${failure.message}');
    },
    (userName) {
      print('User name: \$userName');
    },
  );
}

/// Fake implementation for example
class FakeUserDataSource implements UserDataSource {
  @override
  Future<void> createUser(User user) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
    // Example: throw NetworkException('No internet connection');
  }
  
  @override
  Future<User> getUser(int id) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
    if (id < 0) {
      throw ValidationException(message: 'Invalid user ID');
    }
    if (id > 10) {
      throw NotFoundException('User not found');
    }
    return User(id: id, name: 'User \$id');
  }
  
  @override
  Future<List<User>> getUsers() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
    return List.generate(5, (index) => User(id: index, name: 'User \$index'));
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates a README file with error handling usage instructions
void _generateErrorHandlingReadmeFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/error/README.md';
  final content = '''
# Error Handling System

This module provides a comprehensive error handling system for your application, separating exceptions and failures for clean architecture.

## Features

- 🚫 Clear distinction between exceptions and failures
- 🔄 Easy mapping between exceptions and failures
- 🧩 Extension methods for Either type (with Clean Architecture)
- 📝 Detailed error messages
- 🔍 Validation error handling with field-specific errors

## Usage

### Exceptions

Exceptions are used in the data layer and should be thrown when something goes wrong:

```dart
try {
  // Some operation that might fail
  final response = await apiClient.getUser(id);
  
  if (response.statusCode == 404) {
    throw NotFoundException('User not found');
  }
  
  return User.fromJson(response.data);
} on DioException catch (e) {
  throw ServerException('Server error: ${'e.message'}');
} catch (e) {
  throw ServerException('Unexpected error: ${'e'}');
}
```

### Failures

Failures are used in the domain and presentation layers to represent errors:

```dart
// In a repository
Future<Either<Failure, User>> getUser(int id) async {
  try {
    final user = await dataSource.getUser(id);
    return Right(user);
  } on Exception catch (e) {
    return Left(ErrorMapper.mapExceptionToFailure(e));
  }
}
```

### Using Either with Clean Architecture

With Clean Architecture, we use the `Either` type from the `dartz` package to represent operations that can either succeed or fail:

```dart
// In a use case or service
Future<Either<Failure, User>> getUser(int id) {
  return userRepository.getUser(id);
}

// In a controller or ViewModel
final result = await getUserUseCase(id);
result.fold(
  (failure) => _showError(failure.message),
  (user) => _showUser(user),
);
```

### Using Extension Methods

We provide several extension methods to make working with `Either` easier:

```dart
// Map the success value
final userNameEither = await useCase.execute(1).mapRight((user) => user.name);

// Get the value or null
final user = (await useCase.execute(1)).getOrNull();

// Handle success and failure
await useCase.execute(1).handle(
  onSuccess: (user) {
    // Handle success
  },
  onFailure: (failure) {
    // Handle failure
  },
);
```

### Using EitherHandler

`EitherHandler` provides a convenient way to execute functions that might throw exceptions:

```dart
Future<Either<Failure, User>> getUser(int id) {
  return EitherHandler.execute(() async {
    return await dataSource.getUser(id);
  });
}
```

## Validation Errors

For validation errors, you can include field-specific errors:

```dart
throw ValidationException(
  message: 'Validation failed',
  fieldErrors: {
    'email': 'Invalid email format',
    'password': 'Password must be at least 8 characters',
  },
);
```

In the UI, you can then display field-specific errors:

```dart
result.fold(
  (failure) {
    if (failure is ValidationFailure && failure.fieldErrors != null) {
      // Handle field errors
      failure.fieldErrors!.forEach((field, error) {
        // Show error for specific field
      });
    } else {
      // Show general error
      _showError(failure.message);
    }
  },
  (success) => _handleSuccess(success),
);
```

## Error Types

### Exceptions

- `ErrorException`: Base exception class
- `ServerException`: For server-related errors
- `AuthException`: For authentication errors
- `UnauthorizedException`: For unauthorized access
- `NotFoundException`: For resource not found errors
- `ConflictException`: For conflicts (e.g., duplicate resources)
- `InternalServerErrorException`: For internal server errors
- `NoInternetConnectionException`: For network connectivity issues
- `CacheException`: For local storage errors
- `ValidationException`: For validation errors
- `TimeoutException`: For request timeouts
- `CancellationException`: For cancelled requests

### Failures

- `Failure`: Base failure class
- `ServerFailure`: For server-related errors
- `AuthFailure`: For authentication errors
- `NetworkFailure`: For network connectivity issues
- `CacheFailure`: For local storage errors
- `ValidationFailure`: For validation errors
- `NotFoundFailure`: For resource not found errors
- `PermissionFailure`: For permission issues
- `TimeoutFailure`: For timeouts
- `UnexpectedFailure`: For unexpected errors
- `InputFailure`: For user input errors
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Add needed dependencies for error handling to pubspec.yaml
void updatePubspecForErrorHandling(
    HookContext context, String projectName, String architecture) {
  final pubspecFile = File('$projectName/pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    context.logger.warn(
        'pubspec.yaml not found, skipping adding error handling dependencies');
    return;
  }

  String content = pubspecFile.readAsStringSync();

  // Check if equatable is already added
  if (!content.contains('equatable:')) {
    // Find the end of the dependencies section
    final dependenciesMatch =
        RegExp(r'dependencies:\s*\n((\s{2}[\w_]+:.*\n)+)').firstMatch(content);

    if (dependenciesMatch != null) {
      final endOfDependencies = dependenciesMatch.end;

      // Dependencies to add
      String errorDependencies = '''

  # Error handling dependencies
  equatable: ^2.0.5
''';

      // Add dartz if it's Clean Architecture and not already present
      if (architecture == 'Clean Architecture' && !content.contains('dartz:')) {
        errorDependencies += '''
  dartz: ^0.10.1
''';
      }

      // Insert dependencies
      content = content.substring(0, endOfDependencies) +
          errorDependencies +
          content.substring(endOfDependencies);

      // Write updated content back to file
      pubspecFile.writeAsStringSync(content);
      context.logger
          .success('Added error handling dependencies to pubspec.yaml');
    } else {
      context.logger
          .warn('Could not find dependencies section in pubspec.yaml');
    }
  } else {
    context.logger
        .info('Error handling dependencies already exist in pubspec.yaml');
  }
}

/// Generate all error handling components
void generateCompleteErrorHandling(
    HookContext context, String projectName, String architecture) {
  // Generate base components
  _generateBaseExceptionFile(context, projectName);
  _generateFailureFile(context, projectName);
  _generateErrorMapperFile(context, projectName);

  // Generate clean architecture specific components if needed
  if (architecture == 'Clean Architecture') {
    _generateEitherExtensionsFile(context, projectName);
    _generateExampleUsageFile(context, projectName);
  }

  // Generate README
  _generateErrorHandlingReadmeFile(context, projectName);

  // Update pubspec.yaml
  updatePubspecForErrorHandling(context, projectName, architecture);
}
