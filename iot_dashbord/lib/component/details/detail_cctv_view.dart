// detail_cctv_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/services/opencv_cctv_iframe.dart';
import 'package:provider/provider.dart';
import 'package:iot_dashboard/controller/cctv_controller.dart';
import 'package:iot_dashboard/component/details/cctv_table_list.dart';
import 'package:iot_dashboard/model/cctv_model.dart';
import 'package:iot_dashboard/services/hls_player_iframe.dart';

class DetailCctvView extends StatefulWidget {
  const DetailCctvView({super.key});

  @override
  State<DetailCctvView> createState() => _DetailCctvViewState();
}

class _DetailCctvViewState extends State<DetailCctvView> {
  String? selectedCamId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CctvController()..fetchCctvs(),
      child: Consumer<CctvController>(
        builder: (context, controller, child) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3672.w,
                height: 1775.h,
                color: const Color(0xff1b254b),
                padding: EdgeInsets.only(top: 15.h, left: 14.w),
                child: Column(
                  children: [
                    Container(
                      width: 3649.w,
                      height: 82.h,
                      decoration: BoxDecoration(
                        color: const Color(0xff414c67),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 18.8.w),
                          SizedBox(
                            width: 45.44.w,
                            height: 41.h,
                            child: Image.asset('assets/icons/cctv.png'),
                          ),
                          SizedBox(width: 60.w),
                          Text(
                            'CCTV 테이블',
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
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CctvTableList(
                          selectedCamId: selectedCamId,
                          onCamSelected: (camId) {
                            setState(() => selectedCamId = camId);
                          },
                        ),
                        SizedBox(width: 20.w),
                        Container(
                          width: 2818.w,
                          height: 1632.h,
                          padding: EdgeInsets.only(
                              left: 10.w, right: 13.w, top: 12.h),
                          child: Column(
                            children: [
                              Container(
                                width: 2798.w,
                                height: 300.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xff0b1437),
                                  border: Border.all(
                                      color: Colors.white, width: 1.w),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 100.h,
                                      decoration: BoxDecoration(
                                        color: Color(0xff0b1437),
                                        border: Border(
                                          bottom: BorderSide(
                                              color: Colors.white, width: 1.w),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 54.w,
                                          ),
                                          Container(
                                            width: 57.w,
                                            height: 40.h,
                                            child: Image.asset(
                                                'assets/icons/cctv.png'),
                                          ),
                                          SizedBox(
                                            width: 30.w,
                                          ),
                                          Text(
                                            'CCTV 현황',
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
                                    Container(
                                      height: 100.h,
                                      decoration: BoxDecoration(
                                        color: Color(0xff0b1437),
                                        border: Border(
                                          bottom: BorderSide(
                                              color: Colors.white, width: 1.w),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 54.w,
                                          ),
                                          _headerCell('ID', 179, 60),
                                          SizedBox(
                                            width: 54.w,
                                          ),
                                          _headerCell('설치 위치', 163.4, 60),
                                          SizedBox(
                                            width: 101.6.w,
                                          ),
                                          _headerCell('연결', 100, 60),
                                          SizedBox(
                                            width: 73.w,
                                          ),
                                          _headerCell('이벤트', 100, 60),
                                          SizedBox(
                                            width: 93.w,
                                          ),
                                          _headerCell('이미지 분석', 200, 60),
                                          SizedBox(
                                            width: 112.w,
                                          ),
                                          _headerCell('주소', 199, 60),
                                          SizedBox(
                                            width: 565.w,
                                          ),
                                          _headerCell('마지막 계측', 240.6, 60),
                                          SizedBox(
                                            width: 297.4.w,
                                          ),
                                          _headerCell('다운로드', 163.4, 60),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        color: const Color(0xff0b1437),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 54.w),
                                        child: selectedCamId == null
                                            ? const Center(
                                                child: Text('No Data',
                                                    style: TextStyle(
                                                        color: Colors.white)))
                                            : Builder(
                                                builder: (context) {
                                                  final selected = controller
                                                      .items
                                                      .firstWhere(
                                                    (e) =>
                                                        e.camId ==
                                                        selectedCamId,
                                                    orElse: () => CctvItem(
                                                      id: 0,
                                                      camId: '',
                                                      location: '',
                                                      isConnected: false,
                                                      eventState: '',
                                                      imageAnalysis: 0.0,
                                                      streamUrl: '',
                                                      lastRecorded:
                                                          DateTime.now(),
                                                      recordPath: '',
                                                    ),
                                                  );
                                                  return Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 54.w,
                                                      ),
                                                      _cell(
                                                        selected.camId,
                                                        w: 180,
                                                      ),
                                                      SizedBox(
                                                        width: 20.w,
                                                      ),
                                                      _cell(selected.location,
                                                          w: 200),
                                                      SizedBox(
                                                        width: 65.w,
                                                      ),

                                                      Container(
                                                        width: 40.w,
                                                        height: 40.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: selected
                                                                  .isConnected
                                                              ? const Color(
                                                                  0xffdb3829)
                                                              : const Color(
                                                                  0xff3dc473),
                                                          border: selected
                                                                  .isConnected
                                                              ? Border.all(
                                                                  color: const Color(
                                                                      0xff3dc473),
                                                                  width: 2.w)
                                                              : null,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      32.r),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 123.w,
                                                      ),
                                                      Container(
                                                          width: 140.w,
                                                          height: 83.h,
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            selected.eventState,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'PretendardGOV',
                                                              fontSize: 36.sp,
                                                              color: selected
                                                                          .eventState ==
                                                                      '정상'
                                                                  ? Color(
                                                                      0xff3dc47e)
                                                                  : Color(
                                                                      0xffdb3829),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          )),
                                                      SizedBox(
                                                        width: 100.w,
                                                      ),
                                                      // if(selected.eventState =="정상")
                                                      _cell(
                                                          '${selected.imageAnalysis.toStringAsFixed(2)} 정상',
                                                          w: 200),
                                                      SizedBox(
                                                        width: 123.w,
                                                      ),
                                                      _cell(
                                                        selected.streamUrl,
                                                        w: 600,
                                                      ),
                                                      SizedBox(
                                                        width: 140.w,
                                                      ),
                                                      _cell(
                                                        '${selected.lastRecorded.year}-${selected.lastRecorded.month.toString().padLeft(2, '0')}-${selected.lastRecorded.day.toString().padLeft(2, '0')} '
                                                        '${selected.lastRecorded.hour.toString().padLeft(2, '0')}:${selected.lastRecorded.minute.toString().padLeft(2, '0')}',
                                                        w: 500,
                                                      ),
                                                      Container(
                                                        width: 149.61.w,
                                                        height: 55.08.h,
                                                        alignment:
                                                            Alignment.center,
                                                        child: TextButton(
                                                          onPressed: () {
                                                            // TODO: implement download logic
                                                          },
                                                          style: TextButton
                                                              .styleFrom(
                                                                  backgroundColor:
                                                                      const Color(
                                                                          0xff2196f3),
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          24.w,
                                                                      vertical:
                                                                          10.h),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5.r), // ✅ 여기서 radius 지정
                                                                  )),
                                                          child: Text(
                                                            '다운로드',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 24.sp,
                                                                fontFamily:
                                                                    'PretendardGOV',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 25.h),
                              Row(
                                children: [
                                  Container(
                                    width: 2271.w,
                                    height: 1295.h,
                                    color: Colors.black,
                                    child: selectedCamId != null
                                        ? HlsPlayerIframe(
                                            key: ValueKey(
                                                selectedCamId), // 이거 중요
                                            cam: selectedCamId!,
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                  SizedBox(width: 56.w),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 162.h),
                                      Container(
                                        width: 356.w,
                                        height: 618.h,
                                        decoration: BoxDecoration(
                                          //color: Color(0xff111c44),
                                          color: Color(0xff1b254b),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.w,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5.r),
                                          // child: 이후 실제 위젯 들어갈 수 있도록 구성해둠
                                        ),
                                      ),
                                      SizedBox(height: 175.h),
                                      Container(
                                        width: 435.81.w,
                                        height: 327.h,
                                        child: selectedCamId != null && selectedCamId!.isNotEmpty
                                            ? OpencvCctvIframe(
                                          key: ValueKey(selectedCamId), // 이거 중요함
                                          cam: selectedCamId!,
                                        )
                                            : const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),

                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _headerCell(String title, double width, double height) {
    return Container(
      width: width.w,
      height: height.h,
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'PretendardGOV',
            fontSize: 36.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _cell(
    String text, {
    required double w,
    double h = 55.08,
  }) {
    return Container(
      width: w.w,
      height: h.h,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'PretendardGOV',
          fontSize: 36.sp,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
