import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/DeviceInfoProvider.dart';
import 'provider/SettingProvider.dart';
import 'provider/clientKeyProvider.dart';
import 'connection_mode_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: DeviceInfoProvider()),
        ChangeNotifierProvider.value(value: SettingProvider()),
        ChangeNotifierProvider.value(value: clientKeyProvider()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Morfin Auth',
        home: ConnectionModeScreen(),
      ),
    ),
  );
}