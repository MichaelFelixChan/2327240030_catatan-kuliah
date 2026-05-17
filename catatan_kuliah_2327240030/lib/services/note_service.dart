import 'package:catatan_kuliah_2327240030/models/course_model.dart';
import 'package:catatan_kuliah_2327240030/models/note_model.dart';
import 'package:firebase_database/firebase_database.dart';

class NoteService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> addCourse(String name, String lecturer) async {
    final courseRef = _database.child('courses').push();

    await courseRef.set({'name': name, 'lecturer': lecturer});
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

  Future<void> addNote({
    required String courseId,
    required String courseName,
    required String title,
    required String content,
  }) async {
    final noteRef = _database.child('notes').push();

    await noteRef.set({
      'courseId': courseId,
      'courseName': courseName,
      'title': title,
      'content': content,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
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

  Future<void> updateNote({
    required String noteId,
    required String courseId,
    required String courseName,
    required String title,
    required String content,
  }) async {
    await _database.child('notes/$noteId').update({
      'courseId': courseId,
      'courseName': courseName,
      'title': title,
      'content': content,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> deleteNote(String noteId) async {
    await _database.child('notes/$noteId').remove();
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
