# Release Process

This document outlines the process for releasing the HomeHarmony application to the Google Play Store.

## Android Release Process

The Android release lifecycle for a Flutter application involves a series of steps to prepare, build, and publish your app to the Google Play Store.

### 1. Pre-Release Configuration

Before building your app for release, there are several configuration steps to ensure it's ready for the Play Store.

* **Update the App's Version Number**: In your `pubspec.yaml` file, make sure to update the version number. Google Play requires a unique version number for each release.
* **Add a Launcher Icon**: Replace the default Flutter launcher icon with your own custom icon.
* **Review the App Manifest**: Check the `AndroidManifest.xml` file located in `android/app/src/main` to ensure the package name (applicationId), permissions, and other settings are correct. The `applicationId` must be unique and should not be changed after you publish your app.
* **Review the Build Configuration**: In the `android/app/build.gradle` file, you can configure properties like `minSdkVersion` and `targetSdkVersion`.

### 2. Signing the App

Android requires that all apps be digitally signed with a certificate before they can be installed.

* **Create a Keystore**: If you don't have one, you'll need to generate a private signing key using the `keytool` command.

    ```bash
    keytool -genkey -v -keystore your-key-name.keystore -alias your-alias-name -keyalg RSA -keysize 2048 -validity 10000
    ```

    Keep this file private and secure, as it's required for all future app updates.

* **Reference the Keystore in Your Project**: Create a file named `key.properties` in the `android` directory of your project. This file will contain the credentials for your keystore.

    ```properties
    storePassword=<password>
    keyPassword=<password>
    keyAlias=<alias>
    storeFile=<path_to_keystore_file>
    ```

* **Configure Gradle for Signing**: In your `android/app/build.gradle` file, add the signing configuration to automatically sign your release builds.

### 3. Building the App for Release

Once your app is configured and signed, you can build the release version. The recommended format for publishing on the Google Play Store is the Android App Bundle (`.aab`).

* **Build an App Bundle**: Run the following command in your terminal:

    ```bash
    flutter build appbundle
    ```

    This command will generate a release app bundle at `build/app/outputs/bundle/release/app-release.aab`.

* **Build an APK (Optional)**: If you need to test a release version on a physical device or publish to a store that doesn't support app bundles, you can build an APK.

    ```bash
    flutter build apk --split-per-abi
    ```

### 4. Publishing to the Google Play Store

With your signed app bundle ready, the final step is to publish it on the Google Play Store.

* **Create a Google Play Developer Account**: If you don't already have one, you'll need to register for a Google Play Developer account.
* **Create an App in the Play Console**: In the Google Play Console, create a new app, providing details like the app name, language, and whether it's free or paid.
* **Complete App Setup**: Fill out all the required information in the Play Console dashboard, including the store listing, content rating, and privacy policy.
* **Upload Your App Bundle**: Navigate to the "Production" or "Internal testing" track and upload the `.aab` file you generated.
* **Rollout the Release**: After uploading, you can review the release details, add release notes, and then roll it out for review by Google.

For new developer accounts, Google has a mandatory 14-day closed testing period before you can publish an app to production.

---

# Building a Releasable Android App from Flutter Source Code

This guide provides step-by-step instructions for taking the source code of a Flutter application and building a releasable Android app bundle (AAB) or APK that is ready for submission to the Google Play Store. The process includes preparing the app, signing it, building the release version, and preparing for Play Store upload.

**Note:** These instructions are based on the official Flutter documentation and best practices as of August 2025. Ensure you have the latest Flutter SDK installed. Always refer to the official docs for any updates: [Flutter Android Deployment](https://docs.flutter.dev/deployment/android).

## Prerequisites

* **Flutter SDK**: Installed and added to your PATH. Verify with `flutter doctor`.
* **Android SDK**: Installed via Android Studio. Ensure you have the Android command-line tools.
* **Java Development Kit (JDK)**: Version 11 or higher.
* **Flutter Project Source Code**: A working Flutter app ready for release.
* **Google Play Console Account**: Create one at [play.google.com/console](https://play.google.com/console) and pay the one-time $25 fee.
* **Keystore Tool**: Available via JDK (keytool command).
* A physical Android device or emulator for testing.

Run `flutter doctor` to check for any issues with your setup.

## Step 1: Update the App Version and Dependencies

1. Open the `pubspec.yaml` file in the root of your Flutter project.
2. Update the `version` field to reflect the release version, e.g., `version: 1.0.0+1` (format: `major.minor.patch+build`).
3. Ensure all dependencies are up to date by running `flutter pub get`.
4. If needed, update the app name in `pubspec.yaml` under `name`.

## Step 2: Configure the Launcher Icon

1. Generate adaptive icons using tools like [icon.kitchen](https://icon.kitchen) or Android Studio's Image Asset Studio.
2. Place the icon files in `android/app/src/main/res/mipmap-*` folders (e.g., mipmap-hdpi, mipmap-mdpi, etc.).
3. Update the `android:icon` attribute in `android/app/src/main/AndroidManifest.xml` to `@mipmap/ic_launcher`.
4. Run the app on an Android device/emulator to verify the icon.

## Step 3: Review and Update the App Manifest

1. Open `android/app/src/main/AndroidManifest.xml`.
2. Set the app name in the `android:label` attribute under the `<application>` tag.
3. Add necessary permissions, e.g., `<uses-permission android:name="android.permission.INTERNET"/>` if your app requires internet access.
4. Ensure the `android:exported` attributes are set correctly for activities, especially if targeting Android 12+.

## Step 4: Review the Gradle Build Configuration

1. Open `android/app/build.gradle` (or `.kts` if using Kotlin DSL).
2. In the `android` block:
   * Set `compileSdkVersion` to the latest (e.g., 34 or higher).
   * Set `minSdkVersion` to at least 21 (Flutter default is often 19 or 21).
   * Set `targetSdkVersion` to the latest (e.g., 34).
   * Ensure `applicationId` is unique (e.g., `com.example.myapp`).
3. If using Material Components, add `implementation 'com.google.android.material:material:<latest-version>'` to dependencies.

## Step 5: Enable Multidex Support (If Needed)

If your app exceeds 64K methods (common with large apps):

1. Run `flutter run --debug` and follow prompts to enable multidex.
2. Alternatively, add `implementation 'androidx.multidex:multidex:2.0.1'` to `android/app/build.gradle` dependencies.
3. Set `multiDexEnabled true` in the `defaultConfig` block.

## Step 6: Create an Upload Keystore for Signing

1. Generate a keystore using the keytool command:
   * On macOS/Linux: `keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
   * On Windows: `keytool -genkey -v -keystore %userprofile%\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Provide a strong password and store details when prompted.
3. Move the generated `.jks` file to `android/app/upload-keystore.jks`.
4. Create a `key.properties` file in the `android` folder with:

   ```
   storePassword=<your-store-password>
   keyPassword=<your-key-password>
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

5. Add `key.properties` and the keystore to `.gitignore` for security.

## Step 7: Configure Signing in Gradle

1. In `android/app/build.gradle`, add before the `android` block:

   ```kotlin
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }
   ```

2. Inside the `android` block, add:

   ```kotlin
   signingConfigs {
       release {
           keyAlias keystoreProperties['keyAlias']
           keyPassword keystoreProperties['keyPassword']
           storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
           storePassword keystoreProperties['storePassword']
       }
   }
   buildTypes {
       release {
           signingConfig signingConfigs.release
       }
   }
   ```

## Step 8: Build the Release App Bundle (AAB)

1. Run `flutter clean` to clear previous builds.
2. Run `flutter pub get` to fetch dependencies.
3. Build the AAB (preferred for Play Store): `flutter build appbundle --release`.
4. The output will be at `build/app/outputs/bundle/release/app-release.aab`.
5. Optionally, build split APKs: `flutter build apk --split-per-abi --release`.
6. To obfuscate code for security, add `--obfuscate --split-debug-info=/<project-name>/symbols` to the build command.

## Step 9: Test the Release Build

1. Install the AAB on a device using bundletool:
   * Download bundletool from GitHub.
   * Generate APKs: `java -jar bundletool.jar build-apks --bundle=app-release.aab --output=app.apks --ks=upload-keystore.jks --ks-pass=pass:<password> --ks-key-alias=upload --key-pass=pass:<password>`
   * Install: `java -jar bundletool.jar install-apks --apks=app.apks`
2. Test functionality, performance, and crashes on multiple devices.
3. Use internal testing on Play Console (upload to internal track for quick testing).

## Step 10: Set Up and Publish to Google Play Store

1. Log in to [Google Play Console](https://play.google.com/console).
2. Click "Create app" and provide:
   * App name
   * Default language
   * App or game type
   * Free or paid (cannot change later)
   * Declarations (e.g., no ads if applicable)
3. Complete the Dashboard tasks:
   * **App content**: Add privacy policy URL (generate one if needed, e.g., via free tools), target audience, content ratings questionnaire.
   * **Store listing**: Upload high-res screenshots (from multiple devices), feature graphic, app icon, descriptions (short and full), categories, tags, contact details.
   * **App access**: Declare if any parts require login.
   * **Ads**: Declare if the app contains ads.
   * **Content rating**: Complete the questionnaire.
   * **Target audience**: Specify age groups and compliance.
4. Go to "Production" > "Create new release":
   * Upload the AAB file.
   * Provide release notes.
   * Set release name and version.
5. Review and roll out:
   * Start with internal testing or closed testing (alpha/beta) for feedback.
   * Once ready, promote to production.
6. Submit for review (Google reviews apps for policy compliance; can take days).
7. Monitor the console for approval and publish.

## Additional Best Practices

* **Code Shrinking**: Enabled by default with R8; disable with `--no-shrink` if issues arise.
* **Security**: Never commit keystores or passwords to version control.
* **Updates**: For future releases, increment `versionCode` and `versionName`, rebuild, and upload new AAB.
* **Troubleshooting**: Check Flutter logs, Android Studio debugger, or forums like Stack Overflow for errors.
* **Costs**: Play Store has a one-time fee; no ongoing costs for free apps.

Your app should now be ready for release! If you encounter issues, consult the official documentation or community resources.
