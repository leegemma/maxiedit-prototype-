---
description: Build debug APK, install on Palma, launch — full one-shot pipeline
allowed-tools: Bash
---

Build a debug APK from the current `index.html` and install it on the BOOX Palma
test device. Project root: `/c/Users/SAMSUNG/Projects/maxiedit-prototype`.

Run these sequentially. Stop and report immediately if any step fails:

1. **Refresh www/** —
   ```bash
   bash -c "rm -rf www && mkdir www && cp index.html www/index.html && cp -R images www/images && cp -R lib www/lib"
   ```

2. **Sync native bundle** — `npx cap sync android`

3. **Build debug APK** — `cd android && ./gradlew assembleDebug` (cd back to project root after)

4. **Install on Palma** —
   ```bash
   adb -s E55CA8AC install -r android/app/build/outputs/apk/debug/app-debug.apk
   ```

5. **Re-enable package** (BOOX auto-disables newly installed apps) —
   ```bash
   adb -s E55CA8AC shell pm enable com.leegemma.maxiedit
   ```

6. **Force-stop + relaunch** —
   ```bash
   adb -s E55CA8AC shell am force-stop com.leegemma.maxiedit
   adb -s E55CA8AC shell am start -n com.leegemma.maxiedit/.MainActivity
   ```

When all six finish, report "APK installed and launched on Palma" in one line.

If the device is unauthorized or unreachable, surface the adb error and stop —
don't try to recover.
