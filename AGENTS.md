# AGENTS.md — Sound Meter

> Context file for AI coding agents working on this project.

## Project Overview

**Sound Meter** is a Flutter mobile application that measures environmental sound levels in real-time using the device microphone. It provides professional-grade acoustic analysis with frequency/time weighting filters (IEC 61672-1:2003), multi-view charting (timeline, waveform, FFT spectrum), recording with audio file capture, and persistent session history.

**Repository**: `github.com/agnivon/sound_meter`
**Framework**: Flutter (Dart `^3.11.1`)
**Target Platform**: Android

---

## Architecture

This project follows the **BLoC (Business Logic Component)** pattern using `flutter_bloc` and `hydrated_bloc` for state management.

### Directory Structure

| Directory | Purpose |
|---|---|
| `lib/blocs/` | BLoC classes (event, state, bloc) for `sound_meter`, `history`, and `theme` |
| `lib/models/` | Data models with JSON serialization (`SoundRecording`) |
| `lib/screens/` | Full-page widgets (`MainScreen`, `HistoryScreen`, `DetailScreen`) |
| `lib/utils/` | Pure, stateless utility classes for domain logic (see rules below) |
| `lib/widgets/` | Reusable UI components (gauges, charts, dialogs) |
| `test/` | Mirrors `lib/` structure with unit, BLoC, and widget tests |
| `assets/icon/` | App icon assets |

### Key BLoCs

| BLoC | State Persistence | Responsibility |
|---|---|---|
| `SoundMeterBloc` | No | Core audio loop: polls microphone at ~30 FPS, calculates dB, FFT, waveform, applies weighting filters |
| `HistoryBloc` | **Yes** (`HydratedBloc`) | Persists saved recordings across app restarts |
| `ThemeBloc` | No | Toggles light/dark mode |

---

## Coding Conventions

### 1. Core Logic → Utility Classes

All domain math and data transformations **must** be implemented as `static` methods in utility classes under `lib/utils/`. This includes:
- Acoustic weighting calculations
- dB conversions and smoothing (EMA, alpha)
- Signal processing helpers

Utility classes must be pure (no `BuildContext`, no UI types) and independently unit-testable.

### 2. Design System & Theming

- **Always** use `Theme.of(context).colorScheme` for colors. Never hardcode `Colors.black`, `Colors.white`, etc.
- **Never** use the deprecated `withOpacity()`. Use `withValues(alpha: double)` instead.
- Theme is defined in `lib/main.dart` with Material 3 and `ColorScheme.fromSeed`.
- Primary brand color: `#E85A3F` (warm coral).

### 3. State Management

- Use BLoC pattern exclusively — no `setState` for business logic, no `ChangeNotifier`.
- Events are imperative commands (`InitializeSoundMeter`, `TogglePauseSoundMeter`).
- States are immutable value objects with `copyWith`.
- Side effects (permissions, file I/O) happen inside BLoC event handlers.

### 4. Testing

- Tests mirror the `lib/` directory structure under `test/`.
- Use `bloc_test` for BLoC testing, `mocktail` for mocking.
- Widget tests should use `BlocProvider` with mock BLoCs, never real audio hardware.

---

## Dependencies (Key)

| Package | Version | Notes |
|---|---|---|
| `flutter_bloc` | `^9.1.1` | State management |
| `hydrated_bloc` | `^11.0.0` | Persistent BLoC storage |
| `flutter_recorder` | `^1.1.2` | Native PCM microphone capture |
| `flutter_soloud` | `^3.5.4` | Audio playback engine |
| `fftea` | `^1.5.0+1` | FFT signal processing |
| `syncfusion_flutter_gauges` | `^33.1.44` | Radial gauge widget |
| `syncfusion_flutter_charts` | `^33.1.45` | Line/area/log charts |
| `permission_handler` | `^12.0.1` | Runtime permissions |

---

## Common Tasks

### Run the app
```bash
flutter run
```

### Run all tests
```bash
flutter test
```

### Analyze for issues
```bash
flutter analyze
```

### Format code
```bash
dart format .
```

### Add a new recording field
1. Update `SoundRecording` model in `lib/models/recording_model.dart` (add field, update `toMap`/`fromMap`/`copyWith`)
2. Update `SoundMeterBloc._onSave()` to populate the new field
3. Update `HistoryState` serialization if needed
4. Update relevant UI screens/widgets

### Add a new weighting type
1. Add enum value in `lib/utils/sound_utils.dart`
2. Implement the math in `SoundUtils.getFrequencyWeightingOffset()` or relevant method
3. Update `weighting_dialog.dart` to show the new option
4. Add unit tests in `test/utils/sound_utils_test.dart`

---

## Environment Notes

- **Physical device required** — emulators have unreliable microphone hardware for real-time audio
- Audio processing runs entirely on-device; no network calls
- Recorder initialized with 32-bit float PCM format (`f32le`) at 48 kHz sample rate
- FFT bin resolution: `48000 / 2 / 256 = 93.75 Hz` per bin
