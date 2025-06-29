import 'package:flutter/material.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';
import 'package:iot_dashboard/component/common/dialog_form2.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:iot_dashboard/model/iot_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IotDataSource extends DataGridSource {
  final BuildContext context;
  final bool isDegree;
  List<DataGridRow> _iotRows = [];

  IotDataSource(this.context, List<IotItem> items, this.isDegree) {
    _iotRows = items.map<DataGridRow>((item) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'id', value: item.id),
        DataGridCell<String>(columnName: 'type', value: item.sensortype),
        DataGridCell<String>(
          columnName: 'location',
          value: '${item.longitude} / ${item.latitude}',
        ),
        DataGridCell<String>(columnName: 'status', value: item.eventtype),
        DataGridCell<String>(columnName: 'battery', value: item.battery),
        DataGridCell<String>(columnName: 'lastUpdated', value: item.createAt),
        DataGridCell<String>(columnName: 'x', value: isDegree ? item.X_Deg : item.X_MM),
        DataGridCell<String>(columnName: 'y', value: isDegree ? item.Y_Deg : item.Y_MM),
        DataGridCell<String>(columnName: 'z', value: isDegree ? item.Z_Deg : item.Z_MM),
        DataGridCell<String>(columnName: 'x_deg', value: item.X_Deg),
        DataGridCell<String>(columnName: 'y_deg', value: item.Y_Deg),
        DataGridCell<String>(columnName: 'z_deg', value: item.Z_Deg),
        DataGridCell<String>(columnName: 'batteryInfo', value: item.batteryInfo),
        DataGridCell<String>(columnName: 'download', value: item.download),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _iotRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final xDeg = double.tryParse(row.getCells().firstWhere((c) => c.columnName == 'x_deg').value.toString()) ?? 0.0;
    final yDeg = double.tryParse(row.getCells().firstWhere((c) => c.columnName == 'y_deg').value.toString()) ?? 0.0;
    final zDeg = double.tryParse(row.getCells().firstWhere((c) => c.columnName == 'z_deg').value.toString()) ?? 0.0;
    final battery = double.tryParse(row.getCells().firstWhere((c) => c.columnName == 'battery').value.toString()) ?? 0.0;

    String status;
    Color color;
    String iconAsset;

    if (xDeg >= 5 || yDeg >= 5 || zDeg >= 5) {
      status = '경고';
      color = const Color(0xffff6060);
      iconAsset = 'assets/icons/alert_warning.png';
    } else if (xDeg >= 3 || yDeg >= 3 || zDeg >= 3) {
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
        } else if (cell.columnName == 'location') {
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
                fontSize: 24.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        } else {
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
