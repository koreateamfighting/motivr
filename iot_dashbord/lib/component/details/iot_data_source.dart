import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:iot_dashboard/model/iot_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IotDataSource extends DataGridSource {
  List<DataGridRow> _iotRows = [];

  IotDataSource(List<IotItem> items) {
    _iotRows = items.map<DataGridRow>((item) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'id', value: item.id),
        DataGridCell<String>(columnName: 'type', value: item.type),
        DataGridCell<String>(columnName: 'location', value: item.location),
        DataGridCell<String>(columnName: 'status', value: item.status),
        DataGridCell<String>(columnName: 'battery', value: item.battery),
        DataGridCell<String>(columnName: 'lastUpdated', value: item.lastUpdated),
        DataGridCell<double>(columnName: 'x', value: item.x),
        DataGridCell<double>(columnName: 'y', value: item.y),
        DataGridCell<double>(columnName: 'z', value: item.z),
        DataGridCell<String>(columnName: 'incline', value: item.incline),
        DataGridCell<String>(columnName: 'batteryInfo', value: item.batteryInfo),
        DataGridCell<String>(columnName: 'download', value: item.download),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _iotRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      color: Color(0xff0b1437),
      cells: row.getCells().map<Widget>((cell) {
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
