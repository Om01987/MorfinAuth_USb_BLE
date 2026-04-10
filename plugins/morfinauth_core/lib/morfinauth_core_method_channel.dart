import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'morfinauth_core_platform_interface.dart';

/// An implementation of [MorfinauthCorePlatform] that uses method channels.
class MethodChannelMorfinauthCore extends MorfinauthCorePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('morfinauth_core');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
