# SmartScan Architecture (Revised)

## 1) Clean Modular Architecture

SmartScan is now restructured into a highly modular repository to ensure separation of concerns and production readiness.

### Root Modules
- **mobile_app/**: Flutter application code (UI, State Management, Glue logic).
- **core_engine/**: Pure Dart/Native logic for image processing and OCR orchestration.
- **services/**: Background tasks, cloud synchronization, and search indexing.
- **models/**: Centralized data entities shared across modules.
- **database/**: Isar schema definitions and database-specific logic.

## 2) Security Implementation

- **AES-256-GCM Encryption**: All captured and processed images are encrypted on-the-fly using the `cryptography` package.
- **Decryption-on-Demand**: Files are only decrypted in memory when needed for OCR or Export, ensuring minimal plain-text footprint.
- **Biometric Integration**: Access to the encryption master key is gated by biometric authentication (Android Keystore).

## 3) Document Processing Pipeline

The pipeline follows a strict modular flow:
1. **Camera Capture**: Raw JPEG capture via CameraX.
2. **Secure Store**: Encrypted persistence of raw frames.
3. **Edge Detection**: OpenCV-based contour extraction (implemented as modular service).
4. **Perspective Transform**: 4-point warping for document normalization.
5. **Enhancement**: Contrast optimization and adaptive thresholding for OCR clarity.
6. **OCR**: Multi-page text recognition using Google ML Kit with Indic language support.
7. **Export**: PDF generation with a hidden text layer for searchability.

## 4) Repository Structure

```text
smartscan/
├── mobile_app/           # Flutter Project Root
│   ├── android/          # Native Android (CameraX hooks)
│   ├── lib/              # UI & Feature Implementations
│   │   ├── app/          # App initialization
│   │   ├── core/         # DI, Security, Storage glue
│   │   └── features/     # Feature-specific UI/Logic
├── core_engine/          # Core processing logic
│   ├── document_pipeline/
│   └── ocr_engine/
├── services/             # Background & Offline services
│   ├── background_tasks/ # WorkManager dispatchers
│   ├── cloud_sync/       # Cloud provider adapters
│   └── search_index/     # OCR text indexing
├── models/               # Domain data entities
└── database/             # Persistent schema & migrations
```
