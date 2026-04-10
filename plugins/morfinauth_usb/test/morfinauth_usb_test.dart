import 'package:flutter_test/flutter_test.dart';
import 'package:morfinauth_usb/morfinauth_usb.dart';
import 'package:morfinauth_usb/morfinauth_usb_platform_interface.dart';
import 'package:morfinauth_usb/morfinauth_usb_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMorfinauthUsbPlatform
    with MockPlatformInterfaceMixin
    implements MorfinauthUsbPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MorfinauthUsbPlatform initialPlatform = MorfinauthUsbPlatform.instance;

  test('$MethodChannelMorfinauthUsb is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMorfinauthUsb>());
  });

  test('getPlatformVersion', () async {
    MorfinauthUsb morfinauthUsbPlugin = MorfinauthUsb();
    MockMorfinauthUsbPlatform fakePlatform = MockMorfinauthUsbPlatform();
    MorfinauthUsbPlatform.instance = fakePlatform;

    expect(await morfinauthUsbPlugin.getPlatformVersion(), '42');
  });
}
