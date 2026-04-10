
import 'morfinauth_core_platform_interface.dart';

class MorfinauthCore {
  Future<String?> getPlatformVersion() {
    return MorfinauthCorePlatform.instance.getPlatformVersion();
  }
}
