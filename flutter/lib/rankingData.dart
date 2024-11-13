//排行榜数据例子

class RecentFile {
  final String? icon,rank, userName, hour, checkData;

  RecentFile({this.icon, this.rank, this.userName, this.hour, this.checkData});
}

List demoRecentFiles = [
  RecentFile(
    icon:"assets/icons/User.svg",
    rank: "1",
    userName: "用户1",
    hour: "9h",
    checkData: "点击查看",
  ),
  RecentFile(
    icon:"assets/icons/User.svg",
    rank: "2",
    userName: "用户2",
    hour: "8h",
    checkData: "点击查看",
  ),
  RecentFile(
    icon:"assets/icons/User.svg",
    rank: "3",
    userName: "用户3",
    hour: "8.2h",
    checkData: "点击查看",
  ),
  RecentFile(
    icon:"assets/icons/User.svg",
    rank: "4",
    userName: "用户4",
    hour: "7h",
    checkData: "点击查看",
  ),
  RecentFile(
    icon:"assets/icons/User.svg",
    rank: "5",
    userName: "用户5",
    hour: "4h",
    checkData: "点击查看",
  ),
  RecentFile(
    icon:"assets/icons/User.svg",
    rank: "5",
    userName: "用户6",
    hour: "4h",
    checkData: "点击查看",
  ),
  RecentFile(
    icon:"assets/icons/User.svg",
    rank: "6",
    userName: "用户6",
    hour: "2h",
    checkData: "点击查看",
  ),
];