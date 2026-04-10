import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morfinauth_usb/morfinauth_usb_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelMorfinauthUsb platform = MethodChannelMorfinauthUsb();
  const MethodChannel channel = MethodChannel('morfinauth_usb');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
