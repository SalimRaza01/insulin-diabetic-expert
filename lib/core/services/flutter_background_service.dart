import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const notificationChannelId = 'my_foreground';
const notificationId = 888;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Create Notification Channel for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, // id
    'MY FOREGROUND SERVICE', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Create the channel on the platform side
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Configure the service and start it
  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart, // Pass service to onStart
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart, // Correct callback signature
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'Basal Delivery Service',
      initialNotificationContent: 'Initializing basal delivery...',
      foregroundServiceNotificationId: notificationId,
    ),
  );
}

// This function is called when the service starts
Future<void> onStart(ServiceInstance service, ) async {
  // Ensure plugin initialization
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Show initial notification indicating basal delivery started
  flutterLocalNotificationsPlugin.show(
    notificationId,
    'INSULIN RUNNING',
    'Service is running',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        notificationChannelId,
        'MY FOREGROUND SERVICE',
        icon: 'ic_bg_service_small',  // Customize the icon for your notification
        ongoing: true, // This makes the notification persistent
      ),
    ),
  );

  // // Periodically check if we're in the start-end time range for the delivery
  // Timer.periodic(const Duration(seconds: 1), (timer) async {
  //   if (service is AndroidServiceInstance) {
  //     if (await service.isForegroundService()) {
  //       DateTime currentTime = DateTime.now();

  //       // If we're inside the start and end time, show the ongoing delivery notification
  //       if (currentTime.isAfter(startTime) && currentTime.isBefore(endTime)) {
  //         flutterLocalNotificationsPlugin.show(
  //           notificationId,
  //           'Basal Delivery In Progress',
  //           'Delivery in progress at $currentTime',
  //           const NotificationDetails(
  //             android: AndroidNotificationDetails(
  //               notificationChannelId,
  //               'MY FOREGROUND SERVICE',
  //               icon: 'ic_bg_service_small',
  //               ongoing: true,  // Keep the notification ongoing
  //             ),
  //           ),
  //         );
  //       } else if (currentTime.isAfter(endTime)) {
  //         // Once delivery time is over, mark the delivery as complete
  //         flutterLocalNotificationsPlugin.show(
  //           notificationId,
  //           'Basal Delivery Completed',
  //           'Basal delivery completed at $currentTime',
  //           const NotificationDetails(
  //             android: AndroidNotificationDetails(
  //               notificationChannelId,
  //               'MY FOREGROUND SERVICE',
  //               icon: 'ic_bg_service_small',
  //               ongoing: false,  // Ends the ongoing notification
  //             ),
  //           ),
  //         );
  //         timer.cancel();  // Stop the timer when delivery is complete
  //       }
  //     }
  //   }
  // });
}
