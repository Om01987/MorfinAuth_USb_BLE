import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:morfinauth_ble/morfinauth_ble.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';

import '../enums/ImageFormatType.dart';
import '../enums/TemplateFormatType.dart';
import '../helper/CommonWidget.dart';
import '../helper/Constants.dart';
import '../helper/DeviceInfo.dart';
import '../helper/SharePreferenceHelper.dart';
import '../provider/DeviceInfoProvider.dart';
import '../provider/SettingProvider.dart';
import 'helper/BottomNavigationDialogListener.dart';

class BleCapturePage extends StatefulWidget {
  const BleCapturePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => BleCapturePageState();
}

enum ScannerAction { Capture, MatchISO, MatchAnsi }

class BleCapturePageState extends State<BleCapturePage> implements BottomDialogRefreshListener {
  final MorfinauthBle _morfinauthBlePlugin = MorfinauthBle();
  final _focusNode = FocusNode();

  String deviceInfo = "Device Status: Connected (BLE)";
  String messsageText = "Ready to Capture";
  bool isMessageError = false;

  // Image Display States: 0 = Lottie Animation, 1 = Raw Bytes
  int displayImage = 0;
  Uint8List? byteImage;
  StreamSubscription? _imageStreamSub;

  late SharePreferenceHelper sharePreferenceHelper;
  DeviceInfo? deviceInfoObject;

  // Dropdown States
  String _selectedImageFormat = "BMP";
  String _selectedTemplateFormat = "FMR V2005";

  String? selectedValue1 = 'BMP';
  String? selectedValue2 = 'FMR V2005';

  final String FMR_V2005 = 'FMR V2005';
  final String FMR_V2011 = 'FMR V2011';
  final String ANSI_V378 = 'ANSI V378';

  List<String> imageFormatDropdown = ["BMP", "JPEG2000", "WSQ", "RAW", "FIRV_2005", "FIRV_2011", "FIRWSQ_V2005", "FIRWSQ_V2011", "FIRJPEG_V2005", "FIRJPEG_V2011"];
  List<String> templateFormatDropdown = ['FMR V2005', "FMR V2011", "ANSI V378"];

  TextEditingController imageQualityController = TextEditingController(text: '60');
  TextEditingController timeoutController = TextEditingController(text: '10000');

  ScannerAction scannerAction = ScannerAction.Capture;

  int timeout = 10000;
  int minQuality = 60;
  int templateType = 0;
  int imageType = 0;

  // Format mapped to BLE SDK CaptureFormat Enum
  int bleCaptureFormatInt = 1; // Default FIR_2005

  Uint8List? lastCapFingerData;
  bool isStopCapture = false;
  int okCapture = 0;

  @override
  void initState() {
    super.initState();
    sharePreferenceHelper = SharePreferenceHelper();
    _setupBleImageStream();

    // Fetch initial device name from provider
    String deviceName = Provider.of<DeviceInfoProvider>(context, listen: false).deviceNameStatus;
    if (deviceName.isNotEmpty) {
      deviceInfo = deviceName;
    }

    _loadSettingsFromProvider();
  }

  void _loadSettingsFromProvider() {
    minQuality = Provider.of<SettingProvider>(context, listen: false).getQuality();
    timeout = Provider.of<SettingProvider>(context, listen: false).getTimeOut();
    imageType = Provider.of<SettingProvider>(context, listen: false).getImageType();
    templateType = Provider.of<SettingProvider>(context, listen: false).getTemplateType();

    if (timeout == -1) timeout = 10000;
    if (minQuality == -1) minQuality = 60;

    timeoutController.text = timeout.toString();
    imageQualityController.text = minQuality.toString();

    // Mapping Template Type
    if (templateType != -1) {
      if (templateType == TemplateFormatType.FMR_V2005.index) selectedValue2 = FMR_V2005;
      else if (templateType == TemplateFormatType.FMR_V2011.index) selectedValue2 = FMR_V2011;
      else if (templateType == TemplateFormatType.ANSI_V378.index) selectedValue2 = ANSI_V378;
    }

    // Mapping Image Type
    if (imageType != -1) {
      if (imageType == ImageFormatType.BMP.index) selectedValue1 = "BMP";
      else if (imageType == ImageFormatType.JPEG2000.index) selectedValue1 = "JPEG2000";
      else if (imageType == ImageFormatType.WSQ.index) selectedValue1 = "WSQ";
      else if (imageType == ImageFormatType.RAW.index) selectedValue1 = "RAW";
      else if (imageType == ImageFormatType.FIR_V2005.index) selectedValue1 = "FIRV_2005";
      else if (imageType == ImageFormatType.FIR_V2011.index) selectedValue1 = "FIRV_2011";
    }
  }

  void _setupBleImageStream() {
    _imageStreamSub = _morfinauthBlePlugin.imageStream.listen((Uint8List incomingImageBytes) {
      if (mounted) {
        setState(() {
          displayImage = 1;
          byteImage = incomingImageBytes;
        });
      }
    }, onError: (error) {
      setLogs("Image Stream Error: $error", true);
    });
  }

  Future<void> StartCapture() async {
    FocusScope.of(context).requestFocus(_focusNode);
    validateValues();
    qualitySaved();
    timeoutValueSaved();

    setState(() {
      displayImage = 0;
      byteImage = null;
      okCapture = 1;
    });

    scannerAction = ScannerAction.Capture;
    setLogs("Starting Capture... Please place finger on scanner.", false);

    try {
      // Map format string to your BLE Plugin's format integer
      _mapFormatToBleInt();

      // Blocking call waiting for BLE Native SDK to finish capturing
      Map<String, dynamic> result = await _morfinauthBlePlugin.startCapture(bleCaptureFormatInt, minQuality, timeout);

      if (result['status'] == 0) {
        setLogs("Capture Success. Quality: ${result['quality']} NFIQ: ${result['nfiq']}", false);

        // Fetch the extracted template from SDK for matching/saving later
        // NOTE: Make sure getTemplate() is exposed in your morfinauth_ble.dart
        /*
        Map<String, dynamic> templateData = await _morfinauthBlePlugin.getTemplate(templateType);
        if (templateData['status'] == 0) {
          lastCapFingerData = templateData['templateBytes'];
        }
        */

      } else {
        setLogs("Capture Failed or Timed Out (Status: ${result['status']})", true);
      }
    } catch (e) {
      setLogs("Error starting capture: $e", true);
      okCapture = 0;
    }
  }

  Future<void> AutoCapture() async {
    // For BLE, AutoCapture usually invokes the same StartCapture workflow internally
    // depending on the Native SDK implementation. We trigger the same UI flow.
    StartCapture();
  }

  Future<void> StopCapture() async {
    FocusScope.of(context).requestFocus(_focusNode);
    try {
      await _morfinauthBlePlugin.stopCapture();
      setLogs("Capture Stopped.", false);
      okCapture = 0;
    } catch (e) {
      setLogs("Error stopping capture.", true);
    }
  }

  Future<void> MatchFinger() async {
    FocusScope.of(context).requestFocus(_focusNode);

    if (okCapture == 0 || lastCapFingerData == null) {
      setLogs("Please run Start Capture first!", true);
      return;
    }

    setLogs("Match Started. Please put finger on scanner.", false);
    setState(() { displayImage = 0; });

    try {
      // 1. Capture new finger
      Map<String, dynamic> captureResult = await _morfinauthBlePlugin.startCapture(bleCaptureFormatInt, minQuality, timeout);

      if (captureResult['status'] == 0) {
        // 2. Perform Match
        // NOTE: Make sure matchTemplate() is exposed in your morfinauth_ble.dart
        /*
        int matchScore = await _morfinauthBlePlugin.matchTemplate(lastCapFingerData!, templateType);
        if (matchScore >= 96) {
          setLogs("Finger matched with score: $matchScore", false);
        } else {
          setLogs("Finger not matched, score: $matchScore", true);
        }
        */
        setLogs("Match feature requires native implementation mapping", false); // Placeholder until mapped
      } else {
        setLogs("Capture for match failed.", true);
      }
    } catch (e) {
      setLogs("Error matching: $e", true);
    }
  }

  void SaveImageAndTemplate() async {
    FocusScope.of(context).requestFocus(_focusNode);
    if (byteImage == null) {
      setLogs("Please run Start Capture first to get an image!", true);
      return;
    }

    try {
      // Save Image
      String imageExt = selectedValue1 == "WSQ" ? ".wsq" : selectedValue1 == "JPEG2000" ? ".jp2" : selectedValue1 == "RAW" ? ".raw" : ".bmp";
      await WriteFile("Image", "FingerImage$imageExt", byteImage!);

      // Save Template
      if (lastCapFingerData != null) {
        String templateExt = selectedValue2 == FMR_V2005 ? "2005.iso" : selectedValue2 == FMR_V2011 ? "2011.iso" : "ANSI.iso";
        await WriteFile("Template", "FingerTemplate_$templateExt", lastCapFingerData!);
        setLogs("Image & Template Saved Successfully", false);
      } else {
        setLogs("Image Saved, but no template available.", false);
      }
    } catch (e) {
      setLogs("Error Saving: $e", true);
    }
  }

  Future<void> WriteFile(String folder, String filename, Uint8List data) async {
    try {
      final directory = await getExternalStorageDirectory();
      final dirPath = '${directory?.path}/FingerData/$folder/$filename';
      File file = File(dirPath);
      await file.create(recursive: true);
      await file.writeAsBytes(data);
    } catch (e) {
      print("WriteFile Error: $e");
    }
  }

  void validateValues() {
    minQuality = int.tryParse(imageQualityController.text) ?? 60;
    timeout = int.tryParse(timeoutController.text) ?? 10000;
    if (minQuality < 1 || minQuality > 100) imageQualityController.text = '60';
    if (timeout < 10000) timeoutController.text = '10000';
  }

  void qualitySaved() {
    Provider.of<SettingProvider>(context, listen: false).setQuality(minQuality);
  }

  void timeoutValueSaved() {
    Provider.of<SettingProvider>(context, listen: false).settimeOut(timeout);
  }

  void _mapFormatToBleInt() {
    // Example mapping based on Native CaptureFormat Enum
    if (selectedValue2 == FMR_V2005) bleCaptureFormatInt = 1;
    else if (selectedValue2 == FMR_V2011) bleCaptureFormatInt = 2;
    else if (selectedValue2 == ANSI_V378) bleCaptureFormatInt = 3;
  }

  void setLogs(String errorMessage, bool isError) {
    if (mounted) {
      setState(() {
        messsageText = errorMessage;
        isMessageError = isError;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    imageQualityController.dispose();
    timeoutController.dispose();
    _imageStreamSub?.cancel();
    super.dispose();
  }

  @override
  void BottomDialogRefresh(bool isRefresh) {
    if (isRefresh) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<DeviceInfoProvider>(context, listen: false).setDeviceNameStatus(deviceInfo);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("BLE Capture Page")),
      bottomNavigationBar: CommonWidget.getBottomNavigationWidget(context, deviceInfo, this),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: imageQualityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Min Quality [1-100]', labelStyle: TextStyle(fontWeight: FontWeight.bold)),
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: timeoutController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'TIMEOUT (ms)', labelStyle: TextStyle(fontWeight: FontWeight.bold)),
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15.0),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Image Format', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10.0),
                            Container(
                              decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 2.0), borderRadius: BorderRadius.circular(8.0)),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedValue1,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedValue1 = newValue!;
                                    imageType = imageFormatDropdown.indexOf(newValue);
                                  });
                                },
                                items: imageFormatDropdown.map((String value) => DropdownMenuItem<String>(value: value, child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text(value, style: const TextStyle(color: Colors.blue))))).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Template Format', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10.0),
                            Container(
                              decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 2.0), borderRadius: BorderRadius.circular(8.0)),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedValue2,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedValue2 = newValue!;
                                    templateType = templateFormatDropdown.indexOf(newValue);
                                  });
                                },
                                items: templateFormatDropdown.map((String value) => DropdownMenuItem<String>(value: value, child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text(value, style: const TextStyle(color: Colors.blue))))).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25.0),
                  const Text('Perform Operations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  Row(
                    children: <Widget>[
                      Expanded(child: ElevatedButton(onPressed: StartCapture, child: const Text('Start Capture'))),
                      const SizedBox(width: 5.0),
                      Expanded(child: ElevatedButton(onPressed: AutoCapture, child: const Text('Auto Capture'))),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  Row(
                    children: <Widget>[
                      Expanded(child: ElevatedButton(onPressed: StopCapture, child: const Text('Stop Capture'))),
                      const SizedBox(width: 5.0),
                      Expanded(child: ElevatedButton(onPressed: MatchFinger, child: const Text('Match Finger'))),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  Row(
                    children: <Widget>[
                      Expanded(child: ElevatedButton(onPressed: SaveImageAndTemplate, child: const Text('Save Image and Template'))),
                    ],
                  ),
                  const SizedBox(height: 15.0),
                  const Text('Fingerprint Preview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    height: 250,
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0), side: const BorderSide(color: Colors.blue, width: 3.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(messsageText, style: TextStyle(color: isMessageError ? Colors.red : Colors.blue, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            Expanded(child: onImageDynamic()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget onImageDynamic() {
    if (displayImage == 0 || byteImage == null) {
      return Lottie.asset('assets/animations/fingerprint.json', width: 200, height: 200, fit: BoxFit.contain);
    } else {
      return Image.memory(byteImage!, width: 250.0, height: 200.0, fit: BoxFit.contain);
    }
  }
}