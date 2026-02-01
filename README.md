# Flutter YOLOv8 Object Detection

A high-performance real-time object detection application built with Flutter and the [Ultralytics YOLOv8](https://github.com/ultralytics/ultralytics) engine. This project runs quantization-optimized TFLite models locally on-device, leveraging the native Android asset manager for low-latency inference.

## 📂 Project Structure Overview

The project is structured to bridge Flutter UI with native compiled models.

```
nocodile/flutter_local/
├── android/app/src/main/assets/  <-- IMPORTANT: Native Model Location
│   ├── yolov8n_quant.tflite      (Currently active utilized model)
│   ├── yolov8n.tflite            (Unquantized float32 model)
│   └── metadata.yaml             (Class labels)
├── assets/models/                <-- Flutter Asset Backup (Currently unused)
│   ├── yolov8n.tflite
│   └── metadata.yaml
├── lib/
│   └── main.dart                 (Main application entry point)
├── pubspec.yaml                  (Dependency and asset declaration)
└── ...
```

## ❓ Confusion Clarified: Where are models loaded from?

**The answer is: `android/app/src/main/assets`**

### Why?
1.  **Code Reference**: In `lib/main.dart`, the `YOLOView` widget is initialized with `modelPath: 'yolov8n_quant.tflite'`.
2.  **File Existence**: The file `yolov8n_quant.tflite` *only* exists in `android/app/src/main/assets`. It does not exist in `assets/models`.
3.  **Native vs Flutter Assets**: The `ultralytics_yolo` package often wraps native Android/iOS libraries. These native libraries access files via the Native Asset Manager, not the Flutter Bundle. While `pubspec.yaml` declares `assets/models`, the native code running the inference engine looks directly into the Android native assets folder.

## 🚀 Getting Started

### Prerequisites
*   **Flutter SDK**: ^3.10.4
*   **Android Device/Emulator**: Must support Camera2 API (Pixel 7/8 recommended).
*   **Hardware**: Android device recommended for GPU/NPU acceleration, though this specific configuration uses CPU (`useGpu: false`).

### Installation

1.  **Clone/Open the project**
    ```bash
    cd c:\Users\alext\Projects\nocodile\flutter_local
    ```

2.  **Clean Build Artifacts**
    Important if you have changed model files or asset paths.
    ```bash
    flutter clean
    ```

3.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

4.  **Run the Application**
    Connect your Android device and run:
    ```bash
    flutter run
    ```

## 🛠 Model Management

To change the model being used (e.g., to use a custom trained model):

1.  **Place the `.tflite` file** in `android/app/src/main/assets/`.
2.  **Update `lib/main.dart`**:
    Change the `modelPath` parameter in `YOLOView`:
    ```dart
    YOLOView(
      modelPath: 'your_custom_model.tflite', // Match filename exactly
      task: YOLOTask.detect,
      ...
    )
    ```
3.  **Rebuild**: Run `flutter clean` and `flutter run`.

## 🐛 Troubleshooting

*   **"Model not found" error**:
    *   Ensure the file is in `android/app/src/main/assets`.
    *   Ensure the filename in `main.dart` matches exactly (case-sensitive).
*   **Camera Permission Denied**:
    *   The app uses `permission_handler` to request access. If denied, go to App Settings on your phone and manually enable Camera permissions.
*   **Slow Inference**:
    *   The current config uses `useGpu: false`. Setup a TFLite GPU Delegate for faster performance, but ensure your model is compatible with GPU delegates.
    *   Verify you are using the `_quant` (quantized) version of the model, which is significantly smaller and faster on mobile CPUs.

## 📦 Dependencies

*   `ultralytics_yolo`: ^0.2.0 - Core YOLO inference engine.
*   `camera`: ^0.10.5 - Camera hardware access.
*   `permission_handler`: ^11.3.1 - OS permission management.