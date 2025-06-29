# ai_vocabulary

An AI application in flutter.

# Build Release
```sh
flutter build ios --release --no-tree-shake-icons
```
* check whether git has commit in the folder
```sh
git ls-files assets/
git log --stat assets/
```

# Good Codes
* [lib/pages/speech_confirm_dialog.dart](lib/pages/speech_confirm_dialog.dart)\
Resolve InkWell issue when the page without Scaffold, the alternative way is to wrap Material widget.\
Good example on IntrinsicHeight when you want Stack size follow its children who has the maximum height.

* [lib/main.dart](lib/main.dart)\
override CupertinoTheme's colors with MaterialTheme

* [lib/painters/bubble_shape.dart](lib/painters/bubble_shape.dart)\
A customized shape which can used to every decoration with [ShapeDecoration](lib/widgets/chat_bubble.dart?plain=1#L48-L52).

* [lib/pages/favorite_words_page.dart](lib/pages/favorite_words_page.dart)\
Used sliver_tools package to implement alphabet list view. In addition, the list has UITableView behavior like UIKit feature.

* [lib/utils/gesture_route_page.dart](lib/utils/gesture_route_page.dart)\
Approached gesture navigation push a new page

* [lib/widgets/count_picker_tile.dart](lib/widgets/count_picker_tile.dart)\
Used build-in context to get RenderBox of the return widget's position and size, instead of GlobalKey.(include main example)

* [lib/utils/load_more_listview.dart](lib/utils/load_more_listview.dart)\
Note RefreshIndicator need Material environment to work. The relative usage at [search page](lib/pages/search_page.dart).\
This idea can write a package and publish to pub dev.(include main example)


## Flutter develop

* Use `dart devtools` CLI to quickly open devtools in browser.
You can press `v` in terminal to open, or use CLI to search current executions
```shell
# Not necessary
flutter pub global activate devtools
dart pub global activate devtools
# Attach executions
flutter attach
```

### FVM manage
```sh
git clone --depth=1 -n --filter=blob:none https://github.com/flutter/flutter.git 3.16.9
cd 3.16.9
git remote set-branches origin 3.16.9
git fetch --depth=1 origin 3.16.9
git pull origin 3.16.9:3.16.9
git checkout 3.16.9
fvm install 3.16.9 --setup
```


### Android configuration
* `android/local.properties`
```properties
ndk.dir=/Users/otto/Library/Android/sdk/ndk/28.0.12674087
cmake.dir=/Applications/CMake.app/Contents
```
* `android/app/build.gradle.kts`
```kts
android {
    namespace = "com.example.ai_vocabulary"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.0.12674087"//flutter.ndkVersion

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.ai_vocabulary"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23//flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}
```

### iOS configuration
enable Firebase to iOS project, you should open `ios/<project>.xcworkerspace` in Xcode. Set `minimum Deployment` to **13** and <kbd>Product</kbd>&rarr;<kbd>Scheme</kbd>&rarr;<kbd>Edit...</kbd>, add a below argument to `Arguments Passed On Launch` in Run for Firebase Analysis.
```shell
-FIRDebugDisabled # Not Necessary
```
* #### Enable Google Sign In
Download `GoogleService-Info.plist` from Firebase console, and move to `ios/Runner/GoogleService-Info.plist`.\
Use Xcode to edit the URL Type:
1. open `ios/<project>.xcworkerspace`
1. select Targets at second left dock panel
2. select Info in header tab bar
3. add URL type which same as your `GoogleService-Info.plist` value of `REVERSED_CLIENT_ID`

see [document](https://firebase.google.com/docs/auth/ios/google-signin?hl=en&authuser=0)\
Note: If you suffer ios CocoaPods problem, you could just remove `ios/Podfile.lock`.



# adb command line
* Find packages name
```sh
adb shell pm list packages # List /data/data dir
adb shell pm list packages |grep example
adb shell pm list packages -f # List /data/app dir
```
* List the directory of application
```sh
adb shell run-as <App package name> "sh -c 'ls -hl <App directory path>'"
#e.g.
adb shell run-as com.example.ai_vocabulary "sh -c 'ls app_flutter'"
adb shell run-as com.example.ai_vocabulary "sh -c 'ls -hl /data/data/com.example.ai_vocabulary/app_flutter/'"
```

* #### Push local device file to emulator
You can only access /data/local/tmp in emulator and to access application directory you need to use `run-as <App package name>`.\
When you used `run-as`, you were in the application directory in default.
```sh
adb push <local/device/file/path> /data/local/tmp &&\
adb shell run-as <App package name> "sh -c 'cp /data/local/tmp/<file name> <destination path>'" &&\
adb shell rm /data/local/tmp/<file name>
#e.g.
adb push ~/Desktop/IMG_4610.PNG /data/local/tmp &&\
adb shell run-as com.example.ai_vocabulary "sh -c 'cp /data/local/tmp/IMG_4610.PNG /data/data/com.example.ai_vocabulary/app_flutter'" &&\
adb shell rm /data/local/tmp/IMG_4610.PNG
```
* #### Pull emulator file to local device
You have to touch a new empty file which has write access then overwrite it by copy the same name.
```sh
adb shell touch /data/local/tmp/<file name> &&\
adb shell run-as <App package name> "sh -c 'cp app_flutter/<file name> /data/local/tmp/<file name>'" &&\
adb pull /data/local/tmp/<file name> <local/device/destination/path> &&\
adb shell rm /data/local/tmp/<file name>
#e.g.
adb shell touch /data/local/tmp/my.db &&\
adb shell run-as com.example.ai_vocabulary "sh -c 'cp app_flutter/my.db /data/local/tmp/my.db'" &&\
adb pull /data/local/tmp/my.db ~/Desktop &&\
adb shell rm /data/local/tmp/my.db
```


[reference](https://medium.com/@liwp.stephen/how-does-android-studio-device-file-explorer-works-62685330e8c8)

* #### Copy `libsqlite3.so`
```sh
curl -L -o android/libsqlite3.so https://raw.githubusercontent.com/LightBuzz/Azure-Unity/master/Assets/LightBuzz_Azure/Plugins/SQLite/Android/libs/arm64-v8a/libsqlite3.so
emulator -avd AVD_NAME
adb push android/libsqlite3.so /data/local/tmp/libsqlite3.so
adb shell chmod 755 /data/local/tmp/libsqlite3.so
```
Then build an arbitrary target .dart file in this project in which must call `copyLibToAppDir()` to copy `/data/local/tmp/libsqlite3.so` to application directory.\
e.g.`flutter run -t copy.dart -d emulator-5554`
```dart
void copyLibToAppDir() async {
    final source = File('/data/local/tmp/libsqlite3.so');
    //When application can't find libsqlite3.so, it will occur exception of this path 
    final destination = File(
      '/data/data/com.example.ai_vocabulary/lib/libsqlite3.so',
    );

    if (await source.exists()) {
      await destination.create(recursive: true);
      await source.copy(destination.path);
      print("sqlite3 copied successfully!");
    } else {
      print("sqlite3 file not found!");
    }
  }
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.