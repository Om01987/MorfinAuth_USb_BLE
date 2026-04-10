import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'morfinauth_ble_platform_interface.dart';

/// An implementation of [MorfinauthBlePlatform] that uses method channels.
class MethodChannelMorfinauthBle extends MorfinauthBlePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('morfinauth_ble');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
