import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'morfinauth_core_method_channel.dart';

abstract class MorfinauthCorePlatform extends PlatformInterface {
  /// Constructs a MorfinauthCorePlatform.
  MorfinauthCorePlatform() : super(token: _token);

  static final Object _token = Object();

  static MorfinauthCorePlatform _instance = MethodChannelMorfinauthCore();

  /// The default instance of [MorfinauthCorePlatform] to use.
  ///
  /// Defaults to [MethodChannelMorfinauthCore].
  static MorfinauthCorePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MorfinauthCorePlatform] when
  /// they register themselves.
  static set instance(MorfinauthCorePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
