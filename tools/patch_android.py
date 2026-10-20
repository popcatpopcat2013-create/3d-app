#!/usr/bin/env python3
"""Patch the AndroidManifest.xml that `flutter create` generates.

Adds the photo permissions the app needs and the app name shown on the phone.
Safe to run more than once: it skips anything that is already there.
"""

import re
import sys
from pathlib import Path

MANIFEST = Path("android/app/src/main/AndroidManifest.xml")
APP_LABEL = "Photo Swipe"

PERMISSIONS = """
    <!-- Photo Swipe: read photos, and delete the ones the user trashed -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="29" />
"""


def main() -> int:
    if not MANIFEST.exists():
        print(f"error: {MANIFEST} not found. Create the Android project first.", file=sys.stderr)
        return 1

    text = MANIFEST.read_text(encoding="utf-8")

    if "READ_MEDIA_IMAGES" not in text:
        text, count = re.subn(
            r"(<manifest[^>]*>)",
            lambda match: match.group(1) + "\n" + PERMISSIONS,
            text,
            count=1,
        )
        if count != 1:
            print("error: could not find the <manifest> tag", file=sys.stderr)
            return 1

    # Android 10 needs this flag to be allowed to delete photos
    if "requestLegacyExternalStorage" not in text:
        text, count = re.subn(
            r"<application",
            '<application\n        android:requestLegacyExternalStorage="true"',
            text,
            count=1,
        )
        if count != 1:
            print("error: could not find the <application> tag", file=sys.stderr)
            return 1

    text = re.sub(r'(android:label=")[^"]*(")', rf"\g<1>{APP_LABEL}\g<2>", text, count=1)

    MANIFEST.write_text(text, encoding="utf-8")
    print(f"Patched {MANIFEST}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
