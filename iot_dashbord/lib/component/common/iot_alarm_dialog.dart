import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:iot_dashboard/utils/keyboard_handler.dart';
import 'package:iot_dashboard/utils/iframe_visibility.dart'; // ✅ 추가

class IotAlarmDialog extends StatefulWidget {
  final String severity;   // '주의' | '경고'
  final String rid;
  final String label;
  final DateTime occurredAt;
  final String btnText;
  final double? fontSize;
  final IconData? leadingIcon;

  const IotAlarmDialog({
    super.key,
    required this.severity,
    required this.rid,
    required this.label,
    required this.occurredAt,
    this.btnText = '확인',
    this.fontSize,
    this.leadingIcon,
  });

  @override
  State<IotAlarmDialog> createState() => _IotAlarmDialogState();
}

class _IotAlarmDialogState extends State<IotAlarmDialog> {
  final FocusNode _focusNode = FocusNode();

  static const designWidth = 3812;
  static const designHeight = 2144;

  Color get _accentColor {
    final n = widget.severity.replaceAll(RegExp(r'\s+'), '');
    if (n == '경고' || n == '위험') return const Color(0xffe53e3e); // RED
    return const Color(0xffdd6b20); // AMBER for '주의' / '점검필요'
  }

  IconData get _iconData {
    final n = widget.severity.replaceAll(RegExp(r'\s+'), '');
    if (n == '경고' || n == '위험') return Icons.warning_amber_rounded;
    return Icons.report_problem_rounded;
  }
  @override
  void initState() {
    super.initState();

    // 1) 화면에 다이얼로그 뜨면 iframe 숨김 (클릭 스루 방지)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try { hideIframes(); } catch (_) {}
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // 2) 어떠한 방식으로든 닫힐 때 항상 복원 (세이프가드)
    try { showIframes(); } catch (_) {}
    _focusNode.dispose();
    super.dispose();
  }

  void _closeDialog() {
    // 닫기 동작 공통 함수: 먼저 iframe 복원 -> pop
    try { showIframes(); } catch (_) {}
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.occurredAt);

    return ScreenUtilInit(
      designSize: Size(designWidth.toDouble(), designHeight.toDouble()),
      builder: (context, child) {
        return RawKeyboardListener(
          focusNode: _focusNode,
          onKey: (RawKeyEvent event) {
            // 엔터/스페이스 → 확인, ESC → 닫기
            // NOTE: handleEnterKey2 내부에서 pop()을 직접 호출할 수 있으므로
            // dispose()에서도 showIframes()를 한 번 더 보장한다.
            handleEnterKey2(event, context);
            handleEscapeKey(event, context);
          },
          child: WillPopScope(
            // 시스템 back/ESC/배리어 탭 등 "willPop 경로"를 통해 닫힐 때도 복원 보장
            onWillPop: () async {
              try { showIframes(); } catch (_) {}
              return true; // 팝 허용
            },
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Center(
                child: Container(
                  width: 1420.w,
                  height: 520.h,
                  decoration: BoxDecoration(
                    color: const Color(0xff414c67),
                    border: Border.all(color: const Color(0xff9b9c9d), width: 10.w),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 상단 바
                      Container(
                        height: 80.h,
                        color: const Color(0xff272e3f),
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: Row(
                          children: [
                            Icon(
                              widget.leadingIcon ?? _iconData,
                              size: 44.sp,
                              color: _accentColor,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'IoT ${widget.severity} 발생',
                              style: TextStyle(
                                fontFamily: 'PretendardGOV',
                                fontWeight: FontWeight.w700,
                                fontSize: 36.sp,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: _closeDialog, // ✅ X 버튼도 공통 닫기
                              child: SizedBox(
                                width: 70.w,
                                height: 70.h,
                                child: const Icon(Icons.close, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 구분선
                      Container(color: Colors.white, height: 1.h),

                      SizedBox(height: 40.h),

                      // 본문: RID / LABEL / 발생시간
                      _kv('RID', widget.rid),
                      SizedBox(height: 16.h),
                      _kv('LABEL', widget.label),
                      SizedBox(height: 16.h),
                      _kv('발생시간', timeStr),

                      const Spacer(),

                      // 확인 버튼
                      Padding(
                        padding: EdgeInsets.only(bottom: 32.h),
                        child: InkWell(
                          onTap: _closeDialog, // ✅ 확인 버튼도 공통 닫기
                          child: Container(
                            width: 220.w,
                            height: 88.h,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _accentColor,
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            child: Text(
                              widget.btnText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'PretendardGOV',
                                fontWeight: FontWeight.w600,
                                fontSize: (widget.fontSize ?? 40.sp),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 48.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 220.w,
            child: Text(
              k,
              style: TextStyle(
                fontFamily: 'PretendardGOV',
                fontWeight: FontWeight.w600,
                fontSize: 42.sp,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: TextStyle(
                fontFamily: 'PretendardGOV',
                fontWeight: FontWeight.w500,
                fontSize: 42.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
