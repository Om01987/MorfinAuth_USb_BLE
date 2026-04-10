import 'package:flutter_test/flutter_test.dart';
import 'package:morfinauth_core/morfinauth_core.dart';
import 'package:morfinauth_core/morfinauth_core_platform_interface.dart';
import 'package:morfinauth_core/morfinauth_core_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMorfinauthCorePlatform
    with MockPlatformInterfaceMixin
    implements MorfinauthCorePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MorfinauthCorePlatform initialPlatform = MorfinauthCorePlatform.instance;

  test('$MethodChannelMorfinauthCore is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMorfinauthCore>());
  });

  test('getPlatformVersion', () async {
    MorfinauthCore morfinauthCorePlugin = MorfinauthCore();
    MockMorfinauthCorePlatform fakePlatform = MockMorfinauthCorePlatform();
    MorfinauthCorePlatform.instance = fakePlatform;

    expect(await morfinauthCorePlugin.getPlatformVersion(), '42');
  });
}
