import 'package:flutter/material.dart';
import 'usb_screen.dart';
import 'ble_screen.dart';

class ConnectionModeScreen extends StatelessWidget {
  const ConnectionModeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Select Connection Mode'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/company_logo.png', width: 250.0),
            const SizedBox(height: 60.0),

            // USB Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 60),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              icon: const Icon(Icons.usb, size: 28),
              label: const Text(
                'USB CONNECTION',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UsbScreen()),
                );
              },
            ),

            const SizedBox(height: 30.0),

            // BLE Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 60),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              icon: const Icon(Icons.bluetooth, size: 28),
              label: const Text(
                'BLE CONNECTION',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BleScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}