// detail_iot_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:iot_dashboard/model/iot_model.dart';
import 'package:iot_dashboard/controller//iot_controller.dart';
import 'package:iot_dashboard/component/details/propulsion_port_view.dart';
import 'package:iot_dashboard/component/details/reach_port_view.dart';
import 'package:iot_dashboard/component/details/iot_data_source.dart';

class DetailIotView extends StatefulWidget {
  const DetailIotView({super.key});

  @override
  State<DetailIotView> createState() => _DetailIotViewState();
}

class _DetailIotViewState extends State<DetailIotView> {
  int selectedTab = 0; //0 : 추진구 , 1 : 도달구
  final ScrollController _verticalController = ScrollController();
  bool isDegree = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
 bool isEditing = false;
  Map<String, IotItem> editedItems = {}; // RID 기준
  Set<String> deletedKeys = {}; // RID+CreateAt 기준
  Map<String, TextEditingController> fieldControllers = {};
  Map<String, String> eventTypeValues = {};

  // Future<List<IotItem>> loadIotData() async {
  //   final String response =
  //   await rootBundle.loadString('assets/data/temp_iot.json');
  //   final List<dynamic> data = jsonDecode(response);
  //   return data.map((e) => IfromJson(e)).toList();
  // }

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }
  void _toggleEditMode(List<IotItem> items) {
    setState(() {
      isEditing = !isEditing;

      if (isEditing) {
        editedItems.clear();
        deletedKeys.clear();
        fieldControllers.clear();
        eventTypeValues.clear();

        for (final item in items) {
          String key(String field) => '${item.id}_${item.createAt}_$field';

          fieldControllers[key('latitude')] = TextEditingController(text: item.latitude);
          fieldControllers[key('longitude')] = TextEditingController(text: item.longitude);
          fieldControllers[key('battery')] = TextEditingController(text: item.battery);
          fieldControllers[key('batteryInfo')] = TextEditingController(text: item.batteryInfo);
          fieldControllers[key('x_mm')] = TextEditingController(text: item.X_MM);
          fieldControllers[key('y_mm')] = TextEditingController(text: item.Y_MM);
          fieldControllers[key('z_mm')] = TextEditingController(text: item.Z_MM);
          fieldControllers[key('x_deg')] = TextEditingController(text: item.X_Deg);
          fieldControllers[key('y_deg')] = TextEditingController(text: item.Y_Deg);
          fieldControllers[key('z_deg')] = TextEditingController(text: item.Z_Deg);

          eventTypeValues['${item.id}_${item.createAt}'] = item.eventtype;
        }
      }
    });
  }
  void _onFieldChanged(String id, String createAt, String field, String value) {
    final key = '${id}_$createAt';
    final original = context.read<IotController>().items.firstWhere(
          (e) => e.id == id && e.createAt == createAt,
      orElse: () => throw Exception('원본 데이터 없음'),
    );

    final prev = editedItems[key] ?? original;

    editedItems[key] = prev.copyWith(
      latitude: field == 'latitude' ? value : prev.latitude,
      longitude: field == 'longitude' ? value : prev.longitude,
      battery: field == 'battery' ? value : prev.battery,
      batteryInfo: field == 'batteryInfo' ? value : prev.batteryInfo,
      X_MM: field == 'x_mm' ? value : prev.X_MM,
      Y_MM: field == 'y_mm' ? value : prev.Y_MM,
      Z_MM: field == 'z_mm' ? value : prev.Z_MM,
      X_Deg: field == 'x_deg' ? value : prev.X_Deg,
      Y_Deg: field == 'y_deg' ? value : prev.Y_Deg,
      Z_Deg: field == 'z_deg' ? value : prev.Z_Deg,
      eventtype: field == 'eventtype' ? value : prev.eventtype,
    );
  }
  Future<void> _saveChanges() async {
    final controller = context.read<IotController>();

    // 1. 수정된 항목 전송
    for (final item in editedItems.values) {
      final success = await controller.updateIotItem(item);
      if (!success) {
        debugPrint('❌ 수정 실패: ${item.id}, ${item.createAt}');
      }
    }

    // 2. 삭제 요청 전송
    for (final key in deletedKeys) {
      final parts = key.split('+');
      if (parts.length == 2) {
        final rid = parts[0];
        final createAt = parts[1];
        final success = await controller.deleteIotItem(rid, createAt);
        if (!success) {
          debugPrint('❌ 삭제 실패: $rid, $createAt');
        }
      }
    }

    // 3. 데이터 새로고침
    await controller.fetchAllSensorData();

    // 4. 상태 초기화
    setState(() {
      isEditing = false;
      editedItems.clear();
      deletedKeys.clear();
      fieldControllers.clear();
      eventTypeValues.clear();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 3672.w,
          height: 1775.h,
          color: Color(0xff1b254b),
          padding: EdgeInsets.only(top: 15.h, left: 14.w),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 1277.w,
                    height: 82.h,
                    decoration: BoxDecoration(
                      color: Color(0xff414c67),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 18.8.w,
                        ),
                        Container(
                          width: 45.44.w,
                          height: 41.h,
                          child: Image.asset('assets/icons/location.png'),
                        ),
                        Text(
                          'IoT 위치',
                          style: TextStyle(
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w700,
                            fontSize: 36.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 56.w,
                  ),
                  Container(
                    width: 2314.w,
                    height: 82.h,
                    decoration: BoxDecoration(
                      color: Color(0xff414c67),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 18.8.w,
                        ),
                        Container(
                          width: 45.44.w,
                          height: 41.h,
                          child: Image.asset('assets/icons/iot.png'),
                        ),
                        Text(
                          'IoT 목록 테이블',
                          style: TextStyle(
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w700,
                            fontSize: 36.sp,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 12.w,
                        ),
                        Container(
                            width: 512.w,
                            height: 61.h,
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.toLowerCase().trim();
                                });
                              },
                              style: TextStyle(
                                fontFamily: 'PretendardGOV',
                                fontWeight: FontWeight.w400,
                                fontSize: 32.sp,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'RID(ID)로 검색',
                                  hintStyle: TextStyle(
                                    fontFamily: 'PretendardGOV',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 32.sp,
                                    color: Color(0xffa0aec0),
                                  ),
                                  prefixIcon: Container(
                                    width: 35.w,
                                    height: 40.h,
                                    child: Icon(
                                      Icons.search,
                                      color: Color(0xffa0aec0),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.r),
                                    borderSide: BorderSide(
                                        color: Color(0xffcbd5e0)), // 연한 회색 테두리
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.r),
                                    borderSide: BorderSide(
                                        color: Color(0xff3182ce),
                                        width: 2.w), // 포커스 시 테두리
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.r),
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                    bottom: 25.h,
                                  )),
                            )),
                        SizedBox(
                          width: 29.w,
                        ),
                        InkWell(
                            onTap: () {},
                            child: Container(
                              width: 141.w,
                              height: 60.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xff3182ce),
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              child: Text(
                                '검색',
                                style: TextStyle(
                                  fontFamily: 'PretendardGOV',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 36.sp,
                                  color: Colors.white,
                                ),
                              ),
                            )),
                        SizedBox(
                          width: 102.w,
                        ),
                        InkWell(
                            onTap: () {
                              setState(() {
                                isDegree = !isDegree;
                              });
                            },
                            child: Container(
                              width: 540.w,
                              height: 60.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xff3182ce),
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              child: Text(
                                '단위 전환(mm/°)',
                                style: TextStyle(
                                  fontFamily: 'PretendardGOV',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 36.sp,
                                  color: Colors.white,
                                ),
                              ),
                            )),
                        SizedBox(
                          width: 452.w,
                        ),
                    InkWell(
                      onTap: () async {
                        final items = context.read<IotController>().filterItems(_searchQuery);

                        if (isEditing) {
                          // 편집 중이면 저장 실행
                          await _saveChanges();
                        } else {
                          // 편집 시작
                          _toggleEditMode(items);
                        }
                      },
                      child: Container(
                        width: 141.w,
                        height: 60.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xff3182ce),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Text(
                          isEditing ? '저장' : '편집',
                          style: TextStyle(
                            fontFamily: 'PretendardGOV',
                            fontWeight: FontWeight.w700,
                            fontSize: 36.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                        SizedBox(
                          width: 7.w,
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              isEditing = false;
                            });

                          },
                          child: Container(
                            width: 50.w,
                            height: 50.h,
                            child: Image.asset(
                              'assets/icons/color_close.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 1273.w,
                    height: 1639.h,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => selectedTab = 0);
                                },
                                child: buildTab(
                                    label: '추진구', isSelected: selectedTab == 0),
                              ),
                            ),
                            SizedBox(
                              width: 20.w,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => selectedTab = 1);
                                },
                                child: buildTab(
                                    label: '도달구', isSelected: selectedTab == 1),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: selectedTab == 0
                              ? const PropulsionPortView()
                              : const ReachPortView(),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 56.w,
                    color: Color(0xff1b2548),
                  ),
                  // 이 영역만 바꾼 코드 (DataTable → SfDataGrid 사용)
                  Container(
                      width: 2325.w,
                      height: 1639.h,
                      color: Colors.black,
                      child: ChangeNotifierProvider(
                        create: (_) =>
                        IotController()
                          ..fetchAllSensorData(),
                        child: Consumer<IotController>(
                          builder: (context, controller, _) {
                            final items = controller.filterItems(_searchQuery);

                            if (items.isEmpty) {
                              return Center(
                                child: Text(
                                  '데이터 없음',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 24.sp),
                                ),
                              );
                            }

                            final dataSource = IotDataSource(context, items, isDegree, isEditing, deletedKeys);

                            return ScrollbarTheme(
                              data: ScrollbarThemeData(
                                thumbColor: MaterialStateProperty.all(
                                    Color(0xff004aff)),
                                // trackColor: MaterialStateProperty.all(Colors.transparent),
                                radius: Radius.circular(10.r),
                                thickness: MaterialStateProperty.all(10.w),
                              ),
                              child: Scrollbar(
                                thumbVisibility: true,
                                controller: _verticalController,
                                child: SfDataGrid(
                                  source: dataSource,
                                  allowSorting: false,
                                  verticalScrollController: _verticalController,
                                  columnWidthMode: ColumnWidthMode.none,
                                  gridLinesVisibility: GridLinesVisibility.both,
                                  headerGridLinesVisibility: GridLinesVisibility
                                      .both,
                                  columns: [
                                    GridColumn(columnName: 'id',
                                        width: 120.w,
                                        label: buildHeader('ID')),
                                    GridColumn(columnName: 'type',
                                        width: 120.w,
                                        label: buildHeader('유형')),
                                    GridColumn(columnName: 'location',
                                        width: 219.w,
                                        label: buildHeader('설치 위치')),
                                    GridColumn(columnName: 'status',
                                        width: 160.w,
                                        label: buildHeader('상태')),
                                    GridColumn(columnName: 'battery',
                                        width: 160.w,
                                        label: buildHeader('배터리')),
                                    GridColumn(columnName: 'lastUpdated',
                                        width: 320.w,
                                        label: buildHeader('마지막 수신')),
                                    GridColumn(
                                      columnName: 'X_MM',
                                      width: 180.w,
                                      label: buildHeader(isDegree ? 'X(°)' : 'X(mm)'),
                                    ),
                                    GridColumn(
                                      columnName: 'Y_MM',
                                      width: 180.w,
                                      label: buildHeader(isDegree ? 'Y(°)' : 'Y(mm)'),
                                    ),
                                    GridColumn(
                                      columnName: 'Z_MM',
                                      width: 180.w,
                                      label: buildHeader(isDegree ? 'Z(°)' : 'Z(mm)'),
                                    ),

                                    GridColumn(columnName: 'batteryInfo',
                                        width: 220.w,
                                        label: buildHeader('배터리 정보')),
    isEditing? GridColumn(
    columnName: 'delete',
    width: 100.w,
    label: buildHeader('삭제'),
    ):
                                    GridColumn(columnName: 'download',
                                        width: 442.w,
                                        label: buildHeader('데이터 다운로드')),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  )


                  ,
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget buildTab({required String label, required bool isSelected}) {
    return Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xff3182ce) : Color(0xff1b254b),
          border: isSelected
              ? null
              : Border.all(
            color: Color(0xff3182ce),
            width: 4.w,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5.r),
            topRight: Radius.circular(5.r),
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 8.w,
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PretendardGOV',
                fontSize: 36.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ));
  }

  DataColumn buildDataColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'PretendardGOV',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  DataCell buildDataCell(String columnName, String text) {
    // 상태(status) 컬럼에 색상 적용
    if (columnName == 'status') {
      Color color;
      switch (text) {
        case '정상':
          color = Colors.green;
          break;
        case '주의':
          color = Colors.yellow;
          break;
        case '경고':
          color = Colors.red;
          break;
        case '점검':
          color = Colors.lightBlue;
          break;
        default:
          color = Colors.grey;
      }

      return DataCell(
        Row(
          children: [
            Icon(Icons.circle, color: color, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontFamily: 'PretendardGOV',
              ),
            ),
          ],
        ),
      );
    }

    // 그 외 컬럼은 일반 스타일 유지
    return DataCell(
      Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Color(0xff1a1f2c),
          border: Border.all(color: Colors.white30, width: 1),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontFamily: 'PretendardGOV',
          ),
        ),
      ),
    );
  }


  DataCell buildStatusCell(String status) {
    Color color;
    switch (status) {
      case '정상':
        color = Colors.green;
        break;
      case '주의':
        color = Colors.orange;
        break;
      case '경고':
        color = Colors.red;
        break;
      case '점검':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return DataCell(
      Row(
        children: [
          Icon(Icons.circle, color: color, size: 16.sp),
          SizedBox(width: 6.w),
          Text(
            status,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontFamily: 'PretendardGOV',
            ),
          ),
        ],
      ),
    );
  }


}
