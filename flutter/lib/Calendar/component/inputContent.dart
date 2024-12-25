import 'package:flutter/material.dart';
import 'package:pose_app/style/style.dart';

class InputContent extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController? controller;
  final Widget? widget;
  const InputContent({Key?key,
  required this.hint,
  required this.title,
  this.controller,
  this.widget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:TextStyle(
              color:Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              fontFamily: 'Gen-light',
            ),
          ),
          Container(
            height: 47,
            margin: EdgeInsets.only(top:8.0),
            padding: EdgeInsets.only(left: 15),
            decoration: BoxDecoration(
              border:Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: widget == null? false:true,
                    autofocus: false,
                    cursorColor: Colors.grey[600],
                    controller: controller,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                      fontFamily: 'Gen-light',
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 0,
                      )
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 0,
                      )
                    ),
                    ),
                  )
                ),
                widget == null?Container():Container(child:widget),
              ],
            ),
          )
        ],
      ),
    );
  }
}