import 'package:flutter/material.dart';
import 'package:iot_dashboard/component/dialog_form2.dart';
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

                  },
                ),
                );
              }, // 비어있는 onPressed
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff3182ce), // 파란색
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
