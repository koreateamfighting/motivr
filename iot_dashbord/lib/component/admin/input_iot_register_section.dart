import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';
import 'package:iot_dashboard/component/admin/action_button.dart';
import 'package:iot_dashboard/component/admin/datepicker_field.dart';
import 'package:iot_dashboard/component/admin/image_picker_text_field.dart';
import 'package:iot_dashboard/component/admin/labeled_textfield_section.dart';
import 'package:iot_dashboard/component/admin/section_title.dart';
import 'package:iot_dashboard/component/admin/custom_divider.dart';
import 'package:iot_dashboard/controller/sensorinfo_controller.dart';
import 'package:iot_dashboard/model/sensorinfo_model.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';
import 'package:intl/intl.dart';  // DateFormat 임포트 추가
import 'package:pluto_grid/pluto_grid.dart';

class InputIotRegisterSection extends StatefulWidget {
  final TextEditingController? iotRegisterRidController;
  final TextEditingController? iotRegisterLabelController;
  final TextEditingController? iotRegisterSensorTypeController;
  final TextEditingController? iotRegisterEventTypeController;
  final TextEditingController? iotRegisterLocationController;
  final TextEditingController? iotRegisterLatitudeController;
  final TextEditingController? iotRegisterLongitudeController;


  const InputIotRegisterSection({
    Key? key,
    this.iotRegisterRidController,
    this.iotRegisterLabelController,
    this.iotRegisterSensorTypeController,
    this.iotRegisterEventTypeController,
    this.iotRegisterLocationController,
    this.iotRegisterLatitudeController,
    this.iotRegisterLongitudeController,

  }) : super(key: key);


  @override
  State<InputIotRegisterSection> createState() => _InputIotRegisterSectionState();
}

class _InputIotRegisterSectionState extends State<InputIotRegisterSection> {
  bool isExpanded = false;
  bool isEditing = false;
  bool _loading = false;
  bool _hasSelection = false; // ← 현재 셀/행이 선택되어 있는지
  PlutoGridStateManager? _grid;
  final List<PlutoColumn> _columns = [];
  final List<PlutoRow> _rows = [];
  final Set<String> _sessionDeletedRids = {};
  late TextEditingController iotRegisterRidController;
  late TextEditingController iotRegisterLabelController;
  late TextEditingController iotRegisterSensorTypeController;
  late TextEditingController iotRegisterEventTypeController;
  late TextEditingController iotRegisterLocationController;
  late TextEditingController iotRegisterLatitudeController;
  late TextEditingController iotRegisterLongitudeController;

  /// 서버에서 받아온 원본(변경 감지용)
  final Map<String, SensorInfo> _originalByRid = {};

  static const _minRows = 40;
// 이벤트 타입 <-> 코드 매핑
  static const Map<String, String> _codeToLabel = {
    '2': '정상',
    '67': '주의',
    '68': '위험',
  };
  static const Map<String, String> _labelToCode = {
    '정상': '2',
    '주의': '67',
    '위험': '68',
  };
  // 코드 → 라벨 (화면용)
  String _toEventLabel(dynamic v) {
    if (v == null) return '정상';
    final s = v.toString();
    // 이미 라벨이면 그대로, 숫자코드면 매핑
    return _eventOptions.contains(s) ? s : (_codeToLabel[s] ?? '정상');
  }

// 라벨 → 코드 (서버 저장용)
  String _toEventCode(dynamic v) {
    if (v == null) return '2'; // 기본 정상
    final s = v.toString();
    return _labelToCode[s] ?? s; // 라벨이면 코드로, 이미 코드면 그대로
  }

  static const List<String> _eventOptions = ['정상', '주의', '위험'];
  @override
  void initState() {
    super.initState();
    _buildColumns();
    _load();
    // 컨트롤러 초기화: 위젯에서 넘어온 게 있으면 사용, 없으면 새로 생성
    iotRegisterRidController = widget.iotRegisterRidController ?? TextEditingController();
    iotRegisterLabelController = widget.iotRegisterLabelController ?? TextEditingController();
    iotRegisterSensorTypeController = widget.iotRegisterSensorTypeController ?? TextEditingController();
    iotRegisterEventTypeController = widget.iotRegisterEventTypeController ?? TextEditingController();
    iotRegisterLocationController = widget.iotRegisterLocationController ?? TextEditingController();
    iotRegisterLatitudeController = widget.iotRegisterLatitudeController ?? TextEditingController();
    iotRegisterLongitudeController = widget.iotRegisterLongitudeController ?? TextEditingController();

    // _fetchAllSenSorInfo();
  }
  // void _onAnyFieldChanged() {
  //   if (!isEditing) {
  //     setState(() {
  //       isEditing = true;
  //     });
  //   }
  // }
  // Future<void> _fetchAllSenSorInfo() async {
  //   try {
  //     final sensorInfo = await SensorInfoController.fetchAll();
  //
  //     if (sensorInfo != null) {
  //       setState(() {
  //         iotRegisterRidController.text = sensorInfo.rid;
  //         iotRegisterLabelController.text = sensorInfo.label;
  //         iotRegisterSensorTypeController.text = sensorInfo.sensorType;
  //         iotRegisterEventTypeController.text = sensorInfo.eventType;
  //         iotRegisterLocationController.text = sensorInfo.location;
  //         iotRegisterLatitudeController.text = sensorInfo.latitude;
  //         iotRegisterLongitudeController.text = sensorInfo.longitude;
  //
  //       });
  //     }
  //   } catch (e) {
  //     // 에러 로그 찍기 (필요하면 UI에 표시 가능)
  //     print('FieldInfo fetch error: $e');
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }
  //
  // Future<void> _saveFieldInfo() async {
  //   final success = await FieldInfoController.insertFieldInfo(
  //     FieldInfo(
  //       id: 0,
  //       constructionType: constructionTypeController.text,
  //       constructionName: constructionNameController.text,
  //       address: constructionAddressController.text,
  //       company: constructionCompanyController.text,
  //       orderer: constructionOrdererController.text,
  //       location: constructionLocationController.text,
  //       startDate: constructStartDate != null ? DateFormat('yyyy-MM-dd').format(constructStartDate!) : '',
  //       endDate: constructEndDate != null ? DateFormat('yyyy-MM-dd').format(constructEndDate!) : '',
  //       latitude: latitudeController.text,
  //       longitude: longtitudeController.text,
  //     ),
  //   );
  //
  //   if (success) {
  //     showDialog(
  //       context: context,
  //       builder: (_) => const DialogForm(
  //         mainText: '현장 정보가 저장되었습니다.',
  //         btnText: '확인',
  //         fontSize: 20,
  //       ),
  //     );
  //   } else {
  //     showDialog(
  //       context: context,
  //       builder: (_) => const DialogForm(
  //         mainText: '저장에 실패했습니다.',
  //         btnText: '닫기',
  //         fontSize: 20,
  //       ),
  //     );
  //   }
  // }

  void _onGridStateChange() {
    final g = _grid;
    if (g == null) return;

    // 셀 또는 블록 선택이 하나라도 있으면 true
    final has = g.currentCell != null ||
        g.currentSelectingRows.isNotEmpty;

    if (has != _hasSelection) {
      setState(() => _hasSelection = has);
    }
  }

  void _attachGrid(PlutoGridStateManager g) {
    _grid?.removeListener(_onGridStateChange);
    _grid = g;
    _grid!.addListener(_onGridStateChange);
    _onGridStateChange(); // 초기 상태 반영
  }
  bool _hasMeaningfulValue(String field, dynamic v) {
    if (v == null) return false;

    final s = v.toString().trim();
    if (s.isEmpty) return false;

    if (field == 'Latitude' || field == 'Longitude') {
      // 0, 0.0, "0", "0.0" 등은 '입력되지 않은 것'으로 간주
      double? d;
      if (v is num) {
        d = v.toDouble();
      } else {
        d = double.tryParse(s);
      }
      return (d != null && d != 0.0);
    }

    // 그 외 필드는 비어있지만 않으면 '입력됨'으로 간주
    return true;
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 제목 바
        Container(
          width: 2880.w,
          height: 70.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: const Color(0xff414c67),
          ),
          child: Row(
            children: [
              SizedBox(width: 41.w),
              Text(
                'IoT 장비 목록 관리',
                style: TextStyle(
                  fontFamily: 'PretendardGOV',
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Image.asset(
                  isExpanded
                      ? 'assets/icons/arrow_down.png'
                      : 'assets/icons/arrow_right2.png',
                  width: isExpanded ? 40.w : 50.w,
                  height: isExpanded ? 20.h : 30.h,
                ),
              ),
              SizedBox(width: 55.w),
            ],
          ),
        ),

        if (isExpanded) SizedBox(height: 12.h),

        if (isExpanded)
          Container(
            width: 2880.w,
            height: 1570.h, // 고정 높이, 넘치면 PlutoGrid가 스크롤
            decoration: BoxDecoration(
              color: const Color(0xff1b254b),
              border: Border.all(color: const Color(0xff3182ce), width: 3.w),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: _loading
                ?  Center(child: CircularProgressIndicator(color: Color(0xff3182ce),))
                : PlutoGrid(
              columns: _columns,
              rows: _rows,
              configuration: PlutoGridConfiguration(
                style: PlutoGridStyleConfig(
                  gridBackgroundColor: const Color(0xff1b254b),
                  cellTextStyle: TextStyle(
                    fontFamily: 'PretendardGOV',
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  columnTextStyle: TextStyle(
                    fontFamily: 'PretendardGOV',
                    color: Colors.black,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800, // 헤더는 살짝 굵게 추천
                  ),
                  rowHeight: 35.h,     // 셀(바디) 높이
                  columnHeight: 60.h,  // 헤더 높이
                  iconColor: Colors.transparent,
                ),
              ),
              onLoaded: (e) {
                _attachGrid(e.stateManager);
                _grid?.setCurrentCell(null, -1);
                _onGridStateChange();
              },
              onChanged: (evt) {
                final f = evt.column.field;

                // 1) 위/경도 공백 입력 시 null로 유지
                if ((f == 'Latitude' || f == 'Longitude') &&
                    (evt.value == null || evt.value.toString().trim().isEmpty)) {
                  _grid?.changeCellValue(
                    evt.row.cells[f]!,
                    null,
                    force: true,
                    notify: true,
                  );
                }

                // 2) RID & Label이 채워졌고 EventType이 비었으면 자동으로 '정상' 세팅
                if (f == 'RID' || f == 'Label') {
                  final rid = (evt.row.cells['RID']?.value ?? '').toString().trim();
                  final label = (evt.row.cells['Label']?.value ?? '').toString().trim();
                  final evCell = evt.row.cells['EventType'];
                  final evVal = (evCell?.value ?? '').toString().trim();

                  if (rid.isNotEmpty && label.isNotEmpty && evVal.isEmpty) {
                    _grid?.changeCellValue(
                      evCell!,
                      '정상', // 화면 표시용 라벨
                      force: true,
                      notify: true,
                    );
                  }
                }
              },

              mode: PlutoGridMode.normal,
            )
            ,
          ),
        SizedBox(height: 5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            ActionButton(
              '행추가',
              const Color(0xffe98800),
              onTap: _loading ? null : _addEmptyRow,
            ),
            SizedBox(width: 12.w),
            ActionButton(
              '삭제',
              _hasSelection ?  const Color(0xffE57373) : const Color(0xff9b9c9d), // 회색
              onTap: (_loading || !_hasSelection) ? null : _deleteSelected,       // 비활성화
            ),
            SizedBox(width: 12.w),
            ActionButton(
              '저장',
              const Color(0xff3182ce),
              onTap: _loading ? null : _saveAll,
            ),
            SizedBox(width: 400.w),
          ],
        )


      ],
    );
  }



  // -------------- Columns / Rows --------------

  void _buildColumns() {
    _columns.clear();

    PlutoColumn col({
      required String field,
      required String title,
      bool readOnly = false,
      double width = 300,
      PlutoColumnType? type,
      bool sortable = true, // 정렬만 남길지 제어
      PlutoColumnRenderer? renderer,   // ⬅️ 추가

    }) {
      return PlutoColumn(
        title: title,
        field: field,
        type: type ?? PlutoColumnType.text(),
        width: width.w,
        titleTextAlign: PlutoColumnTextAlign.center,
        textAlign: PlutoColumnTextAlign.center,

        // ✅ 정렬만 허용
        enableSorting: sortable,

        // ✅ 헤더 아이콘 끄기 (드래그/메뉴)
        enableColumnDrag: false,
        enableContextMenu: false,
        enableFilterMenuItem: false,

        readOnly: readOnly,
        backgroundColor: const Color(0xff414c67),
        titlePadding: EdgeInsets.symmetric(horizontal: 8.w),
        renderer: renderer,
      );
    }

    // ✅ 맨 왼쪽 인덱스 컬럼 (편집/정렬 불가, 서버 반영 X)
    _columns.add(
      PlutoColumn(
        title: 'id',
        field: 'id',
        type: PlutoColumnType.number(),
        width: 120.w,
        readOnly: true,
        enableSorting: false,
        enableColumnDrag: false,   // ← 드래그 아이콘 제거
        enableContextMenu: false,  // ← 메뉴 아이콘 제거
        enableFilterMenuItem: false,
        titleTextAlign: PlutoColumnTextAlign.center,
        textAlign: PlutoColumnTextAlign.center,
        backgroundColor: const Color(0xff414c67),
        renderer: (ctx) => Text(
          '${ctx.rowIdx + 1}',
          style: TextStyle(color: Colors.black, fontSize: 16.sp),
          textAlign: TextAlign.center,
        ),
      ),
    );

    _columns.addAll([
      col(field: 'RID',        title: 'RID(필수입력)',       width: 270),
      col(field: 'Label',      title: '라벨(필수입력',       width: 520),
      col(field: 'SensorType', title: '센서타입',    width: 500),
      // ⬇️ 드롭다운으로 변경
      col(
        field: 'EventType',
        title: '이벤트 유형',
        width: 320,
        type: PlutoColumnType.text(),   // ← text로 두고
        readOnly: true,                 // ← 편집은 우리가 열어줄 다이얼로그로
        renderer: (ctx) {
          final label = _toEventLabel(ctx.cell.value);
          Color bg = label == '위험'
              ? Colors.red.shade600
              : (label == '주의' ? Colors.orange.shade600 : Colors.green.shade600);

          return InkWell(
            onTap: () => _openEventSelector(context, ctx),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(6.r),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 4.w),
                  const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
                ],
              ),
            ),
          );
        },
      ),

      col(field: 'Location',   title: '위치',       width: 480),
      col(
        field: 'Latitude',
        title: '위도',
        width: 330,
        type: PlutoColumnType.number(),
        renderer: (ctx) => Text(
          (ctx.cell.value == null || ctx.cell.value.toString().isEmpty)
              ? '' : ctx.cell.value.toString(),
          style: TextStyle(fontSize: 18.sp),
          textAlign: TextAlign.center,
        ),
      ),
      col(
        field: 'Longitude',
        title: '경도',
        width: 330,
        type: PlutoColumnType.number(),
        renderer: (ctx) => Text(
          (ctx.cell.value == null || ctx.cell.value.toString().isEmpty)
              ? '' : ctx.cell.value.toString(),
          style: TextStyle(fontSize: 18.sp),
          textAlign: TextAlign.center,
        ),
      ),
    ]);
  }

  PlutoRow _rowFromModel(SensorInfo s) {
    return PlutoRow(cells: {
      'id':        PlutoCell(value: 0), // 실제 표시는 renderer가 rowIdx+1로 그림
      'RID': PlutoCell(value: s.rid),
      'Label': PlutoCell(value: s.label ?? ''),
      'SensorType': PlutoCell(value: s.sensorType ?? ''),
      'EventType': PlutoCell(value: _toEventLabel(s.eventType)),
      'Location': PlutoCell(value: s.location ?? ''),
      'Latitude': PlutoCell(value: s.latitude),
      'Longitude': PlutoCell(value: s.longitude),
    });
  }

  SensorInfo _modelFromRow(PlutoRow r) {
    double? _toD(dynamic v) {
      if (v == null || v.toString().trim().isEmpty) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return SensorInfo(
      rid: (r.cells['RID']!.value ?? '').toString().trim(),
      label: (r.cells['Label']!.value ?? '').toString().trim().isEmpty
          ? null
          : r.cells['Label']!.value.toString().trim(),
      sensorType: (r.cells['SensorType']!.value ?? '').toString().trim().isEmpty
          ? null
          : r.cells['SensorType']!.value.toString().trim(),
      eventType: _toEventCode(r.cells['EventType']!.value),
      location: (r.cells['Location']!.value ?? '').toString().trim().isEmpty
          ? null
          : r.cells['Location']!.value.toString().trim(),
      latitude: _toD(r.cells['Latitude']!.value),
      longitude: _toD(r.cells['Longitude']!.value),
    );
  }
  void _ensureMinRows() {
    final need = max(0, _minRows - _rows.length);
    for (int i = 0; i < need; i++) {
      _rows.add(PlutoRow(cells: {
        'id':        PlutoCell(value: 0),
        'RID':       PlutoCell(value: ''),
        'Label':     PlutoCell(value: ''),
        'SensorType':PlutoCell(value: ''),
        'EventType': PlutoCell(value: ''),
        'Location':  PlutoCell(value: ''),
        'Latitude':  PlutoCell(value: null),
        'Longitude': PlutoCell(value: null),
      }));
    }
  }


  // -------------- Actions --------------
  Future<void> _openEventSelector(
      BuildContext context,
      PlutoColumnRendererContext ctx, // ← 여기!
      ) async {
    String current = _toEventLabel(ctx.cell.value);
    String selected = current;

    final result = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xff1b254b),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          contentPadding: EdgeInsets.all(20.w),
          content: StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 520.w,
              child: RadioTheme(
                data: RadioThemeData(
                  // M3 대응: 라디오 체크/테두리 색
                  fillColor: MaterialStateProperty.all(const Color(0xff3182ce)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ..._eventOptions.map(
                          (opt) => RadioListTile<String>(
                        value: opt,
                        groupValue: selected,
                        onChanged: (v) => setState(() => selected = v!),
                        // M2에서도 확실히 적용되도록
                        activeColor: const Color(0xff3182ce),
                        title: Text(
                          opt,
                          style: TextStyle(
                            fontFamily: 'PretendardGOV',
                            fontSize: 22.sp,
                            color: Colors.white,
                          ),
                        ),
                        dense: true,
                        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actionsPadding: EdgeInsets.only(right: 12.w, bottom: 12.h),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xff3182ce)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontFamily: 'PretendardGOV', fontSize: 18.sp),
              ),
              child: Text('취소',
                  style: TextStyle(fontFamily: 'PretendardGOV', fontSize: 18.sp, color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selected),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff3182ce),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                textStyle: TextStyle(fontFamily: 'PretendardGOV', fontSize: 18.sp),
              ),
              child: Text('확인',
                  style: TextStyle(fontFamily: 'PretendardGOV', fontSize: 18.sp, color: Colors.white)),
            ),
          ],
        );

      },
    );

    if (result != null) {
      ctx.stateManager.changeCellValue(ctx.cell, result, force: true, notify: true);
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await SensorInfoController.fetchAll();

      // 서버가 현재 돌려주는 RID 목록
      final serverRids = list.map((e) => e.rid).toSet();

      // 서버가 더 이상 돌려주지 않는 RID는 블록리스트에서 제거(완전 삭제 반영된 것)
      _sessionDeletedRids.removeWhere((rid) => !serverRids.contains(rid));

      // 세션 블록리스트에 있는 RID는 화면에서 숨김
      final visible = list.where((e) => !_sessionDeletedRids.contains(e.rid)).toList();

      _originalByRid
        ..clear()
        ..addEntries(visible.map((e) => MapEntry(e.rid, e)));

      _rows
        ..clear()
        ..addAll(visible.map(_rowFromModel));
      _ensureMinRows();

      // stateManager 갱신(하나의 방식만 사용)
      _grid?.removeAllRows();
      _grid?.appendRows(_rows);
      _reindexAfterFrame();
    } catch (e) {
      await _showDialog('불러오기 실패', e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  void _addEmptyRow() {
    final row = PlutoRow(cells: {
      'id':        PlutoCell(value: 0),
      'RID':       PlutoCell(value: ''),
      'Label':     PlutoCell(value: ''),
      'SensorType':PlutoCell(value: ''),
      'EventType': PlutoCell(value: ''),
      'Location':  PlutoCell(value: ''),
      'Latitude':  PlutoCell(value: null),
      'Longitude': PlutoCell(value: null),
    });
    _grid?.appendRows([row]);
    _reindexAfterFrame();
  }
  void _reindexAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rows = _grid?.rows ?? _rows;
      for (int i = 0; i < rows.length; i++) {
        rows[i].cells['id']?.value = i + 1;
      }
      _grid?.notifyListeners();
    });
  }


  Future<void> _deleteSelected() async {
    if (_grid == null) return;
    final selected = _grid!.currentSelectingRows.isNotEmpty
        ? _grid!.currentSelectingRows
        : (_grid!.currentRow != null ? [ _grid!.currentRow! ] : <PlutoRow>[]);

    if (selected.isEmpty) {
      await _showDialog('알림', '삭제할 행을 선택하세요.');
      return;
    }

    setState(() => _loading = true);
    int ok = 0, fail = 0;

    for (final r in selected) {
      final rid = (r.cells['RID']?.value ?? '').toString().trim();
      if (rid.isEmpty) {
        // 빈행은 로컬에서만 제거
        _grid!.removeRows([r]);
        ok++;
        continue;
      }
      try {
        final success = await SensorInfoController.deleteByRid(rid);
        if (success) {
          _originalByRid.remove(rid);
          _sessionDeletedRids.add(rid);
          _grid!.removeRows([r]);
          ok++;
        } else {
          fail++;
        }
      } catch (_) {
        fail++;
      }
    }

    setState(() => _loading = false);
  }

  Future<void> _saveAll() async {
    if (_grid == null) return;

    // 0) 필수값(RID/Label) 사전 검증: 하나라도 누락이면 전체 저장 중단
    final rows = _grid!.rows;
    for (final r in rows) {
      final rid   = (r.cells['RID']?.value ?? '').toString().trim();
      final label = (r.cells['Label']?.value ?? '').toString().trim();

      bool hasOther = false;

      // SensorType
      final st = r.cells['SensorType']?.value;
      if (st != null && st.toString().trim().isNotEmpty) hasOther = true;

      // EventType
      final ev = r.cells['EventType']?.value;
      if (!hasOther && ev != null && ev.toString().trim().isNotEmpty) hasOther = true;

      // Location
      final loc = r.cells['Location']?.value;
      if (!hasOther && loc != null && loc.toString().trim().isNotEmpty) hasOther = true;

      // Latitude (0/0.0/"0"/"0.0"은 미입력 취급)
      if (!hasOther) {
        final latV = r.cells['Latitude']?.value;
        double? lat;
        if (latV is num) {
          lat = latV.toDouble();
        } else if (latV is String && latV.trim().isNotEmpty) {
          lat = double.tryParse(latV.trim());
        }
        if (lat != null && lat != 0.0) hasOther = true;
      }

      // Longitude (0/0.0/"0"/"0.0"은 미입력 취급)
      if (!hasOther) {
        final lonV = r.cells['Longitude']?.value;
        double? lon;
        if (lonV is num) {
          lon = lonV.toDouble();
        } else if (lonV is String && lonV.trim().isNotEmpty) {
          lon = double.tryParse(lonV.trim());
        }
        if (lon != null && lon != 0.0) hasOther = true;
      }

      // 완전 빈 행은 통과, 그 외에는 RID/Label 필수
      final isEmptyRow = rid.isEmpty && label.isEmpty && !hasOther;
      if (!isEmptyRow && (rid.isEmpty || label.isEmpty)) {
        await _showDialog('입력 오류', 'RID, 라벨을 모두 입력하세요');
        return; // ⬅️ 전체 저장 취소
      }
    }

    // 0-1) RID/Label ok 인 행인데 EventType 비었으면 화면/저장 모두 '정상'으로
    for (final r in rows) {
      final rid   = (r.cells['RID']?.value ?? '').toString().trim();
      final label = (r.cells['Label']?.value ?? '').toString().trim();
      if (rid.isNotEmpty && label.isNotEmpty) {
        final evCell = r.cells['EventType'];
        final evVal  = (evCell?.value ?? '').toString().trim();
        if (evVal.isEmpty) {
          evCell?.value = '정상'; // _modelFromRow에서 코드 '2'로 변환됨
        }
      }
    }

    // 1) 저장 진행
    setState(() => _loading = true);
    int created = 0, updated = 0;

    try {
      final all = _grid!.rows.toList();
      for (final r in all) {
        final rid = (r.cells['RID']?.value ?? '').toString().trim();
        if (rid.isEmpty) continue; // 완전 빈 행 skip

        final m = _modelFromRow(r); // EventType은 '2/67/68'로 변환됨

        if (_originalByRid.containsKey(m.rid)) {
          await SensorInfoController.updateByRid(
            m.rid,
            label: m.label,
            sensorType: m.sensorType,
            eventType: m.eventType,
            location: m.location,
            latitude: m.latitude,
            longitude: m.longitude,
          );
          updated++;
        } else {
          await SensorInfoController.create(
            rid: m.rid,
            label: m.label,
            sensorType: m.sensorType,
            eventType: m.eventType,
            location: m.location,
            latitude: m.latitude,
            longitude: m.longitude,
          );
          created++;
        }
      }
    } catch (e) {
      // 서버 저장 중 예외가 발생하면 안내 후 종료
      setState(() => _loading = false);
      await _showDialog('저장 오류', '저장 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
      await _load(); // 서버 상태로 새로고침
      return;
    }


    setState(() => _loading = false);
    await _showDialog('','저장 되었습니다.');



  }


  // -------------- Helpers --------------

  Future<void> _showDialog(String title, String msg, {bool reloadAfter = false}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent, // 배경 어둡게 X
      builder: (_) => DialogForm(
        mainText: '$title\n$msg',
        btnText: '확인',
        fontSize: 18.sp,
      ),
    );

    if (reloadAfter && mounted) {
      await _load();
    }
  }



  // @override
  // Widget build(BuildContext context) {
  //   // if (_isLoading) {
  //   //   // 로딩 중일 때 로딩 인디케이터 보여주기
  //   //   return Center(child: CircularProgressIndicator(color: Color(0xff3182ce)));
  //   // }
  //
  //   return
  //     Column(
  //     children: [
  //       Container(
  //         width: 2880.w,
  //         height: 70.h,
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(5.r),
  //           color: const Color(0xff414c67),
  //         ),
  //         child: Row(
  //           children: [
  //             SizedBox(width: 41.w),
  //             Text(
  //               'Iot 장비 목록 관리',
  //               style: TextStyle(
  //                 fontFamily: 'PretendardGOV',
  //                 fontSize: 36.sp,
  //                 fontWeight: FontWeight.w700,
  //                 color: Colors.white,
  //               ),
  //             ),
  //             const Spacer(),
  //             InkWell(
  //               onTap: () {
  //                 setState(() {
  //                   isExpanded = !isExpanded;
  //                 });
  //               },
  //               child: Image.asset(
  //                 isExpanded
  //                     ? 'assets/icons/arrow_down.png'
  //                     : 'assets/icons/arrow_right2.png',
  //                 width: isExpanded ? 40.w : 50.w,
  //                 height: isExpanded ? 20.h : 30.h,
  //               ),
  //             ),
  //             SizedBox(width: 55.w),
  //           ],
  //         ),
  //       ),
  //     ]
  //   );
  // }
}
