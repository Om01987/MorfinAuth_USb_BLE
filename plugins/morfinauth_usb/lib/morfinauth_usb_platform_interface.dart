import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'morfinauth_usb_method_channel.dart';

abstract class MorfinauthUsbPlatform extends PlatformInterface {
  /// Constructs a MorfinauthUsbPlatform.
  MorfinauthUsbPlatform() : super(token: _token);

  static final Object _token = Object();

  static MorfinauthUsbPlatform _instance = MethodChannelMorfinauthUsb();

  /// The default instance of [MorfinauthUsbPlatform] to use.
  ///
  /// Defaults to [MethodChannelMorfinauthUsb].
  static MorfinauthUsbPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MorfinauthUsbPlatform] when
  /// they register themselves.
  static set instance(MorfinauthUsbPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
