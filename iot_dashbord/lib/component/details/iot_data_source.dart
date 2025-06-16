import 'package:flutter/material.dart';
import 'package:iot_dashboard/component/common/dialog_form2.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:iot_dashboard/model/iot_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IotDataSource extends DataGridSource {
  final BuildContext context;
  List<DataGridRow> _iotRows = [];

  IotDataSource(this.context, List<IotItem> items) {
    _iotRows = items.map<DataGridRow>((item) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'id', value: item.id),
        DataGridCell<String>(columnName: 'type', value: item.type),
        DataGridCell<String>(columnName: 'location', value: item.location),
        DataGridCell<String>(columnName: 'status', value: item.status),
        DataGridCell<String>(columnName: 'battery', value: item.battery),
        DataGridCell<String>(
            columnName: 'lastUpdated', value: item.lastUpdated),
        DataGridCell<double>(columnName: 'x', value: item.x),
        DataGridCell<double>(columnName: 'y', value: item.y),
        DataGridCell<double>(columnName: 'z', value: item.z),
        DataGridCell<String>(columnName: 'incline', value: item.incline),
        DataGridCell<String>(
            columnName: 'batteryInfo', value: item.batteryInfo),
        DataGridCell<String>(columnName: 'download', value: item.download),
      ]);
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
                  builder: (_) => DialogForm2(
                    mainText: "파일을 다운로드 하시겠습니까?",
                    btnText1: "아니오",
                    btnText2: "네",
                    onConfirm: () async {
                      // 다운로드 로직
                    },
                  ),
                );
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
          // 상태 컬럼만 색상 표시 적용
          final status = cell.value.toString();
          Color color;
          String iconAsset;
          switch (status) {
            case '정상':
              color = Color(0xff2fa365);
              iconAsset = 'assets/icons/alert_normal.png';
              break;
            case '주의':
              color = Color(0xfffbd50f);
              iconAsset = 'assets/icons/alert_caution.png';
              break;
            case '경고':
              color = Color(0xffff6060);
              iconAsset = 'assets/icons/alert_warning.png';
              break;
            case '점검':
              color = Color(0xff83c2f1);
              iconAsset = 'assets/icons/alert_repair.png';
              break;
            default:
              color = Colors.grey;
              iconAsset = ''; // or use a default icon if needed
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
        } else {
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
