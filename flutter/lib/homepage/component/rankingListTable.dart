//主页第一个container的窗口内容

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pose_app/config/size_config.dart';
import 'package:pose_app/rankingData.dart';
import 'package:pose_app/style/colors.dart';
import 'package:pose_app/style/style.dart';
import 'package:pose_app/rankingData.dart';

class rankingListTable extends StatelessWidget {
  const rankingListTable({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: SizeConfig.blockSizeVertical! * 4),        
        Container(
          padding: EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: AppColors.beige,
            borderRadius: 
            const BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PrimaryText(
                    text: '排行榜',
                    size: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
              PrimaryText(text: '20xx/xx/xx',size: 16.0,color: AppColors.secondary,),   
              SizedBox(
                width: double.infinity,
                child: DataTable(
                  horizontalMargin: 0,
                  columnSpacing: defaultPadding,
                  columns:[
                    DataColumn(
                      label: Text('排名')
                      ),
                    DataColumn(
                      label: Text('用户名')
                      ),
                    DataColumn(
                      label: Text('总时间')
                      ),
                        
                  ] ,
                  rows: List.generate(
                    demoRecentFiles.length, (index) => rankingListDataRow(demoRecentFiles[index]
                  ),)
                  ),
              )
    
            ],
          ),
          ),
    
      ],
      
    );
  }

  DataRow rankingListDataRow(RecentFile fileInfo) {
    return DataRow(
                    cells:[
                      DataCell(
                        Row(
                          children: [
                            SvgPicture.asset(
                              fileInfo.icon ?? 'assets/icons/example_user.svg',
                              height: 30,
                              width: 30,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: defaultPadding),
                                child: (Text(fileInfo.rank ?? 'N/A')), 
                            )
                            

                          ],
                        ),
                      ),
                      
                      //DataCell(Text(fileInfo.rank ?? 'N/A')),                              
                      DataCell(Text(fileInfo.userName ?? 'N/A')),
                      DataCell(Text(fileInfo.hour ?? 'N/A')),
                      //DataCell(Text(fileInfo.checkData ?? 'N/A')),
  
                    ],
                  );
  }
}