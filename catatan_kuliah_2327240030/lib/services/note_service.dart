import 'package:firebase_database/firebase_database.dart';

class NoteService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
}
