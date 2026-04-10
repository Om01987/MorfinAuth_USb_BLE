
import 'morfinauth_usb_platform_interface.dart';

class MorfinauthUsb {
  Future<String?> getPlatformVersion() {
    return MorfinauthUsbPlatform.instance.getPlatformVersion();
  }
}
