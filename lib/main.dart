import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_vision/flutter_vision.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  debugPrint("=== FOUND ${cameras.length} CAMERAS ===");
  for (int i = 0; i < cameras.length; i++) {
    debugPrint("Camera $i: ${cameras[i].name} (${cameras[i].lensDirection})");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YOLO Object Detection',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const YoloVideo(),
    );
  }
}

class YoloVideo extends StatefulWidget {
  const YoloVideo({super.key});

  @override
  State<YoloVideo> createState() => _YoloVideoState();
}

class _YoloVideoState extends State<YoloVideo> {
  late CameraController controller;
  late FlutterVision vision;
  List<Map<String, dynamic>> yoloResults = [];
  CameraImage? cameraImage;
  bool isLoaded = false;
  bool isDetecting = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    vision = FlutterVision();
    try {
      // await loadYoloModel();
      
      if (cameras.isEmpty) {
        setState(() {
          errorMessage = "No cameras found.";
        });
        return;
      }

      // 1. Better Camera Selection Logic
      // Try to find a back camera, otherwise use the first one available.
      // On web, sometimes the first entry is weird (like audio-only or virtual),
      // so we prioritize standard inputs.
      CameraDescription? selectedCamera;
      for (var camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.back) {
          selectedCamera = camera;
          break;
        }
      }
      selectedCamera ??= cameras.first;

      // 2. Initialize Controller with Fallback
      // We start with 'max' which usually works best on Web (browser decides).
      // If that fails, the catch block handles it.
      controller = CameraController(
        selectedCamera,
        ResolutionPreset.max, 
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420, // Explicitly set format for Web
      );

      await controller.initialize();

      if (mounted) {
        setState(() {
          isLoaded = true;
        });
      }
    } catch (e) {
      debugPrint("Initialization Error: $e");
      if (mounted) {
        setState(() {
          errorMessage = "Camera Error: $e";
        });
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    vision.closeYoloModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 3. Error UI
    // If initialization failed, show the error instead of a white screen
    if (errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      );
    }

    if (!isLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
          ...displayBoxesAroundRecognizedObjects(
            MediaQuery.of(context).size,
          ),
          Positioned(
            bottom: 75,
            width: MediaQuery.of(context).size.width,
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    width: 5, color: Colors.white, style: BorderStyle.solid),
              ),
              child: isDetecting
                  ? IconButton(
                      onPressed: stopDetection,
                      icon: const Icon(
                        Icons.stop,
                        color: Colors.red,
                        size: 50,
                      ),
                      iconSize: 50,
                    )
                  : IconButton(
                      onPressed: startDetection,
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 50,
                      ),
                      iconSize: 50,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadYoloModel() async {
    debugPrint("Loading YOLO model...");
    await vision.loadYoloModel(
      labels: 'assets/models/labels.txt',
      modelPath: 'assets/models/yolov8n.tflite',
      modelVersion: "yolov8",
      quantization: false,
      numThreads: 1,
      useGpu: false, // Turned off GPU for Web stability
    );
    debugPrint("YOLO model LOADED successfully!");
  }

  Future<void> startDetection() async {
    setState(() {
      isDetecting = true;
    });
    if (controller.value.isStreamingImages) return;
    await controller.startImageStream((image) async {
      if (isDetecting) {
        cameraImage = image;
        yoloOnFrame(image);
      }
    });
  }

  Future<void> stopDetection() async {
    if (controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }
    setState(() {
      isDetecting = false;
      yoloResults.clear();
    });
  }

  Future<void> yoloOnFrame(CameraImage cameraImage) async {
    if (!mounted) return;

    final result = await vision.yoloOnFrame(
      bytesList: cameraImage.planes.map((plane) => plane.bytes).toList(),
      imageHeight: cameraImage.height,
      imageWidth: cameraImage.width,
      iouThreshold: 0.4,
      confThreshold: 0.4,
      classThreshold: 0.5,
    );
    if (result.isNotEmpty && mounted) {
      setState(() {
        yoloResults = result;
      });
    }
  }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (yoloResults.isEmpty || cameraImage == null) return [];

    Color colorPick = const Color.fromARGB(255, 50, 233, 30);

    final imageWidth = cameraImage!.width.toDouble();
    final imageHeight = cameraImage!.height.toDouble();

    final screenRatio = screen.width / screen.height;
    final previewRatio = controller.value.aspectRatio;

    double previewWidth;
    double previewHeight;
    double offsetX = 0;
    double offsetY = 0;

    if (screenRatio > previewRatio) {
      previewHeight = screen.height;
      previewWidth = screen.height * previewRatio;
      offsetX = (screen.width - previewWidth) / 2;
    } else {
      previewWidth = screen.width;
      previewHeight = screen.width / previewRatio;
      offsetY = (screen.height - previewHeight) / 2;
    }

    final factorX = previewWidth / imageHeight;
    final factorY = previewHeight / imageWidth;

    return yoloResults.map((result) {
      final box = result["box"];
      final left = box[0] * factorX + offsetX;
      final top = box[1] * factorY + offsetY;
      final width = (box[2] - box[0]) * factorX;
      final height = (box[3] - box[1]) * factorY;

      return Positioned(
        left: left,
        top: top,
        width: width,
        height: height,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: colorPick, width: 2.0),
          ),
          child: Text(
            "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }
}
