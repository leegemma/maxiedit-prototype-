---
description: Build signed release AAB for Play Console upload (no push, no install)
allowed-tools: Bash
---

Produce a signed `app-release.aab` for Play Console upload. Project root:
`/c/Users/SAMSUNG/Projects/maxiedit-prototype`.

Steps:

1. **Refresh www/** —
   ```bash
   bash -c "rm -rf www && mkdir www && cp index.html www/index.html && cp -R images www/images && cp -R lib www/lib"
   ```

2. **Sync native bundle** — `npx cap sync android`

3. **Build signed bundle** — `cd android && ./gradlew bundleRelease` (cd back after)

4. **Locate output** — `ls -la android/app/build/outputs/bundle/release/app-release.aab`

5. **Verify signature** —
   ```bash
   "/c/Program Files/Microsoft/jdk-17.0.18.8-hotspot/bin/jarsigner.exe" -verify android/app/build/outputs/bundle/release/app-release.aab 2>&1 | tail -3
   ```

   The output should contain "signer certificate will expire on 2053-09-27" —
   that confirms the maxiedit-release.keystore signed it. Warnings about
   "signed in JarFile but is not signed in JarInputStream" are benign AAB
   metadata, not signature failures.

When done, report the AAB file path and size, plus the signer expiry date.
DO NOT push, install, or upload — this command only produces the artifact.

If `keystore.properties` is missing the build will silently fall back to
unsigned. If you see no signing step in the gradle log, stop and report —
the user needs to fill in `keystore.properties`.
