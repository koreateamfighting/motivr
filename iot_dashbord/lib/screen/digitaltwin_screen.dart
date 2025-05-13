import 'package:flutter/material.dart';
import 'package:iot_dashbord/component/base_layout.dart';
class DigitalTwinScreen extends StatelessWidget {
  const DigitalTwinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: Column(
        children: [
          Expanded(child: Container(color: Colors.green)),
          Expanded(child: Container(color: Colors.purple)),
        ],
      ),
    );
  }
}
