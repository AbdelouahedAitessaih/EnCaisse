# AdMob app-ads.txt (EnCaisse)

AdMob verifies the app using this file on your **developer website**.

## Live URL

```text
https://encaisse-3c7fb.web.app/app-ads.txt
```

Content (must match AdMob exactly):

```text
google.com, pub-7691333173853968, DIRECT, f08c47fec0942fa0
```

## Required Play Console setting

Play Console → EnCaisse → **Grow users → Store presence → Main store listing**  
(or **Store settings** / developer contact, depending on Console language)

Set **Website** to:

```text
https://encaisse-3c7fb.web.app
```

AdMob crawls `https://YOUR-DEVELOPER-SITE/app-ads.txt`. If Play has no website, or a different domain, verification fails.

## Deploy / update

```bash
firebase deploy --only hosting --project encaisse-3c7fb
```

Then in AdMob → Verify app → **Check for updates**.  
Propagation can take a few hours (sometimes up to 24h).
