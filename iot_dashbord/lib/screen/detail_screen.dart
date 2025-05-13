import 'package:flutter/material.dart';
import 'package:iot_dashbord/component/base_layout.dart';
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: Column(
        children: [
          Expanded(child: Container(color: Colors.grey)),
          Expanded(child: Container(color: Colors.indigo)),
        ],
      ),
    );
  }
}
