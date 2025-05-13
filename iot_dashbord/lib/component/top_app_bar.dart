import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TopAppBar extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const TopAppBar({Key? key, this.onMenuPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3812.w,
      height: 100.h,
      color: const Color(0xff0b2144),
      child: Row(
        children: [
          SizedBox(width: 50.w),
          Transform.scale(
            scale: 1.6,
            child: SizedBox(
              width: 100.w,
              height: 100.h,
              child: IconButton(
                onPressed: onMenuPressed,
                icon: const Icon(Icons.menu_rounded),
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 120.w),
          Text(
            'Digital Twin CMS',
            style: TextStyle(
              fontFamily: 'PretendardGOV',
              fontWeight: FontWeight.w800,
              fontSize: 40.sp,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Transform.scale(
                scale: 1.5,
                child: SizedBox(
                  width: 100.w,
                  height: 100.h,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.people_alt_outlined),
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 36.w),
              Container(
                width: 300.w,
                height: 100.h,
                child: Image.asset(
                  'assets/images/company_logo.png',
                  fit: BoxFit.fill,
                ),
              ),
            ],
          )

        ],
      ),
    );
  }
}
