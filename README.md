# Repeat Speaker 🎙️⚡ (v1.2.0)

A clean, minimal, distraction-free mobile app built with Flutter. It lets you type or paste English text and speaks it aloud in an endless loop with synchronized real-time word highlighting until you pause it.

---

## ✨ Version 1.2.0 Highlights

- ⚡ **Zero-Lag Performance:** Engineered for ultra-smooth 60–120fps responsiveness on Android by eliminating heavy GPU blur filters and background animation loops.
- 🎯 **Single Play/Pause Button:** A single, clean, prominent circular Play/Pause button under your thumb.
- 🎨 **Minimal & Modern Theme:** Clean dark obsidian and crisp light surfaces with refined hairline borders, free of excessive glowing shadows or ambient blur clutter.
- 🔲 **Minimal Logo:** Elegant, professional brand logo across the AppBar, launcher icon, and splash screen.
- 📋 **Silent Instant Paste:** One-tap clipboard paste directly into the text field with no intrusive popup toasts.
- 📖 **Real-Time Word Highlighting:** Synchronized word-by-word visual highlighting during speech that auto-scrolls with playback.
- 🎙️ **5 Curated Voice Models:** Standardized to 5 natural, clear studio-grade voices (US Studio, US Clarity, British Elegance, British Warmth, Australian Crisp).
- 💾 **Persistent Data & Settings:** Automatically remembers entered text, selected voice model, playback speed, pause interval, and theme preference across app closures and reboots.
- 🛡️ **Screen Wakelock:** Keeps screen active while repeating so your phone never sleeps mid-study.
- 📶 **100% Offline & Free:** Powered exclusively by the device's native TTS engine. No API keys, no subscriptions, zero data tracking.

---

## 📥 Direct APK Download & Installation

Download the pre-compiled APK directly from GitHub Releases:

### 🔗 [Download Latest RepeatSpeaker.apk (v1.2.0)](https://github.com/abdulraheemasangi/repeat-speaker/releases/latest)

### How to Install on your Android Phone:
1. Open the [Releases](https://github.com/abdulraheemasangi/repeat-speaker/releases/latest) page in Chrome on your Android phone.
2. Tap **`RepeatSpeaker.apk`** under **Assets** to download it.
3. Tap the file in your notification bar or Downloads app.
4. If prompted, toggle on **Allow from this source**.
5. Tap **Install** (or **Update**) and launch the app!

---

## 🎙️ Curated Voice Models

| Model | Accent | Gender | Profile |
| :--- | :--- | :--- | :--- |
| **US Studio** | 🇺🇸 en-US | Female | Clear, natural, articulate studio narration |
| **US Clarity** | 🇺🇸 en-US | Male | Deep, focused, authoritative American voice |
| **British Elegance** | 🇬🇧 en-GB | Female | Sophisticated, classic British pronunciation |
| **British Warmth** | 🇬🇧 en-GB | Male | Gentle, warm, calm British cadence |
| **Australian Crisp** | 🇦🇺 en-AU | Natural | Bright, friendly Australian speech rhythm |

---

## 📂 Project Architecture

```
├── .github/
│   ├── scripts/
│   │   └── configure_android.py  # CI script configuring manifest queries & signing
│   └── workflows/
│       └── build-apk.yml         # Automated GitHub Actions APK build & release
├── android_assets/               # Master drawables for minimal branding
│   ├── drawable/
│   │   ├── ic_launcher_background.xml
│   │   ├── ic_launcher_foreground.xml
│   │   └── launch_background.xml
│   └── mipmap-anydpi-v26/
│       └── ic_launcher.xml
├── lib/
│   ├── main.dart                 # App bootstrap, persistent theme restore
│   ├── models/
│   │   └── voice_model.dart      # 5 curated studio & neural voice definitions
│   ├── screens/
│   │   └── home_screen.dart      # Minimal main screen & synchronized reader
│   ├── services/
│   │   ├── storage_service.dart  # SharedPreferences automatic local persistence
│   │   └── tts_controller.dart   # TTS engine, word progress handler, loop control
│   ├── theme/
│   │   └── liquid_glass_theme.dart # Minimal clean palette, typography, decorations
│   └── widgets/
│       ├── about_dialog.dart     # Minimal "About Repeat Speaker" modal
│       ├── app_logo.dart         # Minimal brand logo
│       ├── circular_media_controls.dart # Single circular Play/Pause button
│       ├── liquid_glass_container.dart  # High-performance surface containers
│       ├── voice_selector_sheet.dart    # Minimal voice model selector sheet
│       └── word_highlight_view.dart     # Synchronized real-time word highlight reader
├── test/
│   └── widget_test.dart          # Automated UI smoke test
├── pubspec.yaml                  # Flutter dependencies (v1.2.0+3)
└── README.md
```

---

## 📄 License
MIT License. Free to use, modify, and distribute.
