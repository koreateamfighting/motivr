import 'dart:html' as html;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class ImagePickerTextField extends StatefulWidget {
  final String title;
  final String hint;
  final double width;
  final double height;
  final void Function(html.File)? onFileSelected;

  const ImagePickerTextField({
    required this.title,
    required this.hint,
    required this.width,
    required this.height,
    required this.onFileSelected,

  });

  @override
  State<ImagePickerTextField> createState() => _ImagePickerTextFieldState();
}

class _ImagePickerTextFieldState extends State<ImagePickerTextField> {
  String? fileName;


  void _pickImage() {
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
    return GestureDetector(
      onTap: _pickImage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontFamily: 'PretendardGOV',
              fontSize: 24.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            width: widget.width.w,
            height: widget.height.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding:  EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  fileName ?? widget.hint,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'PretendardGOV',
                    color: fileName == null ? Colors.grey : Colors.black,
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
