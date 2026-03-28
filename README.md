# 🔊 Sound Meter

A professional-grade sound level meter built with Flutter, providing real-time decibel monitoring, acoustic weighting filters, and recording capabilities — all from your phone's microphone.

[![Flutter](https://img.shields.io/badge/Flutter-3.11+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## ✨ Features

### 🎯 Real-Time Monitoring
- **Live dB readings** from the device microphone at ~30 FPS polling rate
- **Radial gauge** with animated needle powered by Syncfusion Flutter Gauges
- **Min / Avg / Max** tracking with exponential moving average (EMA) smoothing
- **Environment classification** — contextual labels like *"Whisper"*, *"Busy Traffic"*, *"Thunder"* based on current noise level

### 📊 Multi-View Charts
Cycle through three real-time visualization modes:
| Chart | Description |
|---|---|
| **Timeline** | Rolling ~24-second dB history graph |
| **Waveform** | Raw PCM amplitude from the microphone membrane |
| **FFT Spectrum** | Logarithmic frequency spectrum (20 Hz – 20 kHz) with peak frequency annotation |

### 🎛️ Acoustic Weighting Filters
Professional frequency and time weighting based on **IEC 61672-1:2003**:

- **Frequency Weighting**: A (dBA), C (dBC), Z (dBZ)
- **Time Weighting**: Fast (125 ms), Slow (1 s), Impulse (35 ms rise / 1.5 s decay)

### 🔧 Calibration
- Adjustable dB offset for hardware calibration against a known reference source

### 💾 Recording & History
- **Save sessions** with full metadata (min/max/avg dB, duration, dB history, weighting unit)
- **Audio file recording** (WAV) via native PCM capture
- **Persistent history** powered by `hydrated_bloc` — recordings survive app restarts
- **Detail screen** with stats card, area chart replay, and built-in audio playback (SoLoud)
- **Rename, share, and delete** recordings

### 🌗 Theme Support
- Light and dark mode with automatic system detection
- Manual toggle from the app bar
- Material 3 design system with a warm coral (`#E85A3F`) primary palette

---

## 🏗️ Architecture

The app follows **BLoC (Business Logic Component)** architecture with a clean separation of concerns:

```
lib/
├── main.dart                    # App entry point, theme config, BLoC providers
├── blocs/
│   ├── sound_meter/             # Core audio state management
│   │   ├── sound_meter_bloc.dart
│   │   ├── sound_meter_event.dart
│   │   └── sound_meter_state.dart
│   ├── history/                 # Persistent recording history (HydratedBloc)
│   │   ├── history_bloc.dart
│   │   ├── history_event.dart
│   │   └── history_state.dart
│   └── theme/                   # Light/dark mode toggle
│       ├── theme_bloc.dart
│       ├── theme_event.dart
│       └── theme_state.dart
├── models/
│   └── recording_model.dart     # SoundRecording data model with serialization
├── screens/
│   ├── main_screen.dart         # Primary meter + charts UI
│   ├── history_screen.dart      # Saved recordings list
│   └── detail_screen.dart       # Recording detail + audio player
├── utils/
│   └── sound_utils.dart         # Frequency/time weighting math, dB references
└── widgets/
    ├── db_meter.dart            # Radial gauge + digital display
    ├── charts.dart              # Timeline, Waveform, FFT chart widgets
    ├── calibration_dialog.dart  # dB offset calibration UI
    ├── db_legend_dialog.dart    # dB reference table dialog
    └── weighting_dialog.dart    # Frequency/time weighting picker
```

### Key Design Principles

- **Utility-First Logic** — All domain math (weighting filters, EMA calculations) lives in `lib/utils/` as static, pure functions for easy unit testing
- **Semantic Theming** — All colors are resolved via `Theme.of(context).colorScheme`; no hardcoded color constants in widgets
- **Reactive State** — BLoC pattern with `flutter_bloc` for predictable, testable state transitions

---

## 🛠️ Tech Stack

| Category | Package | Purpose |
|---|---|---|
| **State Management** | `flutter_bloc` / `hydrated_bloc` | Reactive BLoC pattern with persistence |
| **Audio Capture** | `flutter_recorder` | Native microphone access (PCM / WAV) |
| **Audio Playback** | `flutter_soloud` | Low-latency audio playback engine |
| **Signal Processing** | `fftea` | Fast Fourier Transform for spectrum analysis |
| **Gauges** | `syncfusion_flutter_gauges` | Radial gauge visualization |
| **Charts** | `syncfusion_flutter_charts` | Timeline, waveform, and FFT charts |
| **Permissions** | `permission_handler` | Runtime microphone permission |
| **File System** | `path_provider` / `path` | App documents directory management |
| **Formatting** | `intl` | Date/time formatting |
| **Sharing** | `share_plus` | Share recordings externally |
| **IDs** | `uuid` | Unique recording identifiers |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>= 3.11.1`
- Android SDK (API 21+) or iOS development environment
- A physical device with a microphone (emulators have limited audio support)

### Installation

```bash
# Clone the repository
git clone https://github.com/agnivon/sound_meter.git
cd sound_meter

# Install dependencies
flutter pub get

# Run on a connected device
flutter run
```

### Building for Release

```bash
# Android APKs (split by ABI for smaller downloads)
flutter build apk --split-per-abi

# Android App Bundle
flutter build appbundle
```

---

## 🧪 Testing

The project includes a comprehensive test suite covering unit, BLoC, and widget tests:

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Test Structure

```
test/
├── blocs/
│   ├── history_bloc_test.dart
│   ├── sound_meter_bloc_test.dart
│   └── theme_bloc_test.dart
├── screens/
│   ├── detail_screen_test.dart
│   ├── history_screen_test.dart
│   └── main_screen_test.dart
├── utils/
│   └── sound_utils_test.dart
└── widgets/
    ├── calibration_dialog_test.dart
    ├── db_meter_test.dart
    └── weighting_dialog_test.dart
```

---

## 📋 Permissions

| Permission | Platform | Reason |
|---|---|---|
| `RECORD_AUDIO` | Android | Microphone access for sound measurement |
| Microphone | iOS | Microphone access for sound measurement |

The app requests microphone permission at startup. All audio processing is performed **on-device** — no data is transmitted externally.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgements

- [Syncfusion](https://www.syncfusion.com/) for their excellent Flutter gauge and chart libraries
- [flutter_recorder](https://pub.dev/packages/flutter_recorder) for native audio capture
- [SoLoud](https://pub.dev/packages/flutter_soloud) for high-performance audio playback
- IEC 61672-1:2003 standard for acoustic weighting filter formulae
