# SmartScan System Design

## 1) Modular Framework
The system is built on a **Modular Monorepo** pattern, separating the application logic from the heavy lifting of image processing and background services.

## 2) Performance Targets & Optimizations
- **Cold Start**: Optimized via lazy initialization in `bootstrap.dart` and `IsarProvider`.
- **Edge Detection**: Offloaded to native threads via platform channels (simulated in current architecture as modular service).
- **Memory Management**: Images are processed in bounded byte buffers. OCR is enqueued to avoid UI thread blocking.
- **Battery Sensitivity**: WorkManager constraints ensure sync and export jobs run primarily when charging.

## 3) Indic Language Support
ML Kit configured with `TextRecognitionScript.latin` and `TextRecognitionScript.devanagari` as default script sets. OCR processing includes script-awareness to extract high-accuracy blocks for search indexing.

## 4) Security Model
All documents (raw and processed) are stored in the `smartscan_data/` directory with `.enc` extensions. The `EncryptionService` handles AES-256-GCM wrapping. Files are strictly inaccessible to other apps.
