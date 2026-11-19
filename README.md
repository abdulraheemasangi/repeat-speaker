# Repeat Speaker 🎙️⚡ (v1.3.0)

A clean, minimal, distraction-free mobile app built with Flutter. It lets you type or paste English text and speaks it aloud in a loop with synchronized real-time word highlighting until you stop it or reach your configured target repetition limit.

---

## ✨ Version 1.3.0 Highlights

- ⚡ **Instant Voice Switching (0ms UI Response):** Tapping any voice model updates the UI and checkmark immediately via reactive state management with zero UI lag, persisting asynchronously in the background.
- 🔄 **Real-Time Dynamic Text Sync:** Fixed TTS speaking stale/default text. TTS now dynamically reads the latest text directly from the text editor before each repetition.
- 🎯 **Accurate Loop Counter & Target Repetition Limit:** Loop counter increments strictly after each speech repetition finishes. Set custom repetition goals (**1x**, **3x**, **5x**, **10x**, **20x**, or **Endless ♾️**) with clean automatic stopping when reached.
- 🎨 **Balanced Repeat Logo:** Refined circular repeat-loop brand icon with tight, symmetrical curvature, balanced spacing, and clean vector arrowheads.
- 🚀 **Smooth 60–120fps Performance:** Deduplicated progress events, eliminated redundant rebuilds, zero heavy GPU blur operations, and freed of memory leaks.
- 🎯 **Single Play/Pause Button:** A single, clean, prominent circular Play/Pause button under your thumb.
- 📖 **Synchronized Word Highlighting:** Real-time word-by-word visual highlighting during speech that auto-scrolls with playback.
- 🎙️ **5 Curated Voice Models:** Standardized to 5 natural, clear studio-grade voices (US Studio, US Clarity, British Elegance, British Warmth, Australian Crisp).
- 💾 **Persistent Data & Settings:** Automatically remembers entered text, selected voice model, playback speed, pause interval, and repetition limit across app restarts.
- 🛡️ **Screen Wakelock:** Keeps screen active while repeating so your phone never sleeps mid-study.
- 📶 **100% Offline & Free:** Powered exclusively by the device's native TTS engine. No API keys, no subscriptions, zero data tracking.

---

## 📥 Direct APK Download & Installation

Download the pre-compiled APK directly from GitHub Releases:

### 🔗 [Download Latest RepeatSpeaker.apk (v1.3.0)](https://github.com/abdulraheemasangi/repeat-speaker/releases/latest)

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
│   │   └── home_screen.dart      # Minimal main screen, tuning controls & loop limit
│   ├── services/
│   │   ├── storage_service.dart  # SharedPreferences automatic local persistence
│   │   └── tts_controller.dart   # TTS engine, dynamic text sync, loop limit, 0ms voice
│   ├── theme/
│   │   └── liquid_glass_theme.dart # Minimal clean palette, typography, decorations
│   └── widgets/
│       ├── about_dialog.dart     # Minimal "About Repeat Speaker" modal (v1.3.0)
│       ├── app_logo.dart         # Symmetrical circular repeat loop logo
│       ├── circular_media_controls.dart # Single circular Play/Pause button
│       ├── liquid_glass_container.dart  # High-performance surface containers
│       ├── voice_selector_sheet.dart    # Instant-switch voice model selector sheet
│       └── word_highlight_view.dart     # Synchronized real-time word highlight reader
├── test/
│   └── widget_test.dart          # Automated UI smoke test
├── pubspec.yaml                  # Flutter dependencies (v1.3.0+4)
└── README.md
```

---

## 📄 License
MIT License. Free to use, modify, and distribute.
