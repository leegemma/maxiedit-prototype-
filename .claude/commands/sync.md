---
description: Re-sync www/ from index.html, images/, lib/ for the Capacitor native bundle
allowed-tools: Bash
---

Refresh the `www/` mirror so the Android/iOS native bundle has the latest web
assets. Equivalent to the `sync:www` npm script.

Run from project root `/c/Users/SAMSUNG/Projects/maxiedit-prototype`:

```bash
bash -c "rm -rf www && mkdir www && cp index.html www/index.html && cp -R images www/images && cp -R lib www/lib"
```

Then run `npx cap sync android` to push the refreshed `www/` into
`android/app/src/main/assets/public`.

Report a one-line success message when both finish.
