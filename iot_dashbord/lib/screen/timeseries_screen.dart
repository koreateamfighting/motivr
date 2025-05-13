import 'package:flutter/material.dart';
import 'package:iot_dashbord/component/base_layout.dart';
class TimeSeriesScreen extends StatelessWidget {
  const TimeSeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: Column(
        children: [
          Expanded(child: Container(color: Colors.orangeAccent)),
          Expanded(child: Container(color: Colors.pinkAccent)),
        ],
      ),
    );
  }
}
