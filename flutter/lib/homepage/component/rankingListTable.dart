//主页第一个container的窗口内容

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pose_app/config/size_config.dart';
import 'package:pose_app/rankingData.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/style/style.dart';

class rankingListTable extends StatelessWidget {
  const rankingListTable({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.beige,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8, // 限制最大高度
          maxWidth: 600,  // 限制宽度
        ),
        child: Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PrimaryText(
                      text: '排行榜',
                      size: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                    PrimaryText(
                      text: '20xx/xx/xx',
                      size: 16.0,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    DataTable(
                      columnSpacing: defaultPadding,
                      columns: [
                        DataColumn(label: Text('排名')),
                        DataColumn(label: Text('用户名')),
                        DataColumn(label: Text('总时间')),
                      ],
                      rows: List.generate(
                        demoRecentFiles.length,
                        (index) => rankingListDataRow(demoRecentFiles[index]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataRow rankingListDataRow(RecentFile fileInfo) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              SvgPicture.asset(
                fileInfo.icon ?? 'assets/icons/example_user.svg',
                height: 30,
                width: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(fileInfo.rank ?? 'N/A'),
              )
            ],
          ),
        ),
        DataCell(Text(fileInfo.userName ?? 'N/A')),
        DataCell(Text(fileInfo.hour ?? 'N/A')),
      ],
    );
  }
}
