# Flutter YOLOv8 Local Detection

A real-time object detection application built with Flutter and the Ultralytics YOLOv8 TFLite engine. This project demonstrates how to run computer vision models locally on-device with high-performance camera streaming.

## 🚀 Getting Started

### 1. Prerequisites
* **Flutter SDK:** Latest stable version.
* **Android:** Physical device or Emulator with Camera support (Pixel 7/8 recommended).
* **Model:** YOLOv8n TFLite format.

### 2. Native Asset Setup (Critical Step)
Unlike standard Flutter assets, the native YOLO engine requires direct access to the model files to avoid memory latency. 

**You must place your files in the following directory:**
`android/app/src/main/assets/`

Expected files:
* `yolov8n.tflite` (The trained model)
* `metadata.yaml` (The class labels)

### 3. Installation & Running
If you have moved files or changed the directory structure, always perform a clean build:

```bash
# Clear old build artifacts
flutter clean

# Fetch dependencies
flutter pub get

# Run on your connected device/emulator
flutter run