import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunar_freelook/src/ui/proxy_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lunar Client Freelook',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProxyScreen(title: 'Lunar Client Freelook'),
    );
  }
}
