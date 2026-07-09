@echo off
echo Building Flutter APK with alternative approach...

REM Set environment variable to use shorter path
set FLUTTER_TEMP_DIR=C:\temp\flutter_build

REM Create temp directory if it doesn't exist
mkdir C:\temp 2>nul
mkdir %FLUTTER_TEMP_DIR% 2>nul

REM Build with specific parameters to avoid path issues
flutter build apk --release --split-per-abi --target-platform android-arm64

echo Build completed. Check build\app\outputs\flutter-apk\ for APK files.
pause