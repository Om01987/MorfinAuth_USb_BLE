import 'dart:async';
import 'package:flutter/services.dart';

class MorfinauthBle {
  static const MethodChannel _methodChannel = MethodChannel('morfinauth_ble/commands');
  static const EventChannel _eventChannel = EventChannel('morfinauth_ble/events');

  /// Start discovering nearby BLE devices
  Future<int?> discoverDevices() async {
    return await _methodChannel.invokeMethod<int>('discoverDevices');
  }

  /// Stop discovering
  Future<int?> stopDiscover() async {
    return await _methodChannel.invokeMethod<int>('stopDiscover');
  }

  /// Connect to a specific BLE device using its MAC address
  Future<int?> connectDevice(String macAddress) async {
    return await _methodChannel.invokeMethod<int>('connectDevice', {
      'macAddress': macAddress,
    });
  }

  /// Disconnect the current device
  Future<int?> disconnectDevice() async {
    return await _methodChannel.invokeMethod<int>('disconnectDevice');
  }

  /// Initialize the connected BLE device
  Future<int?> initDevice() async {
    return await _methodChannel.invokeMethod<int>('initDevice');
  }

  /// Start fingerprint capture
  Future<int?> startCapture(int quality, int timeout) async {
    return await _methodChannel.invokeMethod<int>('startCapture', {
      'quality': quality,
      'timeout': timeout,
    });
  }

  /// Stop the ongoing capture
  Future<int?> stopCapture() async {
    return await _methodChannel.invokeMethod<int>('stopCapture');
  }

  /// This stream listens to all native events (Previews, Discovered Devices, Battery Warnings)
  Stream<dynamic> get bleEventStream {
    return _eventChannel.receiveBroadcastStream();
  }
}