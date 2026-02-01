# Ignore missing desktop java.beans classes for SnakeYAML
-dontwarn java.beans.**
-dontwarn java.awt.**
-dontwarn org.yaml.snakeyaml.**

# Keep generic model classes if needed
-keep class org.yaml.snakeyaml.** { *; }