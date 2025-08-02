// import 'dart:developer';
// import 'dart:io';
// import 'package:camerawesome/camerawesome_plugin.dart';
// import 'package:camerawesome/pigeon.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
//
// class CameraPage extends StatelessWidget {
//   const CameraPage({super.key});
//
//   @override
//   Widget build(BuildContext context){
//     return Scaffold(
//       body: Container(
//         color: Colors.white,
//         child: CameraAwesomeBuilder.awesome(
//           saveConfig: SaveConfig.photo(
//             //initialCaptureMode: CaptureMode.photo,
//             mirrorFrontCamera: true,
//             pathBuilder:(sensors) async {
//               final Directory extDir = await getTemporaryDirectory();
//               final testDir = await Directory(
//                 '${extDir.path}/camerawesome',
//               ).create(recursive: true);
//               if (sensors.length == 1){
//                 final String filePath =
//                     '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
//                 return SingleCaptureRequest(filePath, sensors.first);
//               } else {
//                 // Separate pictures taken with front and back camera
//                 return MultipleCaptureRequest(
//                   {
//                     for (final sensor in sensors)
//                       sensor:
//                       '${testDir.path}/${sensor.position == SensorPosition.front ? 'front_' : "back_"}${DateTime.now().millisecondsSinceEpoch}.jpg',
//                   },
//                 );
//               }
//             },
//
//             exifPreferences: ExifPreferences(saveGPSLocation: true),
//           ),
//           sensorConfig: SensorConfig.single(
//             sensor: Sensor.position(SensorPosition.back),
//             flashMode: FlashMode.auto,
//             aspectRatio: CameraAspectRatios.ratio_4_3,
//             zoom: 0.0,
//           ),
//           enablePhysicalButton: true,
//           // filter: AwesomeFilter.AddictiveRed,
//           previewFit: CameraPreviewFit.contain,
//           onMediaTap: (mediaCapture) {
//             mediaCapture.captureRequest.when(
//               single: (single) {
//                 debugPrint('single: ${single.file?.path}');
//                 single.file?.openRead();
//               },
//               multiple: (multiple){
//                 multiple.fileBySensor.forEach((key, value) {
//                   log('multiple file taken: $key ${value?.path}');
//                   value?.openRead();
//                 });
//               },
//             );
//           },
//           availableFilters: awesomePresetFiltersList,
//         ),
//       ),
//     );
//   }
// }