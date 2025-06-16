import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iot_dashboard/utils/keyboard_handler.dart';
import 'package:markdown/markdown.dart' as md;
import 'dart:convert';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  static const designWidth = 3812;
  static const designHeight = 2144;

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  TextSpan? _markdownSpan;
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
    final String rawText = await rootBundle.loadString('assets/texts/privacy_policy.txt');

    final processedText = rawText
        .replaceAll('&quot;', '"')
        .replaceAll(r'\n', '\n')
        .replaceAllMapped(RegExp(r'(?<!#)#?\s*\$'), (match) => '')
        .split('\n')
        .map((line) {
      if (line.trim().startsWith('##')) {
        return '\n${line.trim()}';
      } else {
        return '${line.trim()}  ';
      }
    })
        .join('\n');

    final document = md.Document();
    final lines = LineSplitter().convert(processedText);
    final nodes = document.parseLines(lines);

    final span = TextSpan(
      children: nodes.map((node) {
        if (node is md.Element && node.tag == 'h2') {
          return TextSpan(
            text: '\n${node.textContent}\n',
            style: TextStyle(
              fontSize: 40.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'PretendardGOV',
              color: Colors.black,
            ),
          );
        } else {
          return TextSpan(
            text: '${node.textContent}\n',
            style: TextStyle(
              fontSize: 36.sp,
              fontFamily: 'PretendardGOV',
              fontWeight: FontWeight.w400,
              color: const Color(0xff505050),
            ),
          );
        }
      }).toList(),
    );

    setState(() {
      _markdownSpan = span;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize:  Size(
        PrivacyPolicyPage.designWidth.toDouble(),
        PrivacyPolicyPage.designHeight.toDouble(),
      ),
      builder: (context, child) {
        return RawKeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKey: (event) => handleEscapeKey(event, context),
          child: WillPopScope(
            onWillPop: () async {
              Navigator.of(context).pop();
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
                        child: _markdownSpan == null
                            ? const Center(child: CircularProgressIndicator())
                            : Padding(
                          padding: EdgeInsets.symmetric(horizontal: 577.w),
                          child: SingleChildScrollView(
                            child: SelectableText.rich(_markdownSpan!),
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
              '개인정보처리방침',
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
