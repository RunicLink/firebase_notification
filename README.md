# Awesome Notifications with Firebase in Flutter Apps - 5025221009 / Anthony Setiawan

Pada project ini saya membuat CRUD dimana setiap melakukan CRUD akan keluar notifikasi
![image](https://github.com/user-attachments/assets/006c25ab-7788-42c8-8b94-4631dc282383)
Bisa dilihat pada gambar tersebut bahwa data telah masuk ke dalam firebase


Setiap aktivitas seperti membuat note, mengupdate note dan mendelete note akan mengeluarkan notifikasi

Add Note
```
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
```
![Screenshot 2025-05-20 084626](https://github.com/user-attachments/assets/0a76d9fb-d6d3-40c1-870b-9cd122f040d0)

Update Note
```
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
```
![image](https://github.com/user-attachments/assets/2debdb85-aa96-430f-bc99-300914ceee08)

Delete Note
```
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
```
![image](https://github.com/user-attachments/assets/46b70968-00f0-493a-bba1-e11673913ef8)



