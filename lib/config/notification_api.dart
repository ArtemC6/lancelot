// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:lancelot/config/utils.dart';
// import 'package:rxdart/rxdart.dart';
//
// class NotificationApi {
//   static final notifications = FlutterLocalNotificationsPlugin();
//   static final onNotifications = BehaviorSubject<String>();
//
//   static Future notificationDetailsDetails(String uri) async {
//     if (uri != '') {
//       final largeIconPath = await Utils.downloadFile(uri, 'largeIcon');
//
//       final styleInformation = BigPictureStyleInformation(
//         htmlFormatContent: true,
//         FilePathAndroidBitmap(largeIconPath),
//         largeIcon: FilePathAndroidBitmap(largeIconPath),
//         hideExpandedLargeIcon: false,
//       );
//
//       return NotificationDetails(
//         android: AndroidNotificationDetails(
//           'channel title', 'channel name',
//           playSound: false,
//           priority: Priority.high,
//           importance: Importance.max,
//           styleInformation: styleInformation,
//           channelShowBadge: true,
//
//           // fullScreenIntent: true,
//           // largeIcon: largeIconPath,
//         ),
//       );
//     } else {
//       return const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'channel title',
//         'channel name',
//         playSound: false,
//         priority: Priority.high,
//         importance: Importance.max,
//       ));
//     }
//   }
//
//   static Future<void> selectNotification(String? payload) async {
//     if (payload != null && payload.isNotEmpty) {
//       onNotifications.add(payload);
//     }
//   }
//
//   static Future initNotification() async {
//     final details = await notifications.getNotificationAppLaunchDetails();
//     if (details != null && details.didNotificationLaunchApp) {
//       onNotifications.add(details.payload.toString());
//     }
//
//     await notifications.initialize(
//         onSelectNotification: selectNotification,
//         const InitializationSettings(
//           android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//         ));
//   }
//
//   static Future showNotification({
//     int? id,
//     String? title,
//     String? body,
//     String? payload,
//     String? uri,
//   }) async =>
//       notifications.show(
//           id!, title, body, await notificationDetailsDetails(uri!),
//           payload: payload);
// }
