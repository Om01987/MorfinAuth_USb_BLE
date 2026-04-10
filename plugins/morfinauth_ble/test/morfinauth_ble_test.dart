import 'package:flutter_test/flutter_test.dart';
import 'package:morfinauth_ble/morfinauth_ble.dart';
import 'package:morfinauth_ble/morfinauth_ble_platform_interface.dart';
import 'package:morfinauth_ble/morfinauth_ble_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMorfinauthBlePlatform
    with MockPlatformInterfaceMixin
    implements MorfinauthBlePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MorfinauthBlePlatform initialPlatform = MorfinauthBlePlatform.instance;

  test('$MethodChannelMorfinauthBle is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMorfinauthBle>());
  });

  test('getPlatformVersion', () async {
    MorfinauthBle morfinauthBlePlugin = MorfinauthBle();
    MockMorfinauthBlePlatform fakePlatform = MockMorfinauthBlePlatform();
    MorfinauthBlePlatform.instance = fakePlatform;

    expect(await morfinauthBlePlugin.getPlatformVersion(), '42');
  });
}
