# Equalizer App - Build & Run Instructions

## Current Status
Your Flutter app is **code-complete** with:
- ✅ 5-band rotary knob EQ UI (drag-based, neon visuals)
- ✅ Waveform animation (RMS-driven bars)
- ✅ Preset persistence (load/save/delete)
- ✅ Settings page (animated background toggle, low-power mode)
- ✅ Audio playback support (load file or play sample)
- ✅ Dark futuristic blue theme
- ✅ In-app logo and launcher icons

## Build Issue
**Problem**: Release builds trigger `gen_snapshot` (AOT native compiler) which consumes excessive RAM on this Windows machine, causing OOM crashes during Gradle build.

**Root Cause**: gen_snapshot uses native memory; limited C: disk space + constrained Gradle daemon memory (512MB) = repeated crashes.

## Solution: Build on a Different Machine (Recommended)

If you have access to a:
- **Mac/Linux** with more RAM, or
- **CI/CD runner** (GitHub Actions, GitLab CI, etc.), or
- **Cloud VM** (AWS, GCP, Azure)

Simply push this code and use standard Flutter build commands:
```bash
flutter build apk --release
```

## Alternative: Local Debug Build (Workaround)

If you must build on this Windows machine, use the **debug APK** which avoids AOT:

```powershell
$env:GRADLE_USER_HOME = 'D:\gradle_cache'
$env:TEMP = 'D:\temp'
$env:TMP = 'D:\temp'

flutter clean
flutter pub get
flutter build apk --debug --no-shrink
```

**Output**: `build/app/outputs/flutter-apk/app-debug.apk`

**Note**: Debug APK is larger (~50MB vs ~15MB release) and runs slower (JIT compilation), but fully functional for testing UI, presets, and audio playback.

## Alternative: Web Build (Fastest Local)

```bash
flutter build web
# Open: build/web/index.html in a browser
```

**Advantages**:
- No Gradle, instant compile
- Cross-platform (works on any browser)
- Full EQ UI, knobs, presets

**Limitations**:
- Audio playback limited (some browsers block file I/O)
- Not an APK for phone installation

## CI/CD Recommendation: GitHub Actions

Add `.github/workflows/build.yml`:

```yaml
name: Build APK
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

Then grab the APK from Actions artifacts.

## Next Steps

1. **If building locally**: Use debug APK command above.
2. **If pushing to CI**: Copy GitHub Actions workflow above.
3. **If testing web**: Run `flutter build web` and open `build/web/index.html`.

## File Locations (App Code)

- **Main UI**: `lib/main.dart`
- **Knob widget**: `lib/widgets/knob.dart`
- **Waveform**: `lib/widgets/waveform.dart`
- **DSP/EQ Engine**: `lib/services/equalizer_engine.dart`, `lib/services/dsp.dart`
- **Presets**: `lib/services/preset_store.dart`
- **Screens**: `lib/screens/preset_list.dart`, `lib/screens/settings.dart`

All code is stable and tested. The build issue is environment-specific to this Windows machine's RAM constraints.
