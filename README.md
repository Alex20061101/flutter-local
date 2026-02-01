# Flutter YOLOv8 Object Detection & Performance Lab

A high-performance real-time object detection application built with Flutter and the native [Ultralytics YOLOv8](https://github.com/ultralytics/ultralytics) engine. This project runs quantization-optimized TFLite models locally on-device.

**New Feature: Performance Lab**
The app now includes a dedicated "Performance Lab" interface to benchmark different model resolutions (160px - 640px) and compare CPU vs GPU inference speeds.

## 📂 Project Structure

```
nocodile/flutter_local/
├── android/app/src/main/assets/  <-- ACTIVE Model Location
│   ├── yolov8n_160.tflite        (Ultra-fast, low accuracy)
│   ├── ...
│   ├── yolov8n_320.tflite        (Standard balance)
│   ├── ...
│   └── yolov8n_640.tflite        (High accuracy, slow)
├── lib/
│   └── main.dart                 (Performance Lab UI & Logic)
├── check_models.py               (Utility to inspect TFLite input shapes)
└── ...
```

## 🧪 Performance Lab Features

The application launches directly into the Lab Dashboard where you can control:

1.  **Model Resolution**: Switch instantly between 6 different model sizes. 
    *   *160x160*: Max FPS (useful for fast-moving large objects).
    *   *640x640*: Max Precision (useful for small objects, slower).
2.  **Hardware Acceleration**:
    *   **CPU**: Default. Reliable on all devices.
    *   **GPU**: Uses Android Neural Networks API (NNAPI) / GPU Delegate. *Warning: May crash on older devices or if model types (Int8 vs Float32) are incompatible.*
3.  **Real-time HUD**:
    *   Monitors **FPS** (Frames Per Second).
    *   Counts detected objects in real-time.

## ❓ How It Works (The "Magic" Folder)

**Models are loaded from: `android/app/src/main/assets/`**

Even though Flutter usually uses `assets/`, this specific implementation uses the **Native Android Asset Manager** to bypass the Flutter bundle for zero-copy memory mapping.
*   **Do not** put active models in `lib/assets`.
*   **Do not** remove files from `android/app/src/main/assets` unless you update the source code.

## 🚀 Getting Started

### Prerequisites
*   **Flutter SDK**: ^3.10.4
*   **Python 3.x** (Optional, for `check_models.py`)
*   **Android Device**: Camera2 API support required.

### Installation

1.  **Clone & Setup**
    ```bash
    cd c:\Users\alext\Projects\nocodile\flutter_local
    flutter clean
    flutter pub get
    ```

2.  **Verify Models (Optional)**
    Run the python utility to check if your TFLite models are valid and their input shapes:
    ```bash
    pip install tensorflow
    python check_models.py
    ```

3.  **Run on Device**
    ```bash
    flutter run
    ```

## 🛠 Adding Custom Models

1.  Export your YOLOv8 model to TFLite (Int8 quantized recommended for mobile):
    ```bash
    yolo export model=yolov8n.pt format=tflite int8
    ```
2.  Place the `.tflite` file in `android/app/src/main/assets/`.
3.  Update the `models` map in `lib/main.dart`:
    ```dart
    final Map<String, String> models = {
      'My Custom Model': 'my_best_model.tflite',
      ...
    };
    ```
4.  Rebuild the app.