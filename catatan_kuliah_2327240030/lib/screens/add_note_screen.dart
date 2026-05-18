import 'package:catatan_kuliah_2327240030/models/course_model.dart';
import 'package:catatan_kuliah_2327240030/models/note_model.dart';
import 'package:catatan_kuliah_2327240030/services/note_service.dart';
import 'package:flutter/material.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final NoteService noteService = NoteService();
  String? selectedCourseId;
  bool isLoading = false;
  List<CourseModel> courses = [];

  Future<void> saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih mata kuliah terlebih dahulu')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final selectedCourse = courses.firstWhere(
        (course) => course.id == selectedCourseId,
      );

      final note = NoteModel(
        id: '',
        courseId: selectedCourse.id,
        courseName: selectedCourse.name,
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await noteService.addNote(note);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil ditambahkan')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Tambah Catatan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mata Kuliah',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<CourseModel>>(
                future: noteService.getCourses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text('Belum ada mata kuliah'),
                    );
                  }
                  courses = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    initialValue: selectedCourseId,
                    decoration: InputDecoration(
                      hintText: 'Pilih mata kuliah',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: courses.map((course) {
                      return DropdownMenuItem<String>(
                        value: course.id,
                        child: Text(course.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCourseId = value;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: titleController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul Wajib Diisi';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Masukkan judul catatan',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: contentController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Isi Catatan Wajib Diisi';
                  }
                  return null;
                },
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Masukkan isi catatan',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E57C2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: isLoading ? null : saveNote,
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan Catatan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
