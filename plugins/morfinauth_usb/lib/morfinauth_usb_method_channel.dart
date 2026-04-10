import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'morfinauth_usb_platform_interface.dart';

/// An implementation of [MorfinauthUsbPlatform] that uses method channels.
class MethodChannelMorfinauthUsb extends MorfinauthUsbPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('morfinauth_usb');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
