import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Request camera permission
  await Permission.camera.request();

  runApp(const MaterialApp(
    home: CameraApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("YOLOv8 Detection"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<PermissionStatus>(
        future: Permission.camera.status,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.data?.isGranted != true) {
            return const Center(child: Text("Camera permission required"));
          }

          return YOLOView(
            // Since we put these in android/app/src/main/assets, 
            // the native side often expects just the filename.
            modelPath: 'yolov8n_quant.tflite',
            task: YOLOTask.detect,
            useGpu: true,
            onResult: (results) {
              if (results.isNotEmpty) {
                final firstResult = results.first;
                debugPrint('Detected ${results.length} objects. First class index: ${firstResult.classIndex}');
              }
            },
          );
        },
      ),
    );
  }
}