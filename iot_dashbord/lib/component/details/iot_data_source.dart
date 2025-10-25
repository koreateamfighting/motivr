import 'package:flutter/material.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';
import 'package:iot_dashboard/component/common/dialog_form2.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:iot_dashboard/model/iot_model.dart';
import 'package:iot_dashboard/controller/iot_controller.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:iot_dashboard/utils/auth_service.dart';
import 'package:iot_dashboard/component/common/dialog_form2.dart';
class IotDataSource extends DataGridSource {
  final BuildContext context;
  final bool isDegree;
  final bool isEditing;
  final Set<String> deletedKeys;
  final Map<String, TextEditingController> fieldControllers;
  final Map<String, String> eventTypeValues;
  final void Function(String indexKey,String id, String field, String value)? onFieldChanged;
  final void Function(String key)? onDelete;

  List<DataGridRow> _iotRows = [];

  IotDataSource(
      this.context,
      List<IotItem> items,
      this.isDegree,
      this.isEditing,
      this.deletedKeys,
      this.fieldControllers,
      this.eventTypeValues, {
        this.onFieldChanged,
        this.onDelete,
      }) {
    _iotRows = items.map<DataGridRow>((item) {
      final cells = <DataGridCell>[

        DataGridCell<String>(columnName: 'id', value: item.id),
        DataGridCell<String>(columnName: 'label', value: item.label),
        DataGridCell<String>(columnName: 'type', value: item.sensortype),
        DataGridCell<String>(
            columnName: 'location',
            value: '${item.latitude} / ${item.longitude}'),
        DataGridCell<String>(columnName: 'status', value: item.eventtype),
        DataGridCell<String>(columnName: 'battery', value: item.battery),
        DataGridCell<String>(columnName: 'lastUpdated', value: DateFormat('yyyy-MM-dd HH:mm:ss').format(item.createAt),),
        DataGridCell<String>(
            columnName: isDegree ? 'x_deg' : 'x_mm', value: isDegree ? item.X_Deg : item.X_MM),
        DataGridCell<String>(
            columnName: isDegree ? 'y_deg' : 'y_mm',value: isDegree ? item.Y_Deg : item.Y_MM),
        DataGridCell<String>(
            columnName: isDegree ? 'z_deg' : 'z_mm', value: isDegree ? item.Z_Deg : item.Z_MM),
        DataGridCell<String>(columnName: 'batteryInfo', value: item.batteryInfo),
        DataGridCell<String>(columnName: 'indexKey', value: item.indexKey ?? ''),
      ];

      if (isEditing) {
        cells.add(DataGridCell<String>(
            columnName: 'deleteKey', value: item.indexKey ?? ''));
      } else {
        cells.add(DataGridCell<String>(
            columnName: 'download', value: item.download));
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
        final field = cell.columnName;
        final id = row.getCells().firstWhere((c) => c.columnName == 'id').value.toString();
        final indexKey = row.getCells().firstWhere((c) => c.columnName == 'indexKey').value.toString();
        if (field == 'location' && isEditing) {
          final lonKey = '${indexKey}_longitude';
          final latKey = '${indexKey}_latitude';
          if (!fieldControllers.containsKey(latKey)) {
            fieldControllers[latKey] = TextEditingController(
                text: row.getCells().firstWhere((c) => c.columnName == 'location').value.toString().split('/').last.trim()
            );
          }
          if (!fieldControllers.containsKey(lonKey)) {
            fieldControllers[lonKey] = TextEditingController(
                text: row.getCells().firstWhere((c) => c.columnName == 'location').value.toString().split('/').first.trim()
            );
          }


          return Container(
            height: 63.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Latitude
                SizedBox(
                  width: 100.w,
                  child: TextField(
                    controller: fieldControllers[latKey],
                    onChanged: (value) => onFieldChanged?.call(id, indexKey, 'latitude', value),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                // Slash separator
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    '/',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),    // Longitude
                SizedBox(
                  width: 100.w,
                  child: TextField(
                    controller: fieldControllers[lonKey],
                    onChanged: (value) => onFieldChanged?.call(id, indexKey, 'longitude', value),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

              ],
            ),
          );
        }


        // ✅ 삭제 버튼
        if (field == 'deleteKey') {
          return Container(
            height: 63.h,
            alignment: Alignment.center,
            child: InkWell(
              onTap: () {
                final id = row.getCells().firstWhere((c) => c.columnName == 'id').value.toString();
                final createAt = row.getCells().firstWhere((c) => c.columnName == 'lastUpdated').value.toString();
                final deleteKey = row.getCells().firstWhere((c) => c.columnName == 'indexKey').value.toString();
                deletedKeys.add(deleteKey);
                onDelete?.call(deleteKey);
              },
              child: Image.asset(
                'assets/icons/color_close.png',
                width: 32.w,
                height: 32.h,
              ),
            ),
          );
        }

        // ✅ 다운로드 버튼
        if (field == 'download') {
          return Container(
            width: 141.w,
            height: 40.h,
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () async {
                final isAuthorized = AuthService.isRoot() || AuthService.isStaff(); // ✅ 권한 확인
                if (!isAuthorized) {
                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const DialogForm(
                      mainText: '권한이 없습니다.',
                      btnText: '확인',
                    ),
                  );
                  return;
                }
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => DialogForm2(
                    mainText: "$id의 엑셀 파일을 다운로드 하시겠습니까?",
                    btnText1: "취소",
                    btnText2: "확인",
                    onConfirm: () {
                      final controller = context.read<IotController>();
                      controller.downloadExcelByRid(id);
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
        }

// ✅ 편집 가능한 필드 처리 (TextField)
        final nonEditable = ['id', 'type', 'status', 'lastUpdated', 'label'];
        if (isEditing && !nonEditable.contains(field)) {
          final mappedField = field; // 💡 이미 정확한 이름

          final key = '${indexKey}_$mappedField'; // ✅ key 일치
          if (!fieldControllers.containsKey(key)) {
            fieldControllers[key] = TextEditingController(text: cell.value.toString());
          }
          final controller = fieldControllers[key]!;
          return Container(
            height: 63.h,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              color: Colors.white,
            ),
            child: TextField(
              controller: controller,
              onChanged: (value) {
                // ✅ onFieldChanged도 정확한 mappedField로 전달
                onFieldChanged?.call(id,  indexKey,mappedField, value);
              },
              style: TextStyle(
                fontFamily: 'PretendardGOV',
                fontSize: 28.sp,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          );
        }


        // ✅ 상태 컬럼: degree 상태 시 아이콘 표시
        if (field == 'status' && isDegree && !isEditing) {
          final x = double.tryParse(row.getCells().firstWhere((c) => c.columnName == 'x_deg').value.toString()) ?? 0.0;
          final y = double.tryParse(row.getCells().firstWhere((c) => c.columnName == 'y_deg').value.toString()) ?? 0.0;
          final z = double.tryParse(row.getCells().firstWhere((c) => c.columnName == 'z_deg').value.toString()) ?? 0.0;
          final battery = double.tryParse(row.getCells().firstWhere((c) => c.columnName == 'battery').value.toString()) ?? 0.0;

          String status;
          Color color;
          String iconAsset;

          if (x.abs() >= 5 || y.abs() >= 5 || z.abs() >= 5) {
            status = '경고';
            color = const Color(0xffff6060);
            iconAsset = 'assets/icons/alert_warning.png';
          } else if (x.abs() >= 3 || y.abs() >= 3 || z.abs() >= 3) {
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
        }

        // ✅ 기본 텍스트 셀 (수정 불가능한 항목 포함)
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
