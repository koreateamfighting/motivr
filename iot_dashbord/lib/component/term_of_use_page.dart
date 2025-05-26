import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import 'package:iot_dashboard/utils/keyboard_handler.dart';

class TermOfUsePage extends StatefulWidget {
  const TermOfUsePage({super.key});

  static const designWidth = 3812;
  static const designHeight = 2144;

  @override
  State<TermOfUsePage> createState() => _TermOfUsePageState();
}

class _TermOfUsePageState extends State<TermOfUsePage> {
  String _markdownText = '';
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadMarkdown();
  }
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadMarkdown() async {
    final String rawText = await rootBundle.loadString('assets/texts/term_of_use.txt');

    final processedText = rawText
        .replaceAllMapped(RegExp(r'(?<!#)#?\s*$'), (match) => '') // 불필요한 공백 제거
        .split('\n') // 줄 단위로 나누고
        .map((line) {
      if (line.trim().startsWith('##')) {
        return '\n${line.trim()}'; // 제목은 그대로
      } else {
        return '${line.trim()}  '; // 일반 줄에는 마크다운 줄바꿈(공백 2칸)
      }
    })
        .join('\n');

    setState(() {
      _markdownText = processedText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(TermOfUsePage.designWidth.toDouble(), TermOfUsePage.designHeight.toDouble()),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return RawKeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKey: (event) {
            handleEscapeKey(event, context); // ESC → 닫기
          },
          child: WillPopScope(
            onWillPop: () async {
              Navigator.of(context).pop(); // ESC 닫기 (브라우저 back 대응)
              return false;
            },
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: 3664.w,
                  height: 2746.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    children: [
                      _buildHeader(context),
                      Expanded(
                        child: _markdownText.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : Container(
                          padding: EdgeInsets.only(left: 577.w, right: 587.w),
                          child: Markdown(
                            data: _markdownText,
                            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                              p: TextStyle(fontSize: 36.sp, fontFamily: 'PretendardGOV', fontWeight: FontWeight.w400, color: Color(0xff505050)),
                              h1: TextStyle(fontSize: 48.sp, fontFamily: 'PretendardGOV', fontWeight: FontWeight.w500, color: Color(0xff000000)),
                              h2: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.bold),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: 3664.w,
      height: 100.h,
      color: const Color(0xff0b1437),
      child: Row(
        children: [
          SizedBox(width: 1509.w),
          Container(
            width: 646.w,
            alignment: Alignment.center,
            child: Text(
              '이용약관',
              style: TextStyle(
                fontFamily: 'PretendardGOV',
                fontWeight: FontWeight.w700,
                fontSize: 64.sp,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 70.w,
              height: 70.h,
              padding: EdgeInsets.all(10.w),
              child: Image.asset('assets/icons/close.png'),
            ),
          ),
          SizedBox(width: 27.w),
        ],
      ),
    );
  }
}
