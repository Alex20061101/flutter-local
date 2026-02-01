import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
  runApp(const MaterialApp(
    home: HomeScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Default to CPU because Note 8 GPU might be unstable with Int8
  bool useGpu = false; 

  // Default model (must match a key in the map below)
  String selectedModel = 'yolov8n_320.tflite'; 

  // MAP: Display Name -> Filename
  // These match your 'tree' output exactly.
  final Map<String, String> models = {
    '160x160 (Max FPS)':  'yolov8n_160.tflite',
    '192x192 (Fast)':     'yolov8n_192.tflite',
    '256x256 (Balanced)': 'yolov8n_256.tflite',
    '320x320 (Standard)': 'yolov8n_320.tflite',
    '416x416 (High Res)': 'yolov8n_416.tflite',
    '640x640 (Max Res)':  'yolov8n_640.tflite',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("YOLO Performance Lab"), backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Resolution / Speed:", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),
            
            // MODEL SELECTOR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8)
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedModel,
                  isExpanded: true,
                  items: models.entries.map((e) {
                    return DropdownMenuItem(value: e.value, child: Text(e.key));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedModel = val);
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // GPU TOGGLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Use GPU", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("May crash older phones", style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                  ],
                ),
                Switch(
                  value: useGpu,
                  activeColor: Colors.green,
                  onChanged: (val) => setState(() => useGpu = val),
                ),
              ],
            ),
            
            const SizedBox(height: 50),
            
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text("START TEST"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetectionScreen(
                      modelPath: selectedModel,
                      useGpu: useGpu,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DetectionScreen extends StatefulWidget {
  final String modelPath;
  final bool useGpu;

  const DetectionScreen({super.key, required this.modelPath, required this.useGpu});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  DateTime? lastFrameTime;
  double currentFps = 0.0;
  int objectCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          YOLOView(
            modelPath: widget.modelPath,
            task: YOLOTask.detect,
            useGpu: widget.useGpu,
            onResult: (results) {
              final now = DateTime.now();
              if (lastFrameTime != null) {
                final delta = now.difference(lastFrameTime!).inMilliseconds;
                if (delta > 0) {
                  final fps = 1000 / delta;
                  if (mounted) {
                    setState(() {
                      currentFps = fps;
                      objectCount = results.length;
                    });
                  }
                }
              }
              lastFrameTime = now;
            },
          ),
          
          // HUD Overlay
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "FPS: ${currentFps.toStringAsFixed(1)}",
                          style: TextStyle(
                            color: currentFps > 15 ? Colors.greenAccent : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Objects: $objectCount",
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}