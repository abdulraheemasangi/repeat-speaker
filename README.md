# Repeat Speaker 🎙️🔁

A simple, clean, and distraction-free Android mobile app built with Flutter. It lets you type or paste English text and speaks it aloud in an endless loop until you stop it.

Perfect for:
- 📖 **Language & Pronunciation Practice:** Listen to sentences repeatedly to master rhythm, intonation, and pronunciation.
- 🧠 **Memorization & Exam Prep:** Memorize speeches, definitions, formulas, or interview answers through continuous auditory reinforcement.
- 🧘 **Mantra & Affirmation Repetition:** Loop daily affirmations or study points hands-free.

---

## 📱 Features

- **Multi-line Text Input:** Generous input box with real-time word and character counters.
- **Quick Clear & Paste:** Convenient action buttons inside the input card, including one-tap clipboard paste and undoable clear.
- **Endless Audio Loop:** Reliably speaks your text over and over without overlapping audio using `awaitSpeakCompletion`.
- **Configurable Pause (0s – 5s):** Set a rest interval between repeats (default: 1.0 second) with responsive early-cancellation.
- **Repeat Counter:** Real-time counter tracks exactly how many times the phrase has looped ("Repeated: 5 times").
- **Thumb-Friendly Bottom Control Bar:**
  - **Large START & STOP Buttons:** Highly visible, large 54dp touch targets with distinct emerald green and crimson red states.
  - **Calibrated Speed Slider:** Smooth speed adjustment from **0.5x to 2.0x** (in 0.1x steps) calibrated for Android's TTS engine so 1.0x sounds like natural human speech. Changing speed restarts or applies immediately.
- **Offline & Free English Voices:** Uses your device's built-in Text-to-Speech engine (`flutter_tts`). No API keys, no paid subscriptions, and completely offline.
- **Voice Selector:** Browse and select from all available English voices on your device, with automatic prioritization of high-quality Google TTS voices.
- **Keep Screen Awake:** Utilizes `wakelock_plus` to keep the screen active while repeating so the device does not go to sleep mid-session.
- **Android 11+ Package Visibility:** Includes `<queries>` for `android.intent.action.TTS_SERVICE` in `AndroidManifest.xml` to detect all installed TTS engines on Android 11, 12, 13, 14, and 15+.
- **Material 3 Design:** Sleek modern Dark theme by default, with a one-tap Light theme toggle in the AppBar.

---

## 📥 Direct APK Download & Installation

You do not need to install Android Studio or Flutter on your computer to use Repeat Speaker on your phone. You can download the pre-compiled APK directly from GitHub Releases:

### 🔗 [Download Latest RepeatSpeaker.apk](https://github.com/abdulraheem-general/repeat-speaker/releases/latest)

> Replace `abdulraheem-general/repeat-speaker` with your GitHub repository path.

### How to Install on your Android Phone:
1. Open the [Releases](https://github.com/abdulraheem-general/repeat-speaker/releases/latest) page in Chrome on your Android device.
2. Tap **`RepeatSpeaker.apk`** under **Assets** to download it.
3. Once downloaded, tap the file in your notification bar (or find it in your **Files / Downloads** app).
4. If Android displays a prompt saying *"For your security, your phone is not allowed to install unknown apps from this source"*:
   - Tap **Settings** in the popup.
   - Toggle on **Allow from this source**.
   - Tap back and press **Install**.
5. Open **Repeat Speaker**, type or paste your text, and press **START**!

---

## 🚀 GitHub Actions Automated Build Pipeline

This repository includes a pre-configured GitHub Actions workflow at [`.github/workflows/build-apk.yml`](.github/workflows/build-apk.yml).

Every time you:
1. Push code to the `main` branch, OR
2. Push a version tag (e.g. `git tag v1.0.0 && git push origin v1.0.0`), OR
3. Trigger the workflow manually from the **Actions** tab on GitHub:

GitHub will automatically:
- Spin up an Ubuntu runner with Java 17 and Flutter stable.
- Build a signed release APK (`RepeatSpeaker.apk`).
- Upload the APK as a workflow artifact.
- Create/update a GitHub Release with `RepeatSpeaker.apk` attached for direct download!

---

## 🔐 Keystore & APK Signing

By default, `android/app/build.gradle` is configured to sign release builds using the standard Android debug key:
```groovy
buildTypes {
    release {
        signingConfig signingConfigs.debug
        ...
    }
}
```
This guarantees that GitHub Actions immediately outputs an APK that installs without signature errors on any Android device.

### How to Switch to a Production Keystore (Optional)
When you are ready to publish to Google Play or sign with a custom keystore:
1. Generate an upload keystore:
   ```bash
   keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
   ```
2. Create a file `android/key.properties` (this file is ignored by `.gitignore`):
   ```properties
   storePassword=yourStorePassword
   keyPassword=yourKeyPassword
   keyAlias=my-key-alias
   storeFile=../my-release-key.jks
   ```
3. Update `android/app/build.gradle` to load `key.properties` and assign `signingConfig signingConfigs.release`.

---

## 💻 Running the App Locally (For Developers)

### Prerequisites:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0.0 or higher)
- Android Studio or Android SDK command-line tools
- A physical Android device with USB debugging enabled, or an Android Emulator

### Steps:
1. Clone the repository:
   ```bash
   git clone https://github.com/abdulraheem-general/repeat_speaker.git
   cd repeat_speaker
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Connect your Android phone via USB (enable **USB Debugging** in Developer Options).
4. Verify your device is recognized:
   ```bash
   flutter devices
   ```
5. Run the app:
   ```bash
   flutter run
   ```
6. Build a standalone release APK locally:
   ```bash
   flutter build apk --release
   ```
   The built APK will be located at:
   `build/app/outputs/flutter-apk/app-release.apk`

---

## 📂 Project Architecture

```
├── .github/
│   └── workflows/
│       └── build-apk.yml         # Automated GitHub Actions APK build & release
├── android/
│   ├── app/
│   │   ├── build.gradle          # Android app configuration, minSdk 21, debug signing
│   │   └── src/main/
│   │       ├── AndroidManifest.xml # Android 11+ TTS queries, Wakelock, portrait lock
│   │       └── kotlin/.../MainActivity.kt
│   ├── build.gradle
│   └── settings.gradle
├── lib/
│   ├── main.dart                 # App initialization, Material 3 Dark/Light themes
│   ├── screens/
│   │   └── home_screen.dart      # Main screen: text input, counter, speed & controls
│   ├── services/
│   │   └── tts_controller.dart   # TTS engine lifecycle, loop control, wakelock, rate mapping
│   └── widgets/
│       └── voice_selector_dialog.dart # English voice selector modal
├── test/
│   └── widget_test.dart          # Automated UI & smoke test
├── pubspec.yaml                  # Flutter dependencies (flutter_tts, wakelock_plus)
└── README.md
```

---

## 📄 License
MIT License. Free to use, modify, and distribute.
