import 'package:flutter/material.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';
import 'package:iot_dashboard/component/common/dialog_form2.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:iot_dashboard/model/iot_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IotDataSource extends DataGridSource {
  final BuildContext context;
  final bool isDegree; // ⬅︎ 추가
  final bool isEditing;
  final Set<String> deletedKeys;
  List<DataGridRow> _iotRows = [];
//경도와 createat , eventtype , sensor type ,점검해야함 지금 임시로 바꿈
  IotDataSource(this.context, List<IotItem> items, this.isDegree, this.isEditing, this.deletedKeys) {
    _iotRows = items.map<DataGridRow>((item) {
      final cells = <DataGridCell>[
        DataGridCell<String>(columnName: 'id', value: item.id),
        DataGridCell<String>(columnName: 'type', value: item.sensortype),
        DataGridCell<String>(columnName: 'location', value: '${item.longitude} / ${item.latitude}'),
        DataGridCell<String>(columnName: 'status', value: item.eventtype),
        DataGridCell<String>(columnName: 'battery', value: item.battery),
        DataGridCell<String>(columnName: 'lastUpdated', value: item.createAt),
        DataGridCell<String>(columnName: 'x', value: isDegree ? item.X_Deg : item.X_MM),
        DataGridCell<String>(columnName: 'y', value: isDegree ? item.Y_Deg : item.Y_MM),
        DataGridCell<String>(columnName: 'z', value: isDegree ? item.Z_Deg : item.Z_MM),
        DataGridCell<String>(columnName: 'batteryInfo', value: item.batteryInfo),
      ];

      if (isEditing) {
        cells.add(DataGridCell<String>(
          columnName: 'deleteKey',
          value: '${item.id}+${item.createAt}',
        ));
      } else {
        cells.add(DataGridCell<String>(
          columnName: 'download',
          value: item.download,
        ));
      }

      return DataGridRow(cells: cells);
    }).toList();
  }


  @override
  List<DataGridRow> get rows => _iotRows;


  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      color: const Color(0xff0b1437),
      cells: row.getCells().map<Widget>((cell) {
        if (cell.columnName == 'download') {
          return Container(
            width: 141.w,
            height: 40.h,
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => DialogForm(
                    mainText: "다운로드 준비중입니다.",
                    btnText: "확인",

                  ),
                );
                // await showDialog(
                //   context: context,
                //   barrierDismissible: false,
                //   builder: (_) => DialogForm2(
                //     mainText: "파일을 다운로드 하시겠습니까?",
                //     btnText1: "아니오",
                //     btnText2: "네",
                //     onConfirm: () async {
                //       // 다운로드 로직
                //     },
                //   ),
                // );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff3182ce),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
              child: Text(
                '다운로드',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontFamily: 'PretendardGOV',
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        } else if (cell.columnName == 'status') {
          if (isDegree) {
            // isDegree == false일 때만 판단
            final x = double.tryParse(row.getCells().firstWhere((c) => c.columnName == 'x').value.toString()) ?? 0.0;
            final y = double.tryParse(row.getCells().firstWhere((c) => c.columnName == 'y').value.toString()) ?? 0.0;
            final z = double.tryParse(row.getCells().firstWhere((c) => c.columnName == 'z').value.toString()) ?? 0.0;
            final battery = double.tryParse(row.getCells().firstWhere((c) => c.columnName == 'battery').value.toString()) ?? 0.0;

            String status;
            Color color;
            String iconAsset;

            if (x >= 5 || y >= 5 || z >= 5) {
              status = '경고';
              color = const Color(0xffff6060);
              iconAsset = 'assets/icons/alert_warning.png';
            } else if (x >= 3 || y >= 3 || z >= 3) {
              status = '주의';
              color = const Color(0xfffbd50f);
              iconAsset = 'assets/icons/alert_caution.png';
            } else if (battery >= 4.8) {
              status = '점검';
              color = const Color(0xff83c2f1);
              iconAsset = 'assets/icons/alert_repair.png';
            } else {
              status = '정상';
              color = const Color(0xff2fa365);
              iconAsset = 'assets/icons/alert_normal.png';
            }

            return Container(
              height: 63.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (iconAsset.isNotEmpty)
                    Container(
                      width: 30.w,
                      height: 30.h,
                      child: Image.asset(iconAsset, fit: BoxFit.contain),
                    ),
                  SizedBox(width: 6.w),
                  Text(
                    status,
                    style: TextStyle(
                      color: color,
                      fontSize: 32.sp,
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }else if (cell.columnName == 'deleteKey') {
            return Container(
              height: 63.h,
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  deletedKeys.add(cell.value.toString());
                  // 꼭 setState(() {})를 detail_iot_view 쪽에서 감싸줘야 삭제 반영됨
                },
                child: Image.asset(
                  'assets/icons/color_close.png',
                  width: 32.w,
                  height: 32.h,
                ),
              ),
            );
          }
          else {
            // isDegree == true일 땐 비워둠
            return Container(
              height: 63.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
              ),
              child: const SizedBox.shrink(),
            );
          }
        }

        else if (cell.columnName == 'location') {
          return Container(
            height: 63.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              cell.value.toString(),
              style: TextStyle(
                fontFamily: 'PretendardGOV',
                color: Colors.white,
                fontSize: 24.sp, // 👈 작게 조정
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
        else {
          // 기본 텍스트 셀
          return Container(
            height: 63.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              cell.value.toString(),
              style: TextStyle(
                fontFamily: 'PretendardGOV',
                color: Colors.white,
                fontSize: 32.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
      }).toList(),
    );
  }

}

Widget buildHeader(String label) {
  return Container(
    height: 100.h,
    alignment: Alignment.center,
    color: Color(0xff414c67),
    child: Text(
      label,
      style: TextStyle(
        fontFamily: 'PretendardGOV',
        color: Colors.white,
        fontSize: 36.sp,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
