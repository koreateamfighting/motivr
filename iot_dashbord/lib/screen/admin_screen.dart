// admin_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/admin/input_alarm_event_section.dart';
import 'package:iot_dashboard/component/admin/input_duty_section.dart';
import 'package:iot_dashboard/component/admin/input_field_info_section.dart';
import 'package:iot_dashboard/component/admin/input_iot_section.dart';
import 'package:iot_dashboard/component/admin/input_title_logo_section.dart';
import 'package:iot_dashboard/component/common/base_layout.dart';
import 'package:iot_dashboard/state/user_role_state.dart';
import 'package:iot_dashboard/utils/auth_service.dart';
import 'dart:html' as html;
import 'dart:async'; // Completer를 위한 import
import 'package:iot_dashboard/component/admin/input_notice_section.dart';
import 'package:iot_dashboard/component/admin/input_cctv_section.dart';
import 'package:iot_dashboard/component/admin/input_event_history_section.dart';
import 'package:iot_dashboard/component/admin/input_special_sensor_section.dart';
import 'package:iot_dashboard/component/admin/input_auth_section.dart';
import 'package:iot_dashboard/component/common/dialog_form.dart';
import 'package:provider/provider.dart';
import 'package:iot_dashboard/controller/iot_controller.dart';

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
  String? alarmSecond;
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
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final x_DegController = TextEditingController();
  final y_DegController = TextEditingController();
  final z_DegController = TextEditingController();
  final x_MMController = TextEditingController();
  final y_MMController = TextEditingController();
  final z_MMController = TextEditingController();
  String? createdAtDate;
  String? createdAtHour;
  String? createdAtMinute;
  String? createdAtSecond;
  final batteryVoltageController = TextEditingController();
  final batteryInfoController = TextEditingController();

//cctv 정보 입력 변수
  final cctvProductIDController = TextEditingController();
  final cctvLocationController = TextEditingController();
  final isConnectedController = TextEditingController();
  final cctvEventController = TextEditingController();
  final imageAnalysisController = TextEditingController();
  final cctvAddressController = TextEditingController();
  String? lastReceiveDate;
  String? lastReceiveHour;
  String? lastReceiveMinute;

//이벤트 관리 (iot/cctv) 변수
  final iotHistoryProductIDController = TextEditingController();
  final iotHistoryLatitudeController = TextEditingController();
  final iotHistoryLongitudeController = TextEditingController();

  String? iotHistoryDate;
  String? iotHistoryHour;
  String? iotHistoryMinute;
  final iotHistoryLogController = TextEditingController();

  final cctvHistoryProductIDController = TextEditingController();


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

  //계정 및 권한
  final idController = TextEditingController();
  final pwController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final companyController = TextEditingController();
  final deptController = TextEditingController();
  final positionController = TextEditingController();
  final responsibilitiesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _alarmTypeController ??= TextEditingController();
    _alarmMessageController ??= TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 관리자 권한 없으면 접근 차단
    if (!AuthService.isStaff() && !AuthService.isRoot()) {
      Future.microtask(() {
        showDialog(
          context: context,
          barrierDismissible: false, // 바깥 터치로 닫히지 않도록
          builder: (_) => const DialogForm(
            mainText: '관리자 계정만 접근할 수 있습니다.',
            btnText: '확인',
          ),
        ).then((_) {
          Navigator.of(context).pushReplacementNamed('/DashBoard');
        });
      });

      return const Scaffold(body: SizedBox());
    }


    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserRoleState()..fetchRoles()),
          ChangeNotifierProvider(create: (_) => IotController()), // ✅ 추가
        ],
        child: ScreenUtilInit(
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
                                  child:
                                      Image.asset('assets/icons/profile.png'),
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
                                  selectedLogoFile =
                                      file; // ✅ AdminScreen의 상태에 저장
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
                                alarmSecond: alarmSecond,
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
                                latitudeController: latitudeController,
                                longitudeController: longitudeController,
                                x_MMController: x_MMController,
                                y_MMController: y_MMController,
                                z_MMController: z_MMController,
                                x_DegController: x_DegController,
                                y_DegController: y_DegController,
                                z_DegController: z_DegController,
                                createdAtDate: createdAtDate,
                                createdAtHour: createdAtHour,
                                createdAtMinute: createdAtMinute,
                                createdAtSecond: createdAtSecond,
                                batteryVoltageController : batteryVoltageController,
                                batteryInfoController: batteryInfoController,
                              ),
                              CCTVInputSection(
                                cctvProductIDController:
                                    cctvProductIDController,
                                imageAnalysisController:
                                    imageAnalysisController,
                                cctvAddressController: cctvAddressController,
                                lastReceiveDate: lastReceiveDate,
                                lastReceiveHour: lastReceiveHour,
                                lastReceiveMinute: lastReceiveMinute,
                              ),
                              EventInputSection(
                                iotHistoryProductIDController:
                                    iotHistoryProductIDController,
                                iotHistoryLatitudeController:
                                iotHistoryLatitudeController,
                                iotHistoryLongitudeController:
                                iotHistoryLongitudeController,

                                iotHistoryDate: iotHistoryDate,
                                iotHistoryHour: iotHistoryHour,
                                iotHistoryMinute: iotHistoryMinute,
                                // iotHistorySecond: iotHistorySecond,
                                iotHistoryLogController:
                                    iotHistoryLogController,
                                cctvHistoryProductIDController:
                                    cctvHistoryProductIDController,


                                cctvHistoryDate: cctvHistoryDate,
                                cctvHistoryHour: cctvHistoryHour,
                                cctvHistoryMinute: cctvHistoryMinute,
                                cctvHistoryLogController:
                                    cctvHistoryLogController,
                              ),
                              SizedBox(
                                height: 80.h,
                              ),
                              InputSpecialSensorSection(
                                // 지중경사계
                                inclinometerIdController:
                                    inclinometerIdController,
                                inclinometerDate: inclinometerDate,

                                inclinometerDepthValues:
                                    inclinometerDepthValues,

                                // 지하수위계
                                piezometerIdController: piezometerIdController,
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
                                strainGaugeIdController:
                                    strainGaugeIdController,
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
                              AuthSection(
                                idController: idController,
                                pwController: pwController,
                                emailController: emailController,
                                nameController: nameController,
                                phoneController: phoneController,
                                companyController: companyController,
                                deptController: deptController,
                                positionController: positionController,
                                responsibilitiesController:
                                    responsibilitiesController,
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ));
            }));
  }
}
