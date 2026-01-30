import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Request camera permission
  await Permission.camera.request();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YOLO Object Detector',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const YOLODetectionScreen(),
    );
  }
}

class YOLODetectionScreen extends StatefulWidget {
  const YOLODetectionScreen({super.key});

  @override
  State<YOLODetectionScreen> createState() => _YOLODetectionScreenState();
}

class _YOLODetectionScreenState extends State<YOLODetectionScreen> {
  int detectedObjects = 0;
  String lastDetection = 'Waiting...';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YOLO Real-Time Detection'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          // YOLO Camera View with object detection
          YOLOView(
            modelPath: 'assets/models/yolov8n.tflite',
            task: YOLOTask.detect,
            onResult: (results) {
              setState(() {
                detectedObjects = results.length;
                if (results.isNotEmpty) {
                  lastDetection = results
                      .map((r) => '${r.className}: ${(r.confidence * 100).toStringAsFixed(0)}%')
                      .join(', ');
                } else {
                  lastDetection = 'No objects detected';
                }
              });
            },
          ),
          
          // Detection info overlay
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Objects detected: $detectedObjects',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastDetection,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
