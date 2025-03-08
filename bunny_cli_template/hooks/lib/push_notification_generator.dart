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

import '../models/push_notification_model.dart';
import 'local_notification_service.dart';

/// Service to handle Firebase Cloud Messaging (FCM) operations
class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LocalNotificationService _localNotificationService;
  final List<Function(PushNotificationModel)> _onNotificationReceivedListeners = [];
  
  FCMService(this._localNotificationService);
  
  /// Initialize FCM service
  Future<void> initialize() async {
    await _requestPermissions();
    await _setupForegroundNotifications();
    await _setupBackgroundAndTerminatedNotifications();
    await _setupOnMessageOpenedApp();
    
    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: \$token');
    
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
        debugPrint('Message also contained a notification: \${message.notification}');
        
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
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
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
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
  
  /// Add a notification received listener
  void addOnNotificationReceivedListener(Function(PushNotificationModel) listener) {
    _onNotificationReceivedListeners.add(listener);
  }
  
  /// Remove a notification received listener
  void removeOnNotificationReceivedListener(Function(PushNotificationModel) listener) {
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
  Future<void> initialize() async {
    // Setup local notifications first
    _localNotificationService = LocalNotificationService();
    await _localNotificationService.initialize();
    
    // Setup FCM service
    _fcmService = FCMService(_localNotificationService);
    await _fcmService.initialize();
    
    // Register background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
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
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          debugPrint('Received iOS local notification: \$id');
        },
      );
      
    final InitializationSettings initializationSettings = InitializationSettings(
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
    debugPrint('Notification tapped with payload: \$payload');
    
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
  Future<List<PendingNotificationRequest>> getPendingNotificationRequests() async {
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

  // Check if firebase dependencies are already added
  if (!content.contains('firebase_messaging:') ||
      !content.contains('flutter_local_notifications:')) {
    // Find the position to insert the dependencies
    final sdkDepIndex = content.indexOf('sdk: flutter');
    if (sdkDepIndex != -1) {
      final insertPoint = content.indexOf('\n', sdkDepIndex) + 1;

      // Firebase dependencies to add
      final firebaseDependencies = '''

  # Firebase dependencies for push notifications
  firebase_core: ^2.15.0
  firebase_messaging: ^14.6.5
  flutter_local_notifications: ^15.1.0+1
  ''';

      // Insert dependencies
      content = content.substring(0, insertPoint) +
          firebaseDependencies +
          content.substring(insertPoint);

      // Write updated content back to file
      pubspecFile.writeAsStringSync(content);
      context.logger.success('Added Firebase dependencies to pubspec.yaml');
    } else {
      context.logger
          .warn('Could not find dependencies section in pubspec.yaml');
    }
  } else {
    context.logger.info('Firebase dependencies already exist in pubspec.yaml');
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

  // Add imports if not already present
  if (!content.contains('firebase_core.dart') ||
      !content.contains('firebase_messaging.dart')) {
    final importPattern = RegExp(r'import .*;\n');
    final lastImportMatch = importPattern.allMatches(content).lastOrNull;

    if (lastImportMatch != null) {
      final insertPosition = lastImportMatch.end;
      content = content.substring(0, insertPosition) +
          "import 'package:firebase_core/firebase_core.dart';\n" +
          // "import 'package:firebase_messaging/firebase_messaging.dart';\n" +
          "import 'package:$projectName/core/notifications/notification_handler.dart';\n" +
          content.substring(insertPosition);
    }
  }

  // Add Firebase initialization
  if (!content.contains('Firebase.initializeApp')) {
    final mainFunction = content.indexOf('void main() async {');

    if (mainFunction != -1) {
      // Get the index after the opening brace
      final insertPosition = content.indexOf('{', mainFunction) + 1;

      content = content.substring(0, insertPosition) +
          "\n  // Initialize Firebase\n" +
          "  await Firebase.initializeApp();\n\n" +
          "  // Initialize notification services\n" +
          "  await notificationHandler.initialize();\n" +
          content.substring(insertPosition);
    }
  }

  // Write updated content back to file
  mainDartFile.writeAsStringSync(content);
  context.logger.success('Updated main.dart with Firebase initialization');
}
