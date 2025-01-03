import 'package:flutter/material.dart';
import 'package:pose_app/style/colors.dart';

class MyButton extends StatelessWidget {
  final String label;
  final GestureTapCallback onTap;
  const MyButton({Key? key, required this.label, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.warmOrange,
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white, 
              fontWeight: FontWeight.w800,
              fontFamily: 'Gen-light',
            ),
          ),
        ),

      ),
    );
  }
}