import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/todo.dart';

class FileService {
  Future<String> get _path async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _file async {
    final path = await _path;
    return File('$path/todo.txt');
  }

  // Lưu danh sách Todo vào file todo.txt
  Future<void> saveTodos(List<Todo> todos) async {
    final file = await _file;
    String data = todos.map((e) => e.toFileString()).join("\n");
    await file.writeAsString(data);
  }

  // Đọc dữ liệu từ file và trả về danh sách Todo
  Future<List<Todo>> loadTodos() async {
    try {
      final file = await _file;
      if (!await file.exists()) {
        return [];
      }
      final content = await file.readAsString();
      return content
          .split("\n")
          .where((e) => e.trim().isNotEmpty)
          .map((e) => Todo.fromString(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Ghi thêm một chuỗi vào file bất kỳ
  Future<void> appendToFile(String filename, String data) async {
    final path = await _path;
    final file = File('$path/$filename');
    await file.writeAsString('$data\n', mode: FileMode.append);
  }

  // Đọc nội dung file bất kỳ
  Future<String> readFromFile(String filename) async {
    try {
      final path = await _path;
      final file = File('$path/$filename');
      if (await file.exists()) {
        return await file.readAsString();
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  // Ghi đè file bất kỳ
  Future<void> writeToFile(String filename, String data) async {
    final path = await _path;
    final file = File('$path/$filename');
    await file.writeAsString(data);
  }
}
