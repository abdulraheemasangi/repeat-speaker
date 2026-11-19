# Repeat Speaker (v1.4.0)

A premium, distraction-free speech repetition studio built with Flutter. It lets you type or paste English text and speaks it aloud in an endless or targeted repetition loop with synchronized real-time word highlighting.

---

## Version 1.4.0 Highlights

- **Luminous Pearlescent Liquid Glass Theme:** Soft, light, airy backgrounds with frosted translucent glass surfaces, specular highlights, and gentle diffused shadows.
- **Complete Emoji Removal & Pure Lucide Vector Icons:** All emoji characters removed from the user interface. Replaced with clean, crisp, resolution-independent vector icons with 2.0 stroke styling.
- **Redesigned Repeat Limit Stepper:** Dedicated glass card with tactile (+) and (−) increment/decrement buttons, an animated repetition count display, a seamless continuous-loop option, and quick preset pills.
- **Apple-Inspired Interactive Buttons:** Tactile circular glass media controls with smooth press animations, specular highlights, and subtle glass action pills.
- **Crisp Country Code Badges:** Replaced OS flag emojis in Voice Selection with sleek, modern geometric country code badges (US, GB, AU).
- **Enhanced Text Contrast & Readability:** High-contrast Slate typography for razor-sharp readability in both light and dark modes.
- **Dynamic Text Synchronization:** Engine dynamically reads the latest text directly from the text editor before each repetition.
- **5 Curated Studio Voice Models:** Standardized to 5 natural, clear studio-grade voices with 0ms instant switching.
- **Reliable Local Persistence:** Automatically remembers entered text, selected voice model, playback speed, pause interval, and repetition limit across app restarts.
- **Screen Wakelock:** Keeps screen active while repeating so your phone never sleeps mid-study.
- **100% Offline & Free:** Powered exclusively by the device's native TTS engine. No API keys, no subscriptions, zero data tracking.

---

## Direct APK Download & Installation

Download the pre-compiled APK directly from GitHub Releases:

### [Download Latest RepeatSpeaker.apk (v1.4.0)](https://github.com/abdulraheemasangi/repeat-speaker/releases/latest)

### How to Install on your Android Phone:
1. Open the [Releases](https://github.com/abdulraheemasangi/repeat-speaker/releases/latest) page in Chrome on your Android phone.
2. Tap **`RepeatSpeaker.apk`** under **Assets** to download it.
3. Tap the file in your notification bar or Downloads app.
4. If prompted, toggle on **Allow from this source**.
5. Tap **Install** (or **Update**) and launch the app!

---

## Curated Voice Models

| Model | Accent | Country | Profile |
| :--- | :--- | :--- | :--- |
| **US Studio** | en-US | US | Clear, natural, articulate studio narration |
| **US Clarity** | en-US | US | Deep, focused, authoritative American voice |
| **British Elegance** | en-GB | GB | Sophisticated, classic British pronunciation |
| **British Warmth** | en-GB | GB | Gentle, warm, calm British cadence |
| **Australian Crisp** | en-AU | AU | Bright, friendly Australian speech rhythm |

---

## Project Architecture

```
├── .github/
│   ├── scripts/
│   │   └── configure_android.py    # CI script configuring manifest queries & signing
│   └── workflows/
│       └── build-apk.yml           # Automated GitHub Actions APK build & release
├── android_assets/                 # Master drawables for minimal branding
├── lib/
│   ├── main.dart                   # App bootstrap, persistent theme restore
│   ├── models/
│   │   └── voice_model.dart        # 5 curated studio & neural voice definitions
│   ├── screens/
│   │   └── home_screen.dart        # Luminous Liquid Glass main screen
│   ├── services/
│   │   ├── storage_service.dart    # SharedPreferences automatic local persistence
│   │   └── tts_controller.dart     # TTS engine, dynamic text sync, loop limit, 0ms voice
│   ├── theme/
│   │   └── liquid_glass_theme.dart # Pearlescent Liquid Glass palette, gradients, shadows
│   └── widgets/
│       ├── about_dialog.dart       # About modal with vector feature rows (v1.4.0)
│       ├── app_icons.dart          # Lucide-style resolution-independent vector icons
│       ├── app_logo.dart           # Symmetrical circular repeat loop logo
│       ├── circular_media_controls.dart # Tactile circular Play/Pause button
│       ├── country_badge.dart      # Clean geometric country code badge (US, GB, AU)
│       ├── liquid_glass_container.dart  # High-performance frosted glass containers
│       ├── repeat_limit_control.dart    # Stepper (+ / −) & animated limit control
│       ├── voice_selector_sheet.dart    # Instant-switch voice model selector sheet
│       └── word_highlight_view.dart     # Synchronized real-time word highlight reader
├── test/
│   └── widget_test.dart            # Automated UI smoke test
├── pubspec.yaml                    # Flutter dependencies (v1.4.0+5)
└── README.md
```

---

## License
MIT License. Free to use, modify, and distribute.
