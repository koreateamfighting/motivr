import 'dart:html' as html;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class ImagePickerTextField extends StatefulWidget {
  final String title;
  final String hint;
  final double width;
  final double height;
  final String? initialFileName;
  final void Function(html.File)? onFileSelected;
  final bool enabled;

  const ImagePickerTextField({
    required this.title,
    required this.hint,
    required this.width,
    required this.height,
    this.initialFileName,
    required this.onFileSelected,
  this.enabled = true,
  });

  @override
  State<ImagePickerTextField> createState() => _ImagePickerTextFieldState();
}

class _ImagePickerTextFieldState extends State<ImagePickerTextField> {
  String? fileName;
  @override
  void initState() {
    super.initState();
    fileName = widget.initialFileName;
  }
  void _pickImage() {

    if (!widget.enabled) return; // ✅ 비활성화 시 업로드 금지

    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files.first;
        setState(() {
          fileName = file.name;
        });

        // ✅ 부모에게 선택된 파일 전달
        if (widget.onFileSelected != null) {
          widget.onFileSelected!(file);
        }
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !widget.enabled;
    return GestureDetector(
      onTap: _pickImage,
      child: Row(

        children: [
          SizedBox(
            width: 41.w,
          ),
          Container(
            width: 400.w,
            height: 50.h,
            alignment: Alignment.centerLeft,
            child:    Text(
              widget.title,
              style: TextStyle(
                fontFamily: 'PretendardGOV',
                fontSize: 36.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(width: 12.h),
          Container(
            width: widget.width.w,
            height: widget.height.h,
              decoration: BoxDecoration(
                color: isDisabled ? const Color(0xffe0e0e0) : Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
            padding:  EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  fileName ?? widget.hint,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'PretendardGOV',
                    color: isDisabled
                        ? Colors.grey.shade600
                        : (fileName == null ? Colors.grey : Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Spacer(),
                Container(
                  width: 40.w,
                  height: 40.h,
                  child: Image.asset('assets/icons/image.png'),
                ),
                SizedBox(width: 18.w,),
              ],
            )
          )
        ],
      ),
    );
  }
}
