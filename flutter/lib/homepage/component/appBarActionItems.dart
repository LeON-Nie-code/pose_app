import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pose_app/style/colors.dart';

class AppBarActionItems extends StatelessWidget {
  const AppBarActionItems({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:MainAxisAlignment.end,
      children: [
        IconButton(onPressed: () {}, icon: SvgPicture.asset('assets/icons/calendar.svg',
        width: 20.0,
        ),
        ),
        SizedBox(width: 10.0,),
        IconButton(onPressed: () {}, icon: SvgPicture.asset('assets/icons/ring.svg',
        width: 20.0,
        ),
        ),
        SizedBox(width: 15.0,),
        Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundImage: AssetImage('assets/icons/user_background.jpg'),
            ),
            Icon(Icons.arrow_drop_down_outlined, color: AppColors.black,),
          ],
        )
        
      ],
    );
  }
}
