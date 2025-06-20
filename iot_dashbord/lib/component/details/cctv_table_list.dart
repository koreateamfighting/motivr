import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:iot_dashboard/controller/cctv_controller.dart';

class CctvTableList extends StatefulWidget {
  final String? selectedCamId;
  final ValueChanged<String> onCamSelected;

  const CctvTableList(
      {super.key, required this.selectedCamId, required this.onCamSelected});

  @override
  State<CctvTableList> createState() => _CctvTableListState();
}

class _CctvTableListState extends State<CctvTableList> {
  int currentPage = 1;
  final int itemsPerPage = 13;

  @override
  void initState() {
    super.initState();

    // Provider의 데이터가 준비되면 첫 번째 항목 선택
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<CctvController>();
      if (controller.items.isNotEmpty && widget.selectedCamId == null) {
        widget.onCamSelected(controller.items.first.camId);
      }

      controller.addListener(() {
        if (mounted && controller.items.isNotEmpty && widget.selectedCamId == null) {
          widget.onCamSelected(controller.items.first.camId);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CctvController>();
    final items = controller.items;
    final totalPages = (items.length / itemsPerPage).ceil();

    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage < items.length)
        ? startIndex + itemsPerPage
        : items.length;

    final pagedItems = items.sublist(startIndex, endIndex);

    return Container(
      width: 813.w,
      height: 1632.h,
      child: Column(
        children: [
          _buildTitleBar(),
          _buildHeader(),
          _buildList(pagedItems),
          _buildPagination(totalPages),
        ],
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      width: 799.w,
      height: 100.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(0xff414c67),
        border: Border(
          top: BorderSide(color: Colors.white, width: 2.w),
          left: BorderSide(color: Colors.white, width: 2.w),
          right: BorderSide(color: Colors.white, width: 2.w),
        ),
      ),
      child: Text(
        '목록',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 48.sp,
          fontFamily: 'PretendardGOV',
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: 799.w,
      height: 100.h,
      decoration: BoxDecoration(
        color: Color(0xff0b1437),
        border: Border.all(color: Colors.white, width: 2.w),
      ),
      child: Row(
        children: [
          _headerCell('ID', 179, 54.63),
          SizedBox(width: 54.w),
          _headerCell('설치 위치', 163.4, 68.85),
          SizedBox(width: 70.6.w),
          _headerCell('연결', 100, 60),
          SizedBox(width: 49.w),
          _headerCell('이벤트', 100, 60),
        ],
      ),
    );
  }

  Widget _buildList(List items) {
    return Container(
      width: 799.w,
      height: 1332.h,
      decoration: BoxDecoration(
        color: Color(0xff0b1437),
        border: Border(
          left: BorderSide(color: Colors.white, width: 2.w),
          right: BorderSide(color: Colors.white, width: 2.w),
        ),
      ),
      child: ListView.separated(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = widget.selectedCamId == item.camId;

          return InkWell(
            onTap: () {
              widget.onCamSelected(item.camId);
              print('${item.camId}로 이동');
            },
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Container(
              height: 100.h,
              color: isSelected ? Colors.grey.withOpacity(0.3) : Colors.transparent, // ✅ 여기 추가
              child: Row(
                children: [
                  SizedBox(width: 32.w),
                  _dataCell(item.camId, 36, 192, 80),
                  SizedBox(width: 40.w),
                  _dataCell(item.location, 32, 160, 80),
                  SizedBox(width: 70.w),
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: item.isConnected
                          ? const Color(0xffdb3829)
                          : const Color(0xff3dc473),
                      border: item.isConnected
                          ? Border.all(color: const Color(0xff3dc473), width: 2.w)
                          : null,
                      borderRadius: BorderRadius.circular(32.r),
                    ),
                  ),
                  SizedBox(width: 100.w),
                  _dataCell(
                    item.eventState,
                    32,
                    140,
                    83,
                    color: item.eventState == '정상'
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => Container(
          height: 2.w,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    return Container(
      width: 799.w,
      height: 100.h,
      decoration: BoxDecoration(
        color: Color(0xff414c67),
        border: Border.all(color: Colors.white, width: 2.w),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: Colors.white, size: 40.w),
            onPressed: currentPage > 1
                ? () {
                    setState(() => currentPage--);
                  }
                : null,
          ),
          SizedBox(width: 20.w),
          Text(
            'page $currentPage of $totalPages',
            style: TextStyle(color: Colors.white, fontSize: 28.sp),
          ),
          SizedBox(width: 20.w),
          IconButton(
            icon: Icon(Icons.chevron_right, color: Colors.white, size: 40.w),
            onPressed: currentPage < totalPages
                ? () {
                    setState(() => currentPage++);
                  }
                : null,
          ),
        ],
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

  Widget _dataCell(String text, double fontSize, double width, double height,
      {Color? color}) {
    return Container(
      width: width.w,
      height: height.h,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(color: color ?? Colors.white, fontSize: fontSize.sp),
      ),
    );
  }
}
