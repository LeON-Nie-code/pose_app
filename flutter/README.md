# pose_app
## 配置环境参考教程视频
https://www.bilibili.com/video/BV1S4411E7LY?spm_id_from=333.788.videopod.episodes&vd_source=54b5d8df27cde4d3e7d32b4182dc1161&p=17


## 下载JAVA SDK
1. https://www.oracle.com/java/technologies/downloads/#jdk19-windows
2. 下载SDK，并配置变量环境中（windows系统）

## 下载flutter SDK
1. https://flutter.dev/docs/development/tools/sdk/releases#windows
2. 配置flutter国内镜像
   参考链接：https://docs.flutter.cn/community/china/
3. 检查flutter是否安装成功，如果输出关于安装的检测信息的话说明配置成功了。
      `flutter doctor`

## 在VS code 上运行flutter
1. 在extension中安装dart、flutter、Awesome Flutter Snippets插件
2. 运行代码
`flutter run -d all`
在运行flutter的过程中，常用的快捷键
```
Flutter run key commands.
r Hot reload.
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).
```
```
r 键 :点击后热加载，也就算是重新加载吧。 R键:热重启项目。
p 键:显示网格，这个可以很好的掌握布局情况，工作中很有用。 o 键:切换android和ios的预览模式。
q 键:退出调试预览模式。
```
3. 查看设备
   ·flutter devices·


