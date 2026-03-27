import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan/app/app.dart';
import 'package:flutter/material.dart';
import 'package:smartscan/core/di/service_locator.dart';

Future<void> bootstrap() async {
  await configureDependencies();
  runApp(const ProviderScope(child: SmartScanApp()));
}
