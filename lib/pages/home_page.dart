import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/firestore.dart';

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Stream<QuerySnapshot> notesStream;

  @override
  void initState() {
    super.initState();
    notesStream = firestoreService.getNotesStream();
  }

  void openNoteBox({String? docID, String? existingText}) {
    textController.text = existingText ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docID == null ? 'Add Note' : 'Update Note'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter your note here',
              border: OutlineInputBorder(),
              filled: true,
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final text = textController.text.trim();
                Navigator.pop(context);

                // Decide whether to add or update
                if (docID == null) {
                  firestoreService.addNote(text);
                } else {
                  firestoreService.updateNote(docID, text);
                }
                // Reset the form
                textController.clear();
              }
            },
            child: Text(docID == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    ).then((_) {
      textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openNoteBox(),
        child: Icon(Icons.add),
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final notesList = snapshot.data?.docs ?? [];

          if (notesList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No notes yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first note',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notesList.length,
            padding: EdgeInsets.all(8),
            itemBuilder: (context, index) {
              DocumentSnapshot document = notesList[index];
              String docID = document.id;
              Map<String, dynamic> data =
              document.data() as Map<String, dynamic>;
              String noteText = data['note'];
              Timestamp? timestamp = data['timestamp'] as Timestamp?;

              return Card(
                elevation: 1,
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    noteText,
                    style: TextStyle(fontSize: 16),
                  ),
                  subtitle: timestamp != null
                      ? Text(
                    'Last updated: ${_formatDate(timestamp.toDate())}',
                    style: TextStyle(fontSize: 12),
                  )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined),
                        onPressed: () =>
                            openNoteBox(docID: docID, existingText: noteText),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(docID),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${_formatTimeOfDay(date)}';
  }

  String _formatTimeOfDay(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _confirmDelete(String docID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Note'),
        content: Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              firestoreService.deleteNote(docID);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}