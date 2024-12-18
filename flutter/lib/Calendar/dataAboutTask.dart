class Task {
  String? userName;
  String? title;
  String? note;
  int? isCompleted;
  String? date;
  String? remind;
  int? id;

  //Task的字符串表示
  @override
  String toString() {
    return 'Task{todo_id: $id ,userName: $userName, title: $title, note: $note, isCompleted: $isCompleted, date: $date, remind: $remind}';
  }

  Task({
    this.userName,
    this.title,
    this.note,
    this.isCompleted,
    this.date,
    this.remind,
    this.id,
  });

  // 从 JSON 构造 Task 实例
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      userName: json['userName'],
      title: json['title'],
      note: json['note'],
      isCompleted: json['isCompleted'],
      date: json['date'],
      remind: json['remind'],
    );
  }

  // 将 toJson 方法放入类内部
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userName'] = userName; // 使用字段名直接赋值
    data['title'] = title;
    data['note'] = note;
    data['isCompleted'] = isCompleted; // 保证字段名一致
    data['date'] = date;
    data['remind'] = remind;
    data['id'] = id;
    return data;
  }
}
