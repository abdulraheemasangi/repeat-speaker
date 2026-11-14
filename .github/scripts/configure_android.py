import os
import re

print("Running configure_android.py...")

# 1. Update AndroidManifest.xml
manifest_path = "android/app/src/main/AndroidManifest.xml"
if os.path.exists(manifest_path):
    with open(manifest_path, "r", encoding="utf-8") as f:
        manifest = f.read()

    # Add Wakelock, Internet, and TTS queries
    if "android.intent.action.TTS_SERVICE" not in manifest:
        queries = """
    <!-- Required permissions and package queries for TTS -->
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.INTERNET" />
    <queries>
        <intent>
            <action android:name="android.intent.action.TTS_SERVICE" />
        </intent>
    </queries>
</manifest>"""
        manifest = manifest.replace("</manifest>", queries)

    # Set friendly app title
    manifest = re.sub(r'android:label="[^"]*"', 'android:label="Repeat Speaker"', manifest)

    # Lock portrait orientation
    if 'android:screenOrientation="portrait"' not in manifest:
        manifest = manifest.replace(
            'android:name=".MainActivity"',
            'android:name=".MainActivity"\n            android:screenOrientation="portrait"'
        )

    with open(manifest_path, "w", encoding="utf-8") as f:
        f.write(manifest)
    print("✓ Successfully configured AndroidManifest.xml")
else:
    print(f"Error: {manifest_path} not found!")

# 2. Update android/app/build.gradle for debug signing in release
gradle_path = "android/app/build.gradle"
if os.path.exists(gradle_path):
    with open(gradle_path, "r", encoding="utf-8") as f:
        gradle = f.read()

    # In modern Flutter app/build.gradle, buildTypes has:
    # buildTypes {
    #     release {
    #         signingConfig = signingConfigs.debug
    #     }
    # }
    if "signingConfig = signingConfigs.debug" not in gradle and "signingConfig signingConfigs.debug" not in gradle:
        if "release {" in gradle:
            gradle = re.sub(
                r'release\s*\{',
                'release {\n            // Sign with debug key for direct installation\n            signingConfig = signingConfigs.debug',
                gradle,
                count=1
            )
        else:
            gradle = gradle.replace(
                "buildTypes {",
                "buildTypes {\n        release {\n            signingConfig = signingConfigs.debug\n        }"
            )

    # Ensure minSdk is at least 21
    if "minSdk = flutter.minSdkVersion" in gradle:
        gradle = gradle.replace("minSdk = flutter.minSdkVersion", "minSdk = 21")
    elif "minSdkVersion flutter.minSdkVersion" in gradle:
        gradle = gradle.replace("minSdkVersion flutter.minSdkVersion", "minSdkVersion 21")

    with open(gradle_path, "w", encoding="utf-8") as f:
        f.write(gradle)
    print("✓ Successfully configured android/app/build.gradle")
else:
    print(f"Error: {gradle_path} not found!")
