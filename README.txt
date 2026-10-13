NutriBowl Flutter Starter - WebView fixed for Chrome and Android

WHAT WAS FIXED
- Chrome/web now displays the existing NutriBowl HTML interface in an iframe instead of trying to create a mobile WebView.
- Android continues to use the Flutter WebView wrapper.
- Existing NutriBowl HTML/CSS/JavaScript assets are preserved.
- This package does NOT include SQLite or Firebase integration.

RUN ON WINDOWS / CHROME
1. Extract this ZIP.
2. Open the extracted nutribowl_flutter_starter folder in VS Code.
3. Open Terminal > New Terminal.
4. Run:
   flutter create . --platforms=web,android
   flutter pub get
   flutter run -d chrome

If flutter create asks to overwrite files, do not overwrite lib/main.dart, lib/web_content_web.dart, lib/web_content_stub.dart, assets/nutribowl/index.html, or pubspec.yaml. If it does not ask, continue normally.

RUN ON ANDROID
1. Start an Android emulator from Android Studio Device Manager, or connect an Android phone with USB debugging enabled.
2. Run:
   flutter create . --platforms=web,android
   flutter pub get
   flutter devices
   flutter run -d YOUR_DEVICE_ID
Replace YOUR_DEVICE_ID with the Android device ID shown by flutter devices.

NOTES
- Node.js/Firebase are not required to run this Flutter project.
- Google Maps embeds and QR generation in the HTML may require internet access.
- This ZIP has been patched to address the WebViewPlatform.instance error on Chrome, but it has not been compiled in this environment because Flutter SDK is unavailable here.
