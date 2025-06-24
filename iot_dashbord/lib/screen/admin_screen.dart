// admin_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/input_alarm_event_section.dart';
import 'package:iot_dashboard/component/admin/input_duty_section.dart';
import 'package:iot_dashboard/component/admin/input_field_info_section.dart';
import 'package:iot_dashboard/component/admin/input_iot_section.dart';
import 'package:iot_dashboard/component/admin/input_title_logo_section.dart';
import 'package:iot_dashboard/component/common/base_layout.dart';
import 'package:iot_dashboard/utils/auth_service.dart';
import 'dart:html' as html;
import 'dart:async'; // Completer를 위한 import
import 'package:iot_dashboard/component/admin/input_notice_section.dart';
import 'package:iot_dashboard/component/admin/input_cctv_section.dart';
import 'package:iot_dashboard/component/admin/input_event_section.dart';
import 'package:iot_dashboard/component/admin/input_sensor_section.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // 전체 타이틀 변수
  final _titleController = TextEditingController();
  html.File? selectedLogoFile;

// 작업명 변수
  final _dutyNameController = TextEditingController();
  String? dutyStartDate;
  String? dutyEndDate;
  TextEditingController? _progressNameController = TextEditingController();

// 최근 알람 / 이벤트 변수
  String? alarmDate;
  String? alarmHour;
  String? alarmMinute;
  TextEditingController? _alarmTypeController;
  TextEditingController? _alarmMessageController;

//공지 및 주요일정 변수
  final _noticeContentController = TextEditingController();

//현장 정보 변수
  final _constructionTypeController = TextEditingController();
  final _constructionNameController = TextEditingController();
  final _constructionAddressController = TextEditingController();
  final _constructionCompanyController = TextEditingController();
  final _constructionOrdererController = TextEditingController();
  final _constructionLocationController = TextEditingController();
  String? constructStartDate;
  String? constructEndDate;
  final _latitudeController = TextEditingController();
  final _longtitudeController = TextEditingController();

//iot 정보 입력 변수
  final iotProductIDController = TextEditingController();
  final iotLocationController = TextEditingController();
  final iotStatusController = TextEditingController();
  final batteryStatusController = TextEditingController();
  final lastReceiveController = TextEditingController();
  final x_MMController = TextEditingController();
  final y_MMController = TextEditingController();
  final z_MMController = TextEditingController();
  final x_DegController = TextEditingController();
  final y_DegController = TextEditingController();
  final z_DegController = TextEditingController();
  final batteryInfoController = TextEditingController();

//cctv 정보 입력 변수
  final cctvProductIDController = TextEditingController();
  final cctvLocationController = TextEditingController();
  final isConnectedController = TextEditingController();
  final cctvEventController = TextEditingController();
  final imageAnalysisController = TextEditingController();
  final cctvAddressController = TextEditingController();
  String? lastReceive;

//이벤트 관리 (iot/cctv) 변수
  final iotHistoryProductIDController = TextEditingController();
  final iotHistoryLocationController = TextEditingController();
  final iotHistoryEventController = TextEditingController();
  String? iotHistoryDate;
  String? iotHistoryHour;
  String? iotHistoryMinute;
  final iotHistoryLogController = TextEditingController();

  final cctvHistoryProductIDController = TextEditingController();
  final cctvHistoryLocationController = TextEditingController();
  final cctvHistoryEventController = TextEditingController();
  String? cctvHistoryDate;
  String? cctvHistoryHour;
  String? cctvHistoryMinute;
  final cctvHistoryLogController = TextEditingController();

  //센서 정보 변수
  //지중경사계
  final inclinometerIdController = TextEditingController();
  final inclinometerLocationController = TextEditingController();
  String? inclinometerDate;
  final inclinometerMeasuredDepthsController = TextEditingController();
  final Map<double, TextEditingController> inclinometerDepthValues = {};

  //지하수위계
  final piezometerIdController = TextEditingController();
  final piezometerLocationController = TextEditingController();
  String? piezometerDate;
  final piezometerDryDaysController = TextEditingController();
  final piezometerCurrentWaterLevelController = TextEditingController();
  final piezometerGroundLevelController = TextEditingController();
  final piezometerChangeAmountController = TextEditingController();
  final piezometerCumulativeChangeController = TextEditingController();

  //변형률계
  final strainGaugeIdController = TextEditingController();
  final strainGaugeLocationController = TextEditingController();
  String? strainGaugeDate;
  final strainGaugeReadingController = TextEditingController();
  final strainGaugeStressController = TextEditingController(); // 단위: kg/cm²
  final strainGaugeDepthController = TextEditingController(); // 단위: m
  //지표침하계
  final settlementGaugeIdController = TextEditingController();
  final settlementGaugeLocationController = TextEditingController();
  String? settlementGaugeDate;
  final settlementGaugeDryDaysController = TextEditingController();
  final settlementGaugeAbsoluteValues1 = TextEditingController();
  final settlementGaugeAbsoluteValues2 = TextEditingController();
  final settlementGaugeAbsoluteValues3 = TextEditingController();
  final settlementGaugeSubsidenceValues1 = TextEditingController();
  final settlementGaugeSubsidenceValues2 = TextEditingController();
  final settlementGaugeSubsidenceValues3 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _alarmTypeController ??= TextEditingController();
    _alarmMessageController ??= TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 관리자 권한 없으면 접근 차단
    if (!AuthService.isAdmin()) {
      // 마이크로태스크로 실행 → UI가 빌드된 후에 다이얼로그 띄우기
      Future.microtask(() {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('접근 거부'),
            content: Text('관리자 계정만 들어갈 수 있습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // 🚪 관리자 아니면 대시보드로 강제 이동
                  Navigator.of(context).pushReplacementNamed('/DashBoard');
                },
                child: Text('확인'),
              ),
            ],
          ),
        );
      });

      // 일단 빈 컨테이너 반환 → 다이얼로그 후 이동
      return const Scaffold(body: SizedBox());
    }

    return ScreenUtilInit(
        designSize: const Size(3812, 2144),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BaseLayout(
              child: Container(
            padding: EdgeInsets.only(left: 64.w, right: 68.w),
            color: Color(0xffE7EAF4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100.h,
                  color: Color(0xffE7EAF4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 60.w,
                        height: 60.h,
                        child: Image.asset(
                          'assets/icons/color_setting2.png',
                        ),
                      ),
                      SizedBox(width: 18.w),
                      Container(
                          width: 200.w,
                          child: Text(
                            '관리자',
                            style: TextStyle(
                              fontFamily: 'PretendardGOV',
                              fontWeight: FontWeight.w700,
                              fontSize: 48.sp,
                              color: Colors.white,
                            ),
                          )),
                      SizedBox(width: 125.w),
                      Container(
                        width: 2880.w,
                        height: 72.h,
                        decoration: BoxDecoration(
                          color: Color(0xff414767),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 11.w,
                            ),
                            Container(
                              width: 50.w,
                              height: 50.h,
                              child: Image.asset('assets/icons/profile.png'),
                            ),
                            SizedBox(
                              width: 45.w,
                            ),
                            Container(
                                width: 261.w,
                                height: 50.h,
                                child: Text(
                                  '관리자 설정 입력',
                                  style: TextStyle(
                                    fontFamily: 'PretendardGOV',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 36.sp,
                                    color: Colors.white,
                                  ),
                                )),
                            SizedBox(
                              width: 2155.w,
                            ),
                            // InkWell(
                            //     onTap: () async {
                            //        final title = _titleController.text.trim();
                            //       // if (title.isEmpty ||
                            //       //     selectedLogoFile == null) {
                            //       //   showDialog(
                            //       //     context: context,
                            //       //     builder: (_) => AlertDialog(
                            //       //       title: Text('입력 누락'),
                            //       //       content: Text('타이틀과 로고 파일을 모두 입력해주세요.'),
                            //       //       actions: [
                            //       //         TextButton(
                            //       //             onPressed: () =>
                            //       //                 Navigator.pop(context),
                            //       //             child: Text('확인'))
                            //       //       ],
                            //       //     ),
                            //       //   );
                            //       //   return;
                            //       // }
                            //
                            //       final result = await SettingController
                            //           .uploadTitleAndLogo(
                            //               title, selectedLogoFile!);
                            //       if (result.success) {
                            //         print('✅ ${result.message}');
                            //         showDialog(
                            //           context: context,
                            //           builder: (_) =>
                            //           const DialogForm(
                            //             mainText:
                            //             '저장되었습니다.',
                            //             btnText: '확인',
                            //             fontSize: 20,
                            //           ),
                            //         );
                            //         await SettingService
                            //             .refresh(); // 🔁 TopAppBar 갱신 트리거
                            //       } else {
                            //         print('❌ ${result.message}');
                            //       }
                            //     },
                            //     child: Container(
                            //       width: 347.w,
                            //       height: 60.h,
                            //       decoration: BoxDecoration(
                            //         color: Color(0xff3182ce),
                            //         borderRadius: BorderRadius.circular(5.r),
                            //       ),
                            //       alignment: Alignment.center,
                            //       child: Text(
                            //         '전체 저장',
                            //         textAlign: TextAlign.center,
                            //         style: TextStyle(
                            //           fontFamily: 'PretendardGOV',
                            //           fontWeight: FontWeight.w700,
                            //           fontSize: 36.sp,
                            //           color: Colors.white,
                            //         ),
                            //       ),
                            //     ))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                // ✅ 헤더 하단 선
                Container(
                  width: double.infinity,
                  height: 2.h,
                  color: Color(0xff3182ce),
                ),

                SizedBox(height: 65.h),

                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          TitleLogoSection(
                            titleController: _titleController,
                            onLogoSelected: (file) {
                              selectedLogoFile = file; // ✅ AdminScreen의 상태에 저장
                            },
                          ),
                          DutySection(
                            dutyNameController: _dutyNameController,
                            dutyStartDate: dutyStartDate,
                            dutyEndDate: dutyEndDate,
                            progressController: _progressNameController,
                          ),
                          EventAlarmSection(
                            alarmDate: alarmDate,
                            alarmHour: alarmHour,
                            alarmMinute: alarmMinute,
                            alarmTypeController: _alarmTypeController,
                            alarmMessageController: _alarmMessageController,
                          ),
                          NoticeInputSection(
                              noticeContentController:
                                  _noticeContentController),
                          FieldInfoSection(
                            constructionTypeController:
                                _constructionTypeController,
                            constructionNameController:
                                _constructionNameController,
                            constructionAddressController:
                                _constructionAddressController,
                            constructionCompanyController:
                                _constructionCompanyController,
                            constructionOrdererController:
                                _constructionOrdererController,
                            constructionLocationController:
                                _constructionLocationController,
                            constructStartDate: constructStartDate,
                            constructEndDate: constructEndDate,
                            latitudeController: _latitudeController,
                            longtitudeController: _longtitudeController,
                          ),
                          IotInputSection(
                            iotProductIDController: iotProductIDController,
                            iotLocationController: iotLocationController,
                            iotStatusController: iotStatusController,
                            batteryStatusController: batteryStatusController,
                            lastReceiveController: lastReceiveController,
                            x_MMController: x_MMController,
                            y_MMController: y_MMController,
                            z_MMController: z_MMController,
                            x_DegController: x_DegController,
                            y_DegController: y_DegController,
                            z_DegController: z_DegController,
                            batteryInfoController: batteryInfoController,
                          ),
                          CCTVInputSection(
                            cctvProductIDController: cctvProductIDController,
                            cctvLocationController: cctvLocationController,
                            isConnectedController: isConnectedController,
                            cctvEventController: cctvEventController,
                            imageAnalysisController: imageAnalysisController,
                            cctvAddressController: cctvAddressController,
                            lastReceive: lastReceive,
                          ),
                          EventInputSection(
                            iotHistoryProductIDController:
                                iotHistoryProductIDController,
                            iotHistoryLocationController:
                                iotHistoryLocationController,
                            iotHistoryEventController:
                                iotHistoryEventController,
                            iotHistoryDate: iotHistoryDate,
                            iotHistoryHour: iotHistoryHour,
                            iotHistoryMinute: iotHistoryMinute,
                            iotHistoryLogController: iotHistoryLogController,
                            cctvHistoryProductIDController:
                                cctvHistoryProductIDController,
                            cctvHistoryLocationController:
                                cctvHistoryLocationController,
                            cctvHistoryEventController:
                                cctvHistoryEventController,
                            cctvHistoryDate: cctvHistoryDate,
                            cctvHistoryHour: cctvHistoryHour,
                            cctvHistoryMinute: cctvHistoryMinute,
                            cctvHistoryLogController: cctvHistoryLogController,
                          ),
                          SizedBox(
                            height: 80.h,
                          ),
                          InputSensorSection(
                            // 지중경사계
                            inclinometerIdController: inclinometerIdController,
                            inclinometerLocationController:
                                inclinometerLocationController,
                            inclinometerDate: inclinometerDate,
                            inclinometerMeasuredDepthsController:
                                inclinometerMeasuredDepthsController,
                            inclinometerDepthValues: inclinometerDepthValues,

                            // 지하수위계
                            piezometerIdController: piezometerIdController,
                            piezometerLocationController:
                                piezometerLocationController,
                            piezometerDate: piezometerDate,
                            piezometerDryDaysController:
                                piezometerDryDaysController,
                            piezometerCurrentWaterLevelController:
                                piezometerCurrentWaterLevelController,
                            piezometerGroundLevelController:
                                piezometerGroundLevelController,
                            piezometerChangeAmountController:
                                piezometerChangeAmountController,
                            piezometerCumulativeChangeController:
                                piezometerCumulativeChangeController,

                            // 변형률계
                            strainGaugeIdController: strainGaugeIdController,
                            strainGaugeLocationController:
                                strainGaugeLocationController,
                            strainGaugeDate: strainGaugeDate,
                            strainGaugeReadingController:
                                strainGaugeReadingController,
                            strainGaugeStressController:
                                strainGaugeStressController,
                            strainGaugeDepthController:
                                strainGaugeDepthController,

                            // 지표침하계
                            settlementGaugeIdController:
                                settlementGaugeIdController,
                            settlementGaugeLocationController:
                                settlementGaugeLocationController,
                            settlementGaugeDate: settlementGaugeDate,
                            settlementGaugeDryDaysController:
                                settlementGaugeDryDaysController,
                            settlementGaugeAbsoluteValues1:
                                settlementGaugeAbsoluteValues1,
                            settlementGaugeAbsoluteValues2:
                                settlementGaugeAbsoluteValues2,
                            settlementGaugeAbsoluteValues3:
                                settlementGaugeAbsoluteValues3,
                            settlementGaugeSubsidenceValues1:
                                settlementGaugeSubsidenceValues1,
                            settlementGaugeSubsidenceValues2:
                                settlementGaugeSubsidenceValues2,
                            settlementGaugeSubsidenceValues3:
                                settlementGaugeSubsidenceValues3,
                          ),
                          SizedBox(
                            height: 80.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ));
        });
  }
}
