
# pinpal

A new Flutter project.

## Getting Started

### Run on iOS Simulator (Mac)

1. Open a simulator:

```bash
open -a Simulator
```

2. Check available Flutter devices:

```bash
flutter devices
```

3. Run the app on the simulator (recommended: use UDID from `flutter devices`):

```bash
flutter run -d <SIMULATOR_UDID>
```

Example:

```bash
flutter run -d B4A89B49-8D72-4843-99E8-8F445EB75F45
```

You can also run by exact simulator name:

```bash
flutter run -d "iPhone 17 Pro"
```

### If simulator does not appear in `flutter devices`

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
killall -9 Simulator
killall -9 com.apple.CoreSimulator.CoreSimulatorService
open -a Simulator
flutter devices
```

If needed, open the iOS workspace in Xcode once and run there:

```bash
open ios/Runner.xcworkspace
```

Then retry `flutter run -d <SIMULATOR_UDID>`.

---

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# pinpal
# pinpal
# pinpal
# pinpal
