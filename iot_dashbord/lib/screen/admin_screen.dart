// admin_screen.dart
import 'package:flutter/material.dart';
import 'package:iot_dashbord/component/base_layout.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: Column(
        children: [
          Expanded(child: Container(color: Colors.red)),
          Expanded(child: Container(color: Colors.blue)),
        ],
      ),
    );
  }
}
