## Requirements
- Flutter installed on yuor machine. See: https://docs.flutter.dev/get-started/install
- Visual Studio Code
- Install Flutter plug-in in VSCode. Marketplace -> Search 'Flutter' -> Install
- Create .env in root directory
- (Optional) scrcpy, see: https://github.com/Genymobile/scrcpy

## Environment
Insert this to your .env
```
SUPABASE_URL=SOME_VALUE
SUPABASE_ANONKEY=SOME_VALUE
```

The value of this is in your Supabase account

## Running the application
1. In your terminal, go to root directory and run ``` flutter pub get ```

## Building APK/iOS
1. For APK ``` flutter build apk --release ```. APK file will located in build/app/outputs/flutter-apk/app-release.apk.