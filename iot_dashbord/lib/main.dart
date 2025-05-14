import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'services/router.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(

      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
