import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'note_channel_group',
          channelKey: 'note_channel',
          channelName: 'Note Notifications',
          channelDescription: 'Notifications for note activities',
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          locked: false,
          defaultPrivacy: NotificationPrivacy.Private,
          soundSource: 'resource://raw/res_custom_notification',
          enableVibration: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'note_channel_group',
          channelGroupName: 'Note Group',
        ),
      ],
      debug: true,
    );

    await requestNotificationPermissions();
  }

  static Future<void> requestNotificationPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  static void listenToNotificationEvents(BuildContext context) {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationService.onActionReceivedMethod,
      onNotificationCreatedMethod: NotificationService.onNotificationCreatedMethod,
      onNotificationDisplayedMethod: NotificationService.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: NotificationService.onDismissActionReceivedMethod,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationCreatedMethod');
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationDisplayedMethod');
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onDismissActionReceivedMethod');
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onActionReceivedMethod');
    if (receivedAction.payload != null && receivedAction.payload!['noteId'] != null) {
      debugPrint('Notification tapped for note ID: ${receivedAction.payload!['noteId']}');
    }
  }

  static Future<void> showNoteAddedNotification({String? noteId, String? noteContent}) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'note_channel',
        title: 'Note Added',
        body: noteContent != null
            ? 'New note: "${noteContent.length > 30 ? noteContent.substring(0, 30) + '...' : noteContent}"'
            : 'You have successfully added a new note!',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Message,
        wakeUpScreen: true,
        fullScreenIntent: false,
        criticalAlert: false,
        payload: noteId != null ? {'noteId': noteId} : null,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'VIEW',
          label: 'View Note',
          actionType: ActionType.Default,
        ),
      ],
    );
  }

  static Future<void> showNoteUpdatedNotification({String? noteId, String? noteContent}) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'note_channel',
        title: 'Note Updated',
        body: noteContent != null
            ? 'Updated note: "${noteContent.length > 30 ? noteContent.substring(0, 30) + '...' : noteContent}"'
            : 'You have successfully updated your note!',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Message,
        payload: noteId != null ? {'noteId': noteId} : null,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'VIEW',
          label: 'View Note',
          actionType: ActionType.Default,
        ),
      ],
    );
  }

  static Future<void> showNoteDeletedNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'note_channel',
        title: 'Note Deleted',
        body: 'You have successfully deleted a note!',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Social,
      ),
    );
  }

  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}