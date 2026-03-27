# Testing & Preview Guide

To preview and test the SmartScan application, follow these steps to ensure all modular dependencies are correctly linked.

## 1. Setup Dependencies
The project is structured as a modular monorepo. You must initialize dependencies for each module:

```powershell
# In the root smartscan/ directory
cd models; flutter pub get
cd ../database; flutter pub get
cd ../core_engine; flutter pub get
cd ../services; flutter pub get
cd ../mobile_app; flutter pub get
```

## 2. Running the Application
Ensure you have an Android emulator or physical device (optimized for mid-range specs: 4-6GB RAM) connected.

```powershell
cd mobile_app
flutter run
```

## 3. Verifying Core Features

### Scanning Pipeline
Navigate to the scan screen and capture a document.
- **Check Logs**: Verify that `ScanningService` triggers the pipeline: `Edge Detection` -> `Perspective Correction` -> `Enhancement`.
- **Security Check**: Check the file system at `/data/user/0/com.smartscan/app_support/smartscan_data/`. Files should have a `.enc` extension and be unreadable by standard image viewers.

### OCR & PDF Export
1. Capture a document and initiate OCR.
2. Export the document as a PDF.
3. Open the exported PDF in a viewer (e.g., Chrome or Adobe Reader).
4. **Test Searchability**: Try searching for text you know was in the document. The hidden text layer should allow full-text search.

## 4. Running Automated Tests
Run unit and widget tests to ensure architectural integrity:

```powershell
# Run tests for the main application
cd mobile_app
flutter test

# Run tests for core engine logic
cd ../core_engine
flutter test
```

## 5. Security Validation
You can verify the encryption by attempting to read a `.enc` file in the console:

```powershell
# This should show a JSON SecretBox structure, not JPEG headers
cat your_document_id/proc_page_id.enc
```
