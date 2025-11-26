# flutter_wa_skeleton

A Flutter WA example project.

This project is a starting point for a Flutter WA.
It's contains fully operational onboarding with apphud integration, settings, premium banner, main paywall and several examples of custom widgets

[Project design](https://www.figma.com/design/8fl2zHw9tLnD94RMXq8sOp/-185.-Arithmetic-Adventure-Darya-Karsakova-?node-id=68426-40580&t=Elkc7GLmQ6hj5Cgm-1)

## Getting Started

1. Clone this repo

2. Change flutter app name at `pubspec.yaml` and `lib/main.dart`->`CommonConfig.appName`

3. Change `CFBundleDisplayName` and `CFBundleName` at `ios/Runner/Info.plist`

4. Change `assets/icon.png` and run `dart run flutter_launcher_icons`

5. Change color at `flutter_native_splash.yaml` to your splash color and run `dart run flutter_native_splash:create`

6. Download assets for your app from figma design:
    - Use the max quality
    - Save the structure and name style of this skeleton
    - Write new assets folders at `pubspec.yaml`
    - Run `dart run build_runner build --delete-conflicting-outputs` to generate assets

7. Edit and create new ui at `lib/app/ui/...`:
    - Set up your flutter splash page at `lib/app/ui/splash.page.dart`
    - Use global service `uiHelper` to detect deviceType and orientation
    - Set up your app styles at folder `lib/style/`
    - Save project structure - create folders for *features* and separate *widgets* and *pages*
    - Use `OnBoardingHelper` service to requestReview and control onboarding status
    - Check and use functions from `lib/core/utils.dart`
