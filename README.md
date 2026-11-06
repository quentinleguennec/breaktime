# Aebeze Mobile applications

## Getting Started

For help getting started with Flutter, view our online [documentation](http://flutter.io/).


## Building the app

Use `flutter run --flavor [flavor]`

flavor can be dev/prod/daybreak. Prod correspond to moodrise live release.

## In case of issue with Watch app on iOS:
1. Run `flutter clean`
2. Open xCode and select the Runner target.
3. Go to "Build Phases" tab.
4. Expand "Target Dependencies" and remove "Moodrise"
5. Expand "Embed Watch Content" and remove "Moodrise.app"

# Before each PR:

Run formating: `flutter format ./app/lib -l 120`

Alternatively just use vscode, we have the setting with default formatting enable on save.

# RELEASE PROCESS

## Before each release:
1. Update the  version code in the pubspec.yaml

## Release

**IMPORTANT**: ensure to run fastlane with gemfile, follow the installation: https://docs.fastlane.tools/getting-started/ios/setup/#use-a-gemfile The only differenre is that Gemfile is already present while Gemfile.lock is not committed to the repo.

In the app folder run: ```bundle exec fastlane```
There are a few available lanes. You can also shortcut if you know the lane you want to run ```bundle exec fastlane releaseAll```

[More on fastlane lanes for this projet](fastlane/README.md)

## IOS build with Watch App

This istructions are deprecated. At the moment there is a runner for ios watch releases which will be updated on next moodrise release. 

1. Run `flutter clean && flutter build ios --flavor prod` (if an error message shows it's probably still fine, see step 9)
2. Open xCode and select the Runner target.
3. Go to "Build Phases" tab.
4. Expand "Target Dependencies" and add "Moodrise" (if it's not there already)
5. Expand "Embed Watch Content" and  add "Moodrise.app"  (if it's not there already)
6. (May not be necessary) Go to Product > Scheme > Edit Scheme and in the "Moodrise" scheme select the Build Configuration (mode+flavor) you want to use on the iphone app. If the Moodrise scheme doesn't show devices even if connected close and re open the xcode project. 
8. Create the build from xCode (select the right target). For release build select the target "Generic iOS device + watchOS Device" and use Product > Archive.
9. Make sure the build number is matching the one you wrote in pubspec.yaml. If it does all is good, you can upload the build, if it doesn't remove "Moodrise" and "Moodrise.app" from "Target Dependencies" and "Embed Watch Content" (see steps 4 and 5) and run Run `flutter clean && flutter build ios --flavor prod`. There should not be any error message here, if there is you need to fix them. Then start again from step 2.

**NOTE**: Testers to receive build before review needs to be invited with app store connect: https://appstoreconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/users_roles

**Test Plan:** Spreadsheet: https://docs.google.com/spreadsheets/d/1qmhQk0bGQ9LoLKPSJgumNZzf7Z1sCgn0rO9NId_-30M

## Building Tester mode app

1. Open project file app.dart
2. Change from "static const testerMode = false;" to "static const testerMode = true;"

## Documented issues and fixes:
Issue: On Mac OS Catlina, issues when connecting device or running flutter doctor about `idevice_id` or `ideviceinfo` or `iproxy` or `idevicesyslog` or `idevicename`.
Fix: replace PATH_TO_FLUTTER_HOME with actual path and run:
sudo xattr -d com.apple.quarantine <PATH_TO_FLUTTER_HOME>/bin/cache/artifacts/libimobiledevice/idevice_id
sudo xattr -d com.apple.quarantine <PATH_TO_FLUTTER_HOME>/bin/cache/artifacts/libimobiledevice/ideviceinfo
sudo xattr -d com.apple.quarantine <PATH_TO_FLUTTER_HOME>/bin/cache/artifacts/usbmuxd/iproxy 
sudo xattr -d com.apple.quarantine <PATH_TO_FLUTTER_HOME>/bin/cache/artifacts/libimobiledevice/idevicesyslog 
sudo xattr -d com.apple.quarantine <PATH_TO_FLUTTER_HOME>/bin/cache/artifacts/libimobiledevice/idevicename 


Issue will building on Android:
```Finished with error: Unsuported Android Plugin version: 3.6.0.```
This is due to the build flavor not being defined. Try running "flutter run --flavor dev"
To update the flavor in Android Studio got to "Run > Edit Configurations..." and add dev or daybreak under "Build flavor".