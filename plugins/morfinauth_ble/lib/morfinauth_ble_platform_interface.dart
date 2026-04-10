import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'morfinauth_ble_method_channel.dart';

abstract class MorfinauthBlePlatform extends PlatformInterface {
  /// Constructs a MorfinauthBlePlatform.
  MorfinauthBlePlatform() : super(token: _token);

  static final Object _token = Object();

  static MorfinauthBlePlatform _instance = MethodChannelMorfinauthBle();

  /// The default instance of [MorfinauthBlePlatform] to use.
  ///
  /// Defaults to [MethodChannelMorfinauthBle].
  static MorfinauthBlePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MorfinauthBlePlatform] when
  /// they register themselves.
  static set instance(MorfinauthBlePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
