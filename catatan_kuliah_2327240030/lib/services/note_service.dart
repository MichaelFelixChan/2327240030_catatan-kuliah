import 'package:catatan_kuliah_2327240030/models/course_model.dart';
import 'package:catatan_kuliah_2327240030/models/note_model.dart';
import 'package:firebase_database/firebase_database.dart';

class NoteService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> addCourse(CourseModel course) async {
    final courseRef = _database.child('courses').push();
    await courseRef.set(course.toMap());
  }

  Future<List<CourseModel>> getCourses() async {
    final snapshot = await _database.child('courses').get();

    List<CourseModel> courses = [];

    if (snapshot.value != null) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      data.forEach((key, value) {
        courses.add(CourseModel.fromMap(key, value));
      });
    }
    return courses;
  }

  Future<void> addNote(NoteModel note) async {
    final noteRef = _database.child('notes').push();
    await noteRef.set(note.toMap());
  }

  Future<List<NoteModel>> getNotes() async {
    final snapshot = await _database.child('notes').get();

    List<NoteModel> notes = [];

    if (snapshot.value != null) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      data.forEach((key, value) {
        notes.add(NoteModel.fromMap(key, value));
      });
    }
    return notes;
  }

  Future<void> updateNote(NoteModel note) async {
    await _database.child('notes').child(note.id).update(note.toMap());
  }

  Future<void> deleteNote(String noteId) async {
    await _database.child('notes').child(noteId).remove();
  }

  List<NoteModel> searchNotes(List<NoteModel> notes, String keyword) {
    return notes.where((note) {
      final title = note.title.toLowerCase();
      final content = note.content.toLowerCase();
      final search = keyword.toLowerCase();

      return title.contains(search) || content.contains(search);
    }).toList();
  }

  List<NoteModel> sortNewest(List<NoteModel> notes) {
    notes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return notes;
  }

  List<NoteModel> sortOldest(List<NoteModel> notes) {
    notes.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return notes;
  }

  List<NoteModel> sortByCourse(List<NoteModel> notes) {
    notes.sort((a, b) => a.courseName.compareTo(b.courseName));
    return notes;
  }
}
