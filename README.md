# Repeat Speaker 🎙️✨ (v1.1.0)

A distraction-free, Apple iOS-inspired **Liquid Glass** mobile app built with Flutter. It lets you type or paste English text and speaks it aloud in a continuous loop with synchronized real-time word-by-word highlighting until paused or stopped.

---

## ✨ Version 1.1.0 Highlights

- 💎 **Apple iOS Liquid Glass UI:** Translucent frosted glass surfaces, glowing ambient depth, refined borders, and smooth micro-animations.
- 📖 **Real-Time Word Highlighting:** Synchronized word-by-word visual highlighting during speech, wrapped in a glowing Liquid Glass pill that auto-scrolls with playback.
- 🎙️ **5 Curated Voice Models:** Curated down to 5 distinct, studio-grade natural voices (US Studio, US Clarity, British Elegance, British Warmth, Australian Crisp) removing robotic/unclear voice clutter.
- 💾 **Persistent Data & Settings:** Automatically preserves entered text, selected voice model, playback speed, pause interval, and theme preference across app closures and restarts.
- ⏯️ **Circular Media Controls:** Large floating circular Play/Pause button with pulse halo, secondary Stop and Counter Reset controls.
- 🛡️ **Active Screen Wakelock:** Keeps screen active during repetition sessions so your phone never sleeps mid-study.
- 📶 **100% Offline & Free:** Powered exclusively by the device's native TTS engine. No API keys, no subscriptions, zero data tracking.

---

## 📥 Direct APK Download & Installation

You can download the pre-compiled APK directly from GitHub Releases:

### 🔗 [Download Latest RepeatSpeaker.apk (v1.1.0)](https://github.com/abdulraheemasangi/repeat-speaker/releases/latest)

### How to Install on your Android Phone:
1. Open the [Releases](https://github.com/abdulraheemasangi/repeat-speaker/releases/latest) page in Chrome on your Android phone.
2. Tap **`RepeatSpeaker.apk`** under **Assets** to download it.
3. Once downloaded, tap the file in your notification bar (or find it in your **Files / Downloads** app).
4. If Android displays a prompt saying *"For your security, your phone is not allowed to install unknown apps from this source"*:
   - Tap **Settings** in the popup.
   - Toggle on **Allow from this source**.
   - Tap back and press **Install** (or **Update**).
5. Open **Repeat Speaker**, type or paste your text, adjust speed, and press the glowing **Play** button!

---

## 🎨 Liquid Glass Design System

The app utilizes a custom Apple iOS-inspired glassmorphism architecture:
- **`LiquidGlassContainer`:** Real-time hardware-accelerated frosted blur (`BackdropFilter` with `sigmaX: 16, sigmaY: 16`), translucent white gradients, and dual-layer specular borders.
- **`LiquidGlassBackground`:** Ambient radial chromatic orbs (Electric Cyan, Royal Indigo, Radiant Purple) that float behind glass panels, giving true optical depth.
- **`WordHighlightView`:** Rich-text reader rendering synchronized word boundaries with glowing indigo-cyan highlight pills and automatic viewport tracking.

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

## 🚀 GitHub Actions Automated Build Pipeline

Every commit pushed to `main` automatically triggers [.github/workflows/build-apk.yml](.github/workflows/build-apk.yml):
- Compiles the release APK (`RepeatSpeaker.apk`).
- Auto-configures Android 11+ TTS queries and Wakelock permissions.
- Signs the APK with Android release debug signature for immediate 1-tap installation.
- Automatically publishes a new GitHub Release with direct download links.

---

## 📂 Project Architecture

```
├── .github/
│   ├── scripts/
│   │   └── configure_android.py  # CI script configuring manifest queries & signing
│   └── workflows/
│       └── build-apk.yml         # Automated GitHub Actions APK build & release
├── android_assets/               # Master drawables for custom Liquid Glass branding
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
│   │   └── home_screen.dart      # Liquid Glass main screen & synchronized reader
│   ├── services/
│   │   ├── storage_service.dart  # SharedPreferences automatic local persistence
│   │   └── tts_controller.dart   # TTS engine, word progress handler, loop control
│   ├── theme/
│   │   └── liquid_glass_theme.dart # iOS Liquid Glass palette, gradients, decorations
│   └── widgets/
│       ├── about_dialog.dart     # Liquid Glass "About Repeat Speaker" modal
│       ├── app_logo.dart         # Custom vector continuous loop + soundwave logo
│       ├── circular_media_controls.dart # Circular Play/Pause/Stop controls
│       ├── liquid_glass_container.dart  # Frosted glass surfaces & ambient backdrop
│       ├── voice_selector_sheet.dart    # Liquid Glass voice model selector sheet
│       └── word_highlight_view.dart     # Synchronized real-time word highlight reader
├── test/
│   └── widget_test.dart          # Automated UI & smoke test
├── pubspec.yaml                  # Flutter dependencies (v1.1.0+2)
└── README.md
```

---

## 📄 License
MIT License. Free to use, modify, and distribute.
