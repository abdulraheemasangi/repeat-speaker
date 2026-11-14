import os
import re

manifest_path = "android/app/src/main/AndroidManifest.xml"
if os.path.exists(manifest_path):
    with open(manifest_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Add Wakelock and TTS queries
    if "android.intent.action.TTS_SERVICE" not in content:
        insert_block = """
    <!-- Permissions and queries for Wakelock and TTS engines -->
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.INTERNET" />
    <queries>
        <intent>
            <action android:name="android.intent.action.TTS_SERVICE" />
        </intent>
    </queries>
</manifest>"""
        content = content.replace("</manifest>", insert_block)

    # 2. Update app label
    content = re.sub(r'android:label="[^"]*"', 'android:label="Repeat Speaker"', content)

    # 3. Lock portrait orientation
    if 'android:screenOrientation="portrait"' not in content:
        content = content.replace(
            'android:name=".MainActivity"',
            'android:name=".MainActivity"\n            android:screenOrientation="portrait"'
        )

    with open(manifest_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Successfully configured AndroidManifest.xml")

gradle_path = "android/app/build.gradle"
if os.path.exists(gradle_path):
    with open(gradle_path, "r", encoding="utf-8") as f:
        gradle = f.read()

    # Ensure release uses debug signing config so release APK is immediately installable
    if "signingConfig signingConfigs.debug" not in gradle and "signingConfig = signingConfigs.debug" not in gradle:
        # Check if release block exists
        if "release {" in gradle:
            gradle = re.sub(
                r'release\s*\{',
                'release {\n            signingConfig = signingConfigs.debug',
                gradle
            )
        else:
            gradle = gradle.replace(
                "buildTypes {",
                "buildTypes {\n        release {\n            signingConfig = signingConfigs.debug\n        }"
            )

    with open(gradle_path, "w", encoding="utf-8") as f:
        f.write(gradle)
    print("Successfully configured android/app/build.gradle")
