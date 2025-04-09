import 'dart:io';

import 'package:mason/mason.dart';

/// Generates a push notification system with Firebase Cloud Messaging
/// if the Notifications module is selected
void generatePushNotificationSystem(
    HookContext context, String projectName, List<dynamic> modules) {
  // Check if Notifications is in the selected modules
  if (!modules.contains('Push Notification')) {
    context.logger.info(
        'Notifications module not selected, skipping push notification system generation');
    return;
  }

  context.logger.info('Generating push notification system for $projectName');

  // Create directory structure
  final directories = [
    'lib/core/notifications',
    'lib/core/notifications/services',
    'lib/core/notifications/models',
  ];

  for (final dir in directories) {
    final directory = Directory('$projectName/$dir');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      context.logger.info('Created directory: $dir');
    }
  }

  // Generate iOS Info.plist with notification permissions
  // generateInfoPlistFile(context, projectName);

  // Update iOS and Android platform configurations
  _configureNotificationsForPlatforms(context, projectName);

  // Generate notification files
  _generateFcmServiceFile(context, projectName);
  _generateNotificationHandlerFile(context, projectName);
  _generateNotificationModelFile(context, projectName);
  _generateLocalNotificationServiceFile(context, projectName);

  // Update pubspec.yaml to add Firebase dependencies
  _addFirebaseDependencies(context, projectName);

  // Update main.dart to initialize Firebase and FCM
  _updateMainForNotifications(context, projectName);

  // Create a sample notification screen
  _generateNotificationScreenFile(context, projectName);

  context.logger.success('Push notification system generated successfully!');
}

/// Generates the FCM service file
void _generateFcmServiceFile(HookContext context, String projectName) {
  final filePath =
      '$projectName/lib/core/notifications/services/fcm_service.dart';
  final content = '''
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

import '../models/push_notification_model.dart';
import 'local_notification_service.dart';


/// Service to handle Firebase Cloud Messaging (FCM) operations
class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LocalNotificationService _localNotificationService;
  final List<Function(PushNotificationModel)> _onNotificationReceivedListeners =
      [];

  FCMService(this._localNotificationService);

  /// Initialize FCM service
  /// Initialize FCM service with improved error handling
  Future<void> initialize() async {
    await _requestPermissions();
    await _setupForegroundNotifications();
    await _setupBackgroundAndTerminatedNotifications();
    await _setupOnMessageOpenedApp();

    try {
      // Get FCM token with error handling
      String? token = await getToken();
      if (token != null) {
        debugPrint('FCM Token: \$'token'');
      } else {
        debugPrint('Failed to get FCM token - notifications may be limited');
      }
    } catch (e) {
      debugPrint('Error during FCM initialization: \$e');
      // Continue execution even if token retrieval fails
    }

    // Listen for token refreshes
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token refreshed: \$newToken');
      // TODO: Send this token to your server
    });
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('FCM permission status: \${settings.authorizationStatus}');
  }

  /// Setup handling of foreground notifications
  Future<void> _setupForegroundNotifications() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: \${message.data}');

      if (message.notification != null) {
        debugPrint(
            'Message also contained a notification: \${message.notification}');

        final notification = PushNotificationModel(
          title: message.notification?.title ?? 'New Notification',
          body: message.notification?.body ?? '',
          payload: json.encode(message.data),
        );

        // Show local notification
        _localNotificationService.showNotification(notification);

        // Notify listeners
        _notifyListeners(notification);
      }
    });
  }

  /// Setup handling of background and terminated notifications
  Future<void> _setupBackgroundAndTerminatedNotifications() async {
    // Check if app was opened from a terminated state
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  /// Setup handling of notifications when app is opened
  Future<void> _setupOnMessageOpenedApp() async {
    // Handle when the app is opened from a background state
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  /// Handle received message
  void _handleMessage(RemoteMessage message) {
    debugPrint('Handling FCM message: \${message.messageId}');

    if (message.notification != null) {
      final notification = PushNotificationModel(
        title: message.notification?.title ?? 'New Notification',
        body: message.notification?.body ?? '',
        payload: json.encode(message.data),
      );

      // Notify listeners
      _notifyListeners(notification);

      // TODO: Navigate to specific screen based on data if needed
      // Example:
      // if (message.data.containsKey('type')) {
      //   if (message.data['type'] == 'chat') {
      //     // Navigate to chat screen
      //   }
      // }
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  /// Get the FCM token
  /// Get the FCM token with improved iOS support
  Future<String?> getToken() async {
    try {
      if (Platform.isIOS) {
        // For iOS, first check APNS token explicitly
        final apnsToken = await _firebaseMessaging.getAPNSToken();

        if (apnsToken == null) {
          debugPrint('APNS token is null, iOS push notifications may not work');

          // iOS simulator doesn't support push notifications
          if (Platform.isIOS && !await _isPhysicalDevice()) {
            debugPrint(
                'Running on iOS simulator - push notifications are not fully supported');
            return 'simulator-token-not-available';
          }

          // On physical devices, wait a bit and try again
          await Future.delayed(const Duration(seconds: 1));
          final retryApnsToken = await _firebaseMessaging.getAPNSToken();

          if (retryApnsToken == null) {
            debugPrint('APNS token still null after retry');
            return null;
          }
        }
      }

      // Now try to get FCM token
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: \$e');
      return null;
    }
  }

  /// Check if the app is running on a physical device
  Future<bool> _isPhysicalDevice() async {
    try {
      // This is a simplified check - in production, use a package like 'device_info_plus'
      // to more accurately determine if the device is physical
      return !bool.fromEnvironment('dart.vm.product');
    } catch (e) {
      return false;
    }
  }


  /// Check if the app is running on a physical device
  Future<bool> _isPhysicalDevice() async {
    try {
      // This is a simplified check - in production, use a package like 'device_info_plus'
      // to more accurately determine if the device is physical
      return !bool.fromEnvironment('dart.vm.product');
    } catch (e) {
      return false;
    }
  }

  /// Add a notification received listener
  void addOnNotificationReceivedListener(
      Function(PushNotificationModel) listener) {
    _onNotificationReceivedListeners.add(listener);
  }

  /// Remove a notification received listener
  void removeOnNotificationReceivedListener(
      Function(PushNotificationModel) listener) {
    _onNotificationReceivedListeners.remove(listener);
  }

  /// Notify listeners of a new notification
  void _notifyListeners(PushNotificationModel notification) {
    for (var listener in _onNotificationReceivedListeners) {
      listener(notification);
    }
  }
}

/// Firebase message handler for background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Need to initialize Firebase before using it
  await Firebase.initializeApp();

  debugPrint('Handling background message: \${message.messageId}');

  // Initialize FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Show notification if there is a notification payload
  if (message.notification != null) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: json.encode(message.data),
    );
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the notification handler file
void _generateNotificationHandlerFile(HookContext context, String projectName) {
  final filePath =
      '$projectName/lib/core/notifications/notification_handler.dart';
  final content = '''
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'models/push_notification_model.dart';
import 'services/fcm_service.dart';
import 'services/local_notification_service.dart';

/// Main class to handle all notification operations
class NotificationHandler {
  late final FCMService _fcmService;
  late final LocalNotificationService _localNotificationService;
  
  /// Initialize notification services
Future<bool> initialize() async {
    try {
      // Setup local notifications first
      _localNotificationService = LocalNotificationService();
      await _localNotificationService.initialize();

      // Setup FCM service
      _fcmService = FCMService(_localNotificationService);
      await _fcmService.initialize();

      // Register background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      return true;
    } catch (e) {
      debugPrint('Error initializing notification services: \$e');
      // Continue with app initialization even if notifications fail
      return false;
    }
  }

  /// Get FCM token with error handling
  Future<String?> getFCMToken() async {
    try {
      return await _fcmService.getToken();
    } catch (e) {
      debugPrint('Error in getFCMToken: \$e');
      return 'Error: \$e';
    }
  }
  
  /// Show a local notification
  Future<void> showLocalNotification(PushNotificationModel notification) async {
    await _localNotificationService.showNotification(notification);
  }
  
  /// Subscribe to a FCM topic
  Future<void> subscribeToTopic(String topic) async {
    await _fcmService.subscribeToTopic(topic);
  }
  
  /// Unsubscribe from a FCM topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcmService.unsubscribeFromTopic(topic);
  }
  
  /// Get FCM token
  Future<String?> getFCMToken() async {
    return await _fcmService.getToken();
  }
  
  /// Add listener for notification received
  void addOnNotificationReceivedListener(Function(PushNotificationModel) listener) {
    _fcmService.addOnNotificationReceivedListener(listener);
  }
  
  /// Remove listener for notification received
  void removeOnNotificationReceivedListener(Function(PushNotificationModel) listener) {
    _fcmService.removeOnNotificationReceivedListener(listener);
  }
  
  /// Add listener for notification tap
  void addOnNotificationTapListener(Function(String?) listener) {
    _localNotificationService.addOnNotificationTapListener(listener);
  }
  
  /// Remove listener for notification tap
  void removeOnNotificationTapListener(Function(String?) listener) {
    _localNotificationService.removeOnNotificationTapListener(listener);
  }
}

/// Global notification handler instance
final notificationHandler = NotificationHandler();
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the notification model file
void _generateNotificationModelFile(HookContext context, String projectName) {
  final filePath =
      '$projectName/lib/core/notifications/models/push_notification_model.dart';
  final content = '''
/// Model class for push notifications
class PushNotificationModel {
  final String title;
  final String body;
  final String? imageUrl;
  final String? payload;
  
  PushNotificationModel({
    required this.title,
    required this.body,
    this.imageUrl,
    this.payload,
  });
  
  factory PushNotificationModel.fromJson(Map<String, dynamic> json) {
    return PushNotificationModel(
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      imageUrl: json['imageUrl'],
      payload: json['payload'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'payload': payload,
    };
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the local notification service file
void _generateLocalNotificationServiceFile(
    HookContext context, String projectName) {
  final filePath =
      '$projectName/lib/core/notifications/services/local_notification_service.dart';
  final content = '''
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/push_notification_model.dart';

/// Service to handle local notifications using flutter_local_notifications plugin
class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<Function(String?)> _onNotificationTapListeners = [];

  /// Initialize local notification service
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  /// Show a notification
  Future<void> showNotification(PushNotificationModel notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: notification.payload,
    );
  }

  /// Handle notification response when tapped
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    final String? payload = response.payload;

    // Notify listeners
    for (var listener in _onNotificationTapListeners) {
      listener(payload);
    }
  }

  /// Add notification tap listener
  void addOnNotificationTapListener(Function(String?) listener) {
    _onNotificationTapListeners.add(listener);
  }

  /// Remove notification tap listener
  void removeOnNotificationTapListener(Function(String?) listener) {
    _onNotificationTapListeners.remove(listener);
  }

  /// Get pending notification requests
  Future<List<PendingNotificationRequest>>
      getPendingNotificationRequests() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}

''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates a notification screen
void _generateNotificationScreenFile(HookContext context, String projectName) {
  final filePath =
      '$projectName/lib/features/notifications/presentation/pages/notification_screen.dart';

  // Create directories if they don't exist
  final directory =
      Directory('$projectName/lib/features/notifications/presentation/pages');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  final content = '''
import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../../core/notifications/notification_handler.dart';
import '../../../../core/notifications/models/push_notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<PushNotificationModel> _notifications = [];
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _loadFCMToken();
    
    // Listen for new notifications
    notificationHandler.addOnNotificationReceivedListener(_onNotificationReceived);
    
    // Listen for notification taps
    notificationHandler.addOnNotificationTapListener(_onNotificationTap);
  }

  @override
  void dispose() {
    // Remove listeners when screen is disposed
    notificationHandler.removeOnNotificationReceivedListener(_onNotificationReceived);
    notificationHandler.removeOnNotificationTapListener(_onNotificationTap);
    super.dispose();
  }
  
  Future<void> _loadFCMToken() async {
    final token = await notificationHandler.getFCMToken();
    setState(() {
      _fcmToken = token;
    });
  }
  
  void _onNotificationReceived(PushNotificationModel notification) {
    setState(() {
      _notifications.add(notification);
    });
  }
  
  void _onNotificationTap(String? payload) {
    if (payload != null) {
      try {
        final data = json.decode(payload);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Notification Payload'),
            content: Text(json.encode(data)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } catch (e) {
        debugPrint('Error parsing payload: \$e');
      }
    }
  }
  
  Future<void> _showLocalNotification() async {
    final notification = PushNotificationModel(
      title: 'Test Notification',
      body: 'This is a test local notification from the app',
      payload: json.encode({'type': 'test', 'time': DateTime.now().toString()}),
    );
    
    await notificationHandler.showLocalNotification(notification);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Column(
        children: [
          // FCM Token display
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FCM Token:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _fcmToken ?? 'Loading token...',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                if (_fcmToken != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Copy to clipboard functionality would go here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Token copied to clipboard')),
                        );
                      },
                      child: const Text('Copy'),
                    ),
                  ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Notification list
          Expanded(
            child: _notifications.isEmpty
                ? const Center(
                    child: Text('No notifications yet'),
                  )
                : ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[_notifications.length - 1 - index];
                      return ListTile(
                        title: Text(notification.title),
                        subtitle: Text(notification.body),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          if (notification.payload != null) {
                            _onNotificationTap(notification.payload);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showLocalNotification,
        tooltip: 'Send test notification',
        child: const Icon(Icons.notification_add),
      ),
    );
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Updates pubspec.yaml to add Firebase dependencies
void _addFirebaseDependencies(HookContext context, String projectName) {
  final pubspecFile = File('$projectName/pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    context.logger
        .warn('pubspec.yaml not found, skipping adding Firebase dependencies');
    return;
  }

  String content = pubspecFile.readAsStringSync();
  bool modified = false;

  // Add dependencies that are missing
  List<String> missingDependencies = [];
  if (!content.contains('firebase_core:'))
    missingDependencies.add('firebase_core: ^3.10.0');
  if (!content.contains('firebase_messaging:'))
    missingDependencies.add('firebase_messaging: ^15.1.6');
  if (!content.contains('flutter_local_notifications:'))
    missingDependencies.add('flutter_local_notifications: ^18.0.0');

  if (missingDependencies.isNotEmpty) {
    // Find the position to insert the dependencies
    final sdkDepIndex = content.indexOf('sdk: flutter');
    if (sdkDepIndex != -1) {
      final insertPoint = content.indexOf('\n', sdkDepIndex) + 1;

      final firebaseDependencies =
          '\n  # Firebase dependencies for push notifications\n  ' +
              missingDependencies.join('\n  ') +
              '\n';

      content = content.substring(0, insertPoint) +
          firebaseDependencies +
          content.substring(insertPoint);

      modified = true;
    }
  }

  if (modified) {
    pubspecFile.writeAsStringSync(content);
    context.logger
        .success('Added missing Firebase dependencies to pubspec.yaml');
  } else {
    context.logger.info('Firebase dependencies already exist in pubspec.yaml');
  }
}

/// Updates Android and iOS configurations for push notifications
void _configureNotificationsForPlatforms(
    HookContext context, String projectName) {
  // Update iOS Info.plist
  _updateIOSInfoPlist(context, projectName);
  // Update Android manifest
  _updateAndroidManifest(context, projectName);

  // Update iOS AppDelegate
  _updateIOSAppDelegate(context, projectName);

  // Add NSUserTrackingUsageDescription to Info.plist (already handled in _generateInfoPlistFile)
  context.logger.success('Configured push notifications for both platforms');
}

void _updateIOSInfoPlist(HookContext context, String projectName) {
  final infoPlistPath = '$projectName/ios/Runner/Info.plist';
  final infoPlistFile = File(infoPlistPath);

  try {
    // Check if file exists
    if (!infoPlistFile.existsSync()) {
      context.logger.warn('Info.plist not found at $infoPlistPath');
      return;
    }

    String content = infoPlistFile.readAsStringSync();
    bool modified = false;

    // Add UIBackgroundModes if not already present
    if (!content.contains('<key>UIBackgroundModes</key>')) {
      // Find the position to insert - before the closing dict tag
      final insertPoint = content.lastIndexOf('</dict>');
      if (insertPoint != -1) {
        final backgroundModes = '''
  <key>UIBackgroundModes</key>
  <array>
    <string>fetch</string>
    <string>processing</string>
    <string>remote-notification</string>
  </array>
''';
        content = content.substring(0, insertPoint) +
            backgroundModes +
            content.substring(insertPoint);
        modified = true;
      }
    }

    //  Add FirebaseAppDelegateProxyEnabled if not already present
    if (!content.contains('<key>FirebaseAppDelegateProxyEnabled</key>')) {
      // Find the position to insert - before the closing dict tag
      final insertPoint = content.lastIndexOf('</dict>');
      if (insertPoint != -1) {
        final firebaseProxySetting = '''
  <key>FirebaseAppDelegateProxyEnabled</key>
  <false/>
''';
        content = content.substring(0, insertPoint) +
            firebaseProxySetting +
            content.substring(insertPoint);
        modified = true;
      }
    }

    // Add NSUserTrackingUsageDescription if not already present
    if (!content.contains('<key>NSUserTrackingUsageDescription</key>')) {
      // Find the position to insert - before the closing dict tag
      final insertPoint = content.lastIndexOf('</dict>');
      if (insertPoint != -1) {
        final userTrackingDescription = '''
  <key>NSUserTrackingUsageDescription</key>
  <string>This app uses push notifications to enhance user experience.</string>
''';
        content = content.substring(0, insertPoint) +
            userTrackingDescription +
            content.substring(insertPoint);
        modified = true;
      }
    }

    // Add FirebaseMessagingAutoInitEnabled if not already present
    if (!content.contains('<key>FirebaseMessagingAutoInitEnabled</key>')) {
      // Find the position to insert - before the closing dict tag
      final insertPoint = content.lastIndexOf('</dict>');
      if (insertPoint != -1) {
        final firebaseMessagingSetting = '''
  <key>FirebaseMessagingAutoInitEnabled</key>
  <false/>
''';
        content = content.substring(0, insertPoint) +
            firebaseMessagingSetting +
            content.substring(insertPoint);
        modified = true;
      }
    }

    // Write back only if modifications were made
    if (modified) {
      infoPlistFile.writeAsStringSync(content);
      context.logger
          .success('Updated Info.plist with required notification settings');
    } else {
      context.logger
          .info('Info.plist already has required notification settings');
    }
  } catch (e) {
    context.logger.err('Failed to update Info.plist: $e');
  }
}

void _updateAndroidManifest(HookContext context, String projectName) {
  final manifestPath = '$projectName/android/app/src/main/AndroidManifest.xml';
  final manifestFile = File(manifestPath);

  // Create parent directories if they don't exist
  final manifestDir = Directory('$projectName/android/app/src/main');
  if (!manifestDir.existsSync()) {
    manifestDir.createSync(recursive: true);
  }

  bool fileExists = manifestFile.existsSync();
  String manifestContent = fileExists
      ? manifestFile.readAsStringSync()
      : '''<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="@string/app_name"
        android:name="\${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- Activity and other elements will be here -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
''';

  bool modified = false;

  // Add notification permission if not already present
  if (!manifestContent.contains(
      '<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>')) {
    // Add permission
    if (manifestContent.contains('<manifest')) {
      final int manifestTagEnd =
          manifestContent.indexOf('>', manifestContent.indexOf('<manifest'));
      manifestContent = manifestContent.substring(0, manifestTagEnd + 1) +
          '\n    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>' +
          manifestContent.substring(manifestTagEnd + 1);
      modified = true;
    }
  }

  // Add receivers if needed
  if (!manifestContent.contains(
      'com.dexterous.flutterlocalnotifications.receivers.NotificationReceiver')) {
    final int applicationEndIndex =
        manifestContent.lastIndexOf('</application>');
    if (applicationEndIndex != -1) {
      final String receiversContent = '''
        <receiver android:name="com.dexterous.flutterlocalnotifications.receivers.NotificationReceiver" android:exported="true"/>
        <receiver android:name="com.dexterous.flutterlocalnotifications.receivers.ScheduledNotificationReceiver" android:exported="true"/>
        <receiver android:name="com.dexterous.flutterlocalnotifications.receivers.ActionReceiver" android:exported="true"/>
''';
      manifestContent = manifestContent.substring(0, applicationEndIndex) +
          receiversContent +
          manifestContent.substring(applicationEndIndex);
      modified = true;
    }
  }

  // Only write if content was modified or file didn't exist
  if (modified || !fileExists) {
    manifestFile.writeAsStringSync(manifestContent);
    if (!fileExists) {
      context.logger
          .info('Created AndroidManifest.xml with notification permissions');
    } else {
      context.logger
          .info('Updated AndroidManifest.xml with notification permissions');
    }
  } else {
    context.logger
        .info('AndroidManifest.xml already has notification permissions');
  }
}

/// Updates iOS AppDelegate.swift with required code for notifications
void _updateIOSAppDelegate(HookContext context, String projectName) {
  final appDelegatePath = '$projectName/ios/Runner/AppDelegate.swift';
  final appDelegateFile = File(appDelegatePath);

  try {
    // Create parent directories if they don't exist
    final appDelegateDir = Directory('$projectName/ios/Runner');
    if (!appDelegateDir.existsSync()) {
      appDelegateDir.createSync(recursive: true);
      context.logger.info('Created directory: ios/Runner');
    }

    // Define the notification-enabled AppDelegate content
    final appDelegateContent = '''import Flutter
import UIKit
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
''';

    // Check if file exists and handle appropriately
    if (appDelegateFile.existsSync()) {
      final existingContent = appDelegateFile.readAsStringSync();

      // Only overwrite if it doesn't already have notification code
      if (!existingContent.contains('flutter_local_notifications')) {
        appDelegateFile.writeAsStringSync(appDelegateContent);
        context.logger
            .info('Updated iOS AppDelegate.swift with notification support');
      } else {
        context.logger
            .info('iOS AppDelegate.swift already has notification support');
      }
    } else {
      appDelegateFile.writeAsStringSync(appDelegateContent);
      context.logger
          .info('Created iOS AppDelegate.swift with notification support');
    }
  } catch (e) {
    context.logger.err('Failed to update iOS AppDelegate.swift: $e');
  }
}

/// Updates main.dart to initialize Firebase and FCM
void _updateMainForNotifications(HookContext context, String projectName) {
  final mainDartFile = File('$projectName/lib/main.dart');
  if (!mainDartFile.existsSync()) {
    context.logger
        .warn('main.dart not found, skipping Firebase initialization');
    return;
  }

  String content = mainDartFile.readAsStringSync();
  bool modified = false;

  // Add imports if not already present
  if (!content.contains('firebase_core.dart')) {
    final importPattern = RegExp(r'import .*;\n');
    final lastImportMatch = importPattern.allMatches(content).lastOrNull;

    if (lastImportMatch != null) {
      final insertPosition = lastImportMatch.end;
      content = content.substring(0, insertPosition) +
          "import 'package:firebase_core/firebase_core.dart';\n" +
          "import 'package:$projectName/core/notifications/notification_handler.dart';\n" +
          content.substring(insertPosition);
      modified = true;
    }
  }

  // Add Firebase initialization if not already present
  if (!content.contains('Firebase.initializeApp')) {
    final mainFunction = content.indexOf('void main() async {');
    if (mainFunction != -1) {
      final insertPosition = content.indexOf('{', mainFunction) + 1;
      content = content.substring(0, insertPosition) +
          "\n  // Initialize Firebase\n" +
          "  await Firebase.initializeApp();\n\n" +
          "  // Initialize notification services\n" +
          "  await notificationHandler.initialize();\n" +
          content.substring(insertPosition);
      modified = true;
    }
  }

  // Only write if content was modified
  if (modified) {
    mainDartFile.writeAsStringSync(content);
    context.logger.success('Updated main.dart with Firebase initialization');
  } else {
    context.logger.info('main.dart already contains Firebase initialization');
  }
}
