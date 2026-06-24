## 2.4.1

- [Android] Fix "Could not find method kotlin()" build failure on AGP 9 when built-in Kotlin is disabled (the Flutter template default) — only configure the kotlin {} DSL when the Kotlin Gradle Plugin is applied, and apply KGP when built-in Kotlin is off

## 2.4.0

- [iOS] Raised declared deployment target to 13.0 to match the minimum already required by Flutter 3.44+
- [Android] Bumped Kotlin to 2.3.20, raised minSdk to 24, and modernized the `lint`/test configuration
- [Example] Migrated the iOS example to Swift Package Manager and the UIScene lifecycle; migrated the Android example to Kotlin DSL + AGP 9 / built-in Kotlin
- Enabled `flutter_lints` via `analysis_options.yaml`

## 2.3.0

- [iOS] Added Swift Package Manager (SPM) support alongside existing CocoaPods support
- [iOS] Raised minimum iOS deployment target to 12.0

## 2.2.0

- Updates minimum supported SDK version to Flutter 3.44 / Dart 3.12
- [Android] Migrates to built-in Kotlin (applies the Kotlin Gradle Plugin only on AGP < 9)

## 2.1.1

- [Android] Updated compileSdkVersion to 36, Gradle to 8.14 and Java/Kotlin compatibility to version 17

## 2.1.0

- [Android] Removed V1 embedding
- [Android] removed obsolete android.enableR8
- [Android] updated to Kotlin 1.5.30
- [Android] upgraded gradle
- [Android] jcenter => mavenCentral
- [Android] set compileSdkVersion to 31
- [iOS] updated Swift version to 5.0

## 2.0.1

[Android] Updated compileSdkVersion and targetSdkVersion to 30
[Android] Fixed #1 

## 2.0.0

- saveAsJpeg: replaced parameter ScaleMode with canScaleUp

## 1.0.0

- Null safety.

## 0.0.4

[Android] Fixed: any thrown exception caused crash. Now exception is delivered correctly to caller.

## 0.0.3

- [Android] Improved error handling.

## 0.0.2

- [iOS] Use background thread to keep UI more responsive.

## 0.0.1

- Initial release.
