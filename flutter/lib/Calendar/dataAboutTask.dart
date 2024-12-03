class Task {
  String? userName;
  String? title;
  String? note;
  int? isCompleted; 
  String? date;
  String? remind;

  Task({
    this.userName,
    this.title,
    this.note,
    this.isCompleted,
    this.date,
    this.remind,
  });

  // 将 toJson 方法放入类内部
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userName'] = userName; // 使用字段名直接赋值
    data['title'] = title;
    data['note'] = note;
    data['isCompleted'] = isCompleted; // 保证字段名一致
    data['date'] = date;
    data['remind'] = remind;
    return data;
  }
}
