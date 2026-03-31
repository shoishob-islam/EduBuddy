@echo off
echo ========================================
echo Building Flutter APK...
echo ========================================
flutter build apk --debug

echo.
echo ========================================
echo Installing APK to device...
echo ========================================
C:\Users\ACER\AppData\Local\Android\sdk\platform-tools\adb install -r android\app\build\outputs\apk\debug\app-debug.apk

echo.
echo ========================================
echo Launching app...
echo ========================================
C:\Users\ACER\AppData\Local\Android\sdk\platform-tools\adb shell am start -n com.example.app7/.MainActivity

echo.
echo ========================================
echo Done! Timer feature should work.
echo ========================================
pause