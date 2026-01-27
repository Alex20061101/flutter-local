import tensorflow as tf
import subprocess
import os

print("Converting ONNX to TFLite using tf2onnx...")

# First, convert ONNX back to SavedModel using built-in tools
subprocess.run([
    "python", "-m", "tf2onnx.convert",
    "--opset", "13",
    "--onnx", "yolov8n.onnx",
    "--output", "yolov8n_converted.onnx"
], check=False)

# Since that's circular, let's just use ultralytics with a workaround
print("Using ultralytics direct export with edgetpu format...")
subprocess.run([
    "yolo", "export", "model=yolov8n.pt", "format=edgetpu"
], check=False)

# Check if yolov8n_saved_model was created
if os.path.exists("yolov8n_saved_model"):
    print("Found SavedModel, converting to TFLite...")
    converter = tf.lite.TFLiteConverter.from_saved_model("yolov8n_saved_model")
    converter.target_spec.supported_ops = [
        tf.lite.OpsSet.TFLITE_BUILTINS,
        tf.lite.OpsSet.SELECT_TF_OPS
    ]
    tflite_model = converter.convert()
    
    os.makedirs("assets/models", exist_ok=True)
    with open("assets/models/yolov8n.tflite", "wb") as f:
        f.write(tflite_model)
    print("✅ Done! Saved to assets/models/yolov8n.tflite")
else:
    print("❌ No SavedModel found. Export failed.")
