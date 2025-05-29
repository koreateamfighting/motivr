import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/component/dashboard/expand_work_task_search.dart';
import 'package:iot_dashboard/controller/worktask_controller.dart';
import 'package:iot_dashboard/model/worktask_model.dart';
import 'package:iot_dashboard/utils/iframe_visibility.dart';

class WorkTaskSection extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const WorkTaskSection({
    super.key,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<WorkTaskSection> createState() => _WorkTaskSectionState();
}

class _WorkTaskSectionState extends State<WorkTaskSection> {
  List<WorkTask> workTasks = [];

  @override
  void initState() {
    super.initState();
    _loadWorkTasks();
  }

  void _loadWorkTasks() async {
    try {
      final data = await WorkTaskController.fetchTasks();
      setState(() {
        workTasks = data;
      });
    } catch (e) {
      print('❌ 작업 데이터 로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 헤더 및 버튼 영역은 그대로
        InkWell(
          onTap: widget.onTap,
          child: Container(
            height: 60.h,
            decoration: BoxDecoration(
              color: Color(0xff111c44),
              border: Border.all(color: Colors.white, width: 1.w),
            ),
            child: Row(
              children: [
                SizedBox(width: 26.w),
                Container(
                  width: 40.16.w,
                  height: 40.h,
                  child: Image.asset('assets/icons/work_task.png'),
                ),
                SizedBox(width: 5.w),
                Text(
                  '작업명',
                  style: TextStyle(
                      fontFamily: 'PretendardGOV',
                      fontWeight: FontWeight.w500,
                      fontSize: 36.sp,
                      color: Colors.white),
                ),
                Spacer(),
                Container(
                  width: 60.w,
                  height: 60.h,
                  child: Icon(
                    widget.isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: Color(0xff3d91ff),
                    size: 70.sp,
                  ),
                )
              ],
            ),
          ),
        ),
        if (widget.isExpanded)
          Container(
            height: 59.h,
            color: Color(0xff0b1437),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 120.48.w,
                  height: 40.h,
                  padding: EdgeInsets.only(top: 5.71.h),
                  decoration: BoxDecoration(
                    color: Color(0xff3182ce),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: InkWell(
                    onTap: () {
                      hideIframes();
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: '',
                        barrierColor: Colors.black.withOpacity(0.5),
                        transitionDuration: Duration(milliseconds: 200),
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 841.w),
                              child: Material(
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: 2750.w,
                                  height: 1803.h,
                                  child: ExpandWorkTaskSearch(),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                      showIframes();
                    },
                    child: Text(
                      '전체 보기',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'PretendardGOV',
                          fontWeight: FontWeight.w400,
                          fontSize: 20.sp,
                          color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 21.52.w)
              ],
            ),
          ),
        Container(height: 1.h, color: Colors.white),
        if (widget.isExpanded)
          _buildHeaderRow(),
        if (widget.isExpanded)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            height: 354.h,
            color: Color(0xff0b1437),
            child: workTasks.isEmpty
                ? Center(
                child: Text('작업 내역 없음',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontFamily: 'PretendardGOV')))
                : ListView.separated(
              itemCount: workTasks.length,
              separatorBuilder: (_, __) =>
                  Container(height: 1.h, color: Colors.white),
              itemBuilder: (context, index) {
                final item = workTasks[index];
                return DataRowWidget(
                  item.title,
                  '${item.progress}%',
                  item.startDate ?? '-',
                  item.endDate ?? '-',
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      height: 59.h,
      decoration: BoxDecoration(
        color: Color(0xff0b1437),
        border: Border.all(color: Colors.white, width: 1.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 25.w),
          SizedBox(
              width: 80.32.w,
              child: Text('작업명',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                  style: _headerStyle())),
          SizedBox(width: 318.68.w),
          SizedBox(width: 81.32.w, child: Text('진행률', style: _headerStyle())),
          SizedBox(width: 81.68.w),
          SizedBox(width: 46.18.w, child: Text('시작', style: _headerStyle())),
          SizedBox(width: 194.82.w),
          Expanded(child: Text('완료', style: _headerStyle())),
        ],
      ),
    );
  }

  TextStyle _headerStyle() => TextStyle(
      fontFamily: 'PretendardGOV',
      fontWeight: FontWeight.w800,
      fontSize: 24.sp,
      color: Colors.white);
}

class DataRowWidget extends StatelessWidget {
  final String task;
  final String progress;
  final String start;
  final String end;

  const DataRowWidget(this.task, this.progress, this.start, this.end,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      height: 59.h,
      color: Color(0xff0b1437),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              width: 400.w,
              height: 29.h,
              child: Text(task,
                  style: _rowStyle())),
          Container(
              width: 70.w,
              height: 29.h,
              child: Text(progress,
                  style: _rowStyle())),
          SizedBox(width: 90.w),
          Container(
              width: 140.56.w,
              height: 29.h,
              child: Text(start,
                  style: _rowStyle())),
          SizedBox(width: 100.44.w),
          Container(
              width: 140.56.w,
              height: 29.h,
              child: Text(end,
                  style: _rowStyle())),
        ],
      ),
    );
  }

  TextStyle _rowStyle() => TextStyle(
    fontFamily: 'PretendardGOV',
    fontWeight: FontWeight.w500,
    fontSize: 24.sp,
    color: Colors.white,
  );
}
