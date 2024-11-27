class StudyDataModel {
  final String title;
  final Map<String, String> data;

  const StudyDataModel({required this.title, required this.data});
}

class StudyDetails {
  final List<StudyDataModel> aboutTotalData;
  final List<StudyDataModel> aboutTodayData;

  // 构造函数，设置默认值为 0
  StudyDetails()
      : aboutTotalData = [
          StudyDataModel(title: "次数", data: {"value": "0"}), // 累积次数默认 0
          StudyDataModel(title: "时长", data: {"totalHour": "0"}), // 累积时长默认 0
          StudyDataModel(title: "日均时长", data: {"totalAverage": "0"}), // 累积日均时长默认 0
        ],
        aboutTodayData = [
          StudyDataModel(title: "次数", data: {"todayValue": "0"}), // 当天次数默认 0
          StudyDataModel(title: "时长", data: {"todayHour": "0"}), // 当天时长默认 0
          StudyDataModel(title: "日均时长", data: {"todayAverage": "0"}), // 当天日均时长默认 0
        ];
}

// TODO: 添加更新数据的方法，下面是例子
//   // 更新 StudyDataModel 列表中的数据
//   // [studyData] 表示需要更新的 StudyDataModel 列表。
//   // [backendData] 后端返回的数据，键为数据的标识（如 "value", "totalHour" 等），值为对应的新数据
//   // 若后端数据缺失，则默认填充为 "0"
//   void updateData(List<StudyDataModel> studyData, Map<String, String> backendData) {
//     for (int i = 0; i < studyData.length; i++) {
//       final key = studyData[i].data.keys.first; // 获取当前键
//       final newValue = backendData[key] ?? "0"; // 获取后端数据，若为空则默认 0
//       studyData[i] = StudyDataModel(
//         title: studyData[i].title,
//         data: {key: newValue}, // 更新数据
//       );
//     }
//   }
// }
     

