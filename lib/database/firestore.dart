import 'package:cloud_firestore/cloud_firestore.dart';
import '../notification/notification_service.dart';

class FirestoreService {
  final CollectionReference notes =
  FirebaseFirestore.instance.collection('notes');

  Future<void> addNote(String note) async {
    DocumentReference docRef = await notes.add({
      'note': note,
      'timestamp': Timestamp.now(),
    });

    await NotificationService.showNoteAddedNotification(
      noteId: docRef.id,
      noteContent: note,
    );
  }

  Stream<QuerySnapshot> getNotesStream() {
    return notes.orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> updateNote(String docID, String newNote) async {
    await notes.doc(docID).update({
      'note': newNote,
      'timestamp': Timestamp.now(),
    });

    await NotificationService.showNoteUpdatedNotification(
      noteId: docID,
      noteContent: newNote,
    );
  }

  Future<void> deleteNote(String docID) async {
    await notes.doc(docID).delete();
    await NotificationService.showNoteDeletedNotification();
  }
}