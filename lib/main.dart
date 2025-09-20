// main.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

/// 🔹 Local Notifications Plugin Instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// 🔹 Background Notification Handler (top-level)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Note: background isolate cannot run complex UI - but system handles notification when notification payload used.
  print("Background Message: ${message.messageId} | ${message.notification?.title}");
}

/// 🔹 Notification Channel constants
const String defaultChannelId = 'default_channel';
const String defaultChannelName = 'General Notifications';
const String defaultChannelDesc = 'All app notifications (with custom sound)';

/// 🔹 Local Notifications & Channel Setup
Future<void> setupFlutterNotifications() async {
  // Android init with small icon (use a valid drawable)
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS init (request permission will be handled separately)
  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestSoundPermission: true,
    requestAlertPermission: true,
    requestBadgePermission: true,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // handle click
      print('Notification tapped, payload: ${response.payload}');
    },
  );

  // Create Android notification channel with custom sound resource 'custom_sound'
  final AndroidNotificationChannel channel = AndroidNotificationChannel(
    defaultChannelId,
    defaultChannelName,
    description: defaultChannelDesc,
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('custom_sound'),
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

/// 🔹 Helper: Download remote image and save locally
Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 🔹 Background Notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔹 Local Notifications Setup (create channel, etc.)
  await setupFlutterNotifications();

  runApp(const MyApp());
}

/// 🔹 Force Update Wrapper (unchanged except small cosmetic tweaks)
class UpdateChecker extends StatefulWidget {
  final Widget child;
  const UpdateChecker({super.key, required this.child});

  @override
  State<UpdateChecker> createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends State<UpdateChecker> {
  bool _showUpdate = false;
  String? _latestVersion;
  String? _currentVersion;

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  bool isVersionOlder(String current, String latest) {
    List<String> c = current.split('.');
    List<String> l = latest.split('.');

    for (int i = 0; i < l.length; i++) {
      int currentPart = i < c.length ? int.tryParse(c[i]) ?? 0 : 0;
      int latestPart = int.tryParse(l[i]) ?? 0;

      if (currentPart < latestPart) return true;
      if (currentPart > latestPart) return false;
    }
    return false;
  }

  Future<void> _checkForUpdate() async {
    try {
      final response =
          await http.get(Uri.parse("https://website.sadhumargi.in/api/latest-version"));
      if (response.statusCode == 200) {
        final latestVersion = jsonDecode(response.body)['version_code']?.toString() ?? '';
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;

        setState(() {
          _latestVersion = latestVersion;
          _currentVersion = currentVersion;
        });

        print("🔹 Installed Version: $currentVersion");
        print("🔹 Latest Version from API: $latestVersion");

        if (isVersionOlder(currentVersion, latestVersion)) {
          setState(() {
            _showUpdate = true;
          });
        }
      }
    } catch (e) {
      print("❌ Update check failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showUpdate) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.system_update_alt,
                      size: 120, color: Colors.white),
                  const SizedBox(height: 30),
                  const Text(
                    "Update Required 🚀",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "A new version of the app is available.\nPlease update to continue.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  if (_latestVersion != null && _currentVersion != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Installed: v$_currentVersion   →   Latest: v$_latestVersion",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      final url = Uri.parse(
                          "https://play.google.com/store/apps/details?id=com.sabsjs.laravel_auth_flutter");
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    child: const Text(
                      "Update Now",
                      style: TextStyle(
                        color: Color(0xFF673AB7),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sabsjs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const UpdateChecker(
        child: SplashScreen(),
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initNotifications(BuildContext context) async {
    // 🔹 Request permissions (iOS mostly)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('FCM permission: ${settings.authorizationStatus}');

    // 🔹 Subscribe to a topic
    await _messaging.subscribeToTopic("allUsers");

    // 🔹 Ensure our channel exists (redundant if created in main, but safe)
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      defaultChannelId,
      defaultChannelName,
      description: defaultChannelDesc,
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('custom_sound'),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 🔹 Foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      final imageUrl =
          notification?.android?.imageUrl ?? notification?.apple?.imageUrl;

      // Prepare platform-specific details ensuring custom sound is used
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        defaultChannelId,
        defaultChannelName,
        channelDescription: defaultChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('custom_sound'),
        icon: '@mipmap/ic_launcher',
      );

      final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'custom_sound.mp3', // must exist in app bundle for iOS
      );

      if (notification != null) {
        if (imageUrl != null && imageUrl.isNotEmpty) {
          // Download big image and show big picture style
          try {
            final String bigPicturePath =
                await _downloadAndSaveFile(imageUrl, 'bigPicture.jpg');

            final BigPictureStyleInformation bigPictureStyle =
                BigPictureStyleInformation(
              FilePathAndroidBitmap(bigPicturePath),
              largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
              contentTitle: notification.title,
              summaryText: notification.body,
            );

            final AndroidNotificationDetails bigAndroidDetails =
                AndroidNotificationDetails(
              androidDetails.channelId,
              androidDetails.channelName,
              channelDescription: androidDetails.channelDescription,
              importance: androidDetails.importance,
              priority: androidDetails.priority,
              playSound: androidDetails.playSound,
              sound: androidDetails.sound,
              icon: androidDetails.icon,
              styleInformation: bigPictureStyle,
            );

            await flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: bigAndroidDetails,
                iOS: iosDetails,
              ),
            );
          } catch (e) {
            // fallback to simple notification if image download fails
            await flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(android: androidDetails, iOS: iosDetails),
            );
          }
        } else {
          // normal notification
          await flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(android: androidDetails, iOS: iosDetails),
          );
        }
      }
    });

    // 🔹 Notification tapped (app opened from background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification Clicked: ${message.notification?.title}");
      // navigation logic if required
    });
  }
}
