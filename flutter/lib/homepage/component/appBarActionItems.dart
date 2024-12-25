import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pose_app/style/colors.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';

class AppBarActionItems extends StatelessWidget {
  const AppBarActionItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                _showCountdownSetupDialog(context);
              },
              icon: SvgPicture.asset(
                'assets/icons/calendar.svg',
                width: 20.0,
              ),
            );
          },
        ),
        const SizedBox(width: 10.0),
        IconButton(
          onPressed: () {},
          icon: SvgPicture.asset(
            'assets/icons/ring.svg',
            width: 20.0,
          ),
        ),
        const SizedBox(width: 15.0),
        Row(
          children: [
            Image.asset(
              'assets/icons/camera.png',
              width: 30,
              height: 30,
              //fit: BoxFit.cover,
            ),
            // Icon(
            //   Icons.colorize_outlined,
            //   color: AppColors.black,
            // ),
          ],
        ),
      ],
    );
  }

  // 显示倒计时设置弹窗
  void _showCountdownSetupDialog(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + size.height / 2 - 55,
        left: offset.dx - 310,
        child: Material(
          color: Colors.transparent,
          child: CountdownSetupDialog(
            onClose: () {
              overlayEntry.remove();
            },
            iconOffset: offset,
            iconSize: size,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }
}

// 倒计时设置弹窗
class CountdownSetupDialog extends StatefulWidget {
  final VoidCallback onClose;
  final Offset iconOffset;
  final Size iconSize;

  const CountdownSetupDialog({
    super.key,
    required this.onClose,
    required this.iconOffset,
    required this.iconSize,
  });

  @override
  _CountdownSetupDialogState createState() => _CountdownSetupDialogState();
}

class _CountdownSetupDialogState extends State<CountdownSetupDialog> {
  int selectedMinutes = 0;
  int selectedSeconds = 0;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Timer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Baloo',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 滚动选择器
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPicker(
                  0,
                  59,
                  (value) {
                    setState(() {
                      selectedMinutes = value;
                    });
                  },
                  '分钟',
                ),
                const SizedBox(width: 10),
                _buildPicker(
                  0,
                  59,
                  (value) {
                    setState(() {
                      selectedSeconds = value;
                    });
                  },
                  '秒',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.refreshButton,
            ),
            onPressed: () {
              final int totalSeconds = selectedMinutes * 60 + selectedSeconds;

              if (totalSeconds > 0) {
                widget.onClose();
                _startCountdown(
                    context, totalSeconds, widget.iconOffset, widget.iconSize);
              } else {
                setState(() {
                  errorMessage = '请输入有效的时间';
                });
              }
            },
            child: const Text(
              '开始',
              style: TextStyle(
                fontFamily: 'Gen-light',
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPicker(
      int min, int max, ValueChanged<int> onSelectedItemChanged, String label) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: CupertinoPicker(
              itemExtent: 30,
              scrollController: FixedExtentScrollController(),
              onSelectedItemChanged: onSelectedItemChanged,
              children: List.generate(
                max - min + 1,
                (index) => Center(child: Text('${min + index}')),
              ),
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _startCountdown(BuildContext context, int totalSeconds,
      Offset iconOffset, Size iconSize) {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: iconOffset.dy + iconSize.height / 2 - 60,
        left: iconOffset.dx - 210,
        child: Material(
          color: Colors.transparent,
          child: CountdownDialog(
            initialSeconds: totalSeconds,
            onClose: () {
              overlayEntry.remove();
            },
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
  }
}

// 倒计时窗口
class CountdownDialog extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback onClose;

  const CountdownDialog(
      {super.key, required this.initialSeconds, required this.onClose});

  @override
  _CountdownDialogState createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<CountdownDialog> {
  late Timer _timer;
  late int _remainingSeconds;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
        _playAlarm();
        widget.onClose();
      }
    });
  }

  Future<void> _playAlarm() async {
    await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black.withOpacity(0.3), width: 2),
          ),
          child: Text(
            _formatTime(_remainingSeconds),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
