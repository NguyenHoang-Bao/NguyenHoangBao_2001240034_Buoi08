class Todo {
  String title;
  DateTime time;

  // khởi tạo
  Todo({required this.title, required this.time});

  // convert -> string
  String toFileString() {
    return "$title|${time.toIso8601String()}";
  }

  // parse <- string
  static Todo fromString(String line) {
    final parts = line.split("|");
    return Todo(
      title: parts[0],
      time: DateTime.parse(parts[1]),
    );
  }
}
