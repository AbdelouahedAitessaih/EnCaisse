# Google Play Console — complete publishing (EnCaisse)

Your dashboard blocks **Closed testing** until **app information / store listing** is finished. New personal developer accounts also need **20 opted-in closed testers for 14 days** before **Production**.

Work top → bottom.

---

### Data safety — account creation / deletion

**How users create accounts — check both:**
- Username and password  
- OAuth (Google Sign-In)

Do **not** use only “Username and other authentication”.

**Delete account URL** (paste exactly):

```text
https://encaisse-3c7fb.web.app/delete-account.html
```

Privacy policy URL:

```text
https://encaisse-3c7fb.web.app/privacy.html
```


Contact email: `aitsaihabdelouahed@gmail.com`

Your GitHub repo is **private**, so GitHub Pages is not publicly reachable unless you make the repo public (or use GitHub Pro). Prefer **Firebase Hosting** (same project as the app):

```bash
firebase login
cd EnCaisse
firebase deploy --only hosting --project encaisse-3c7fb
```

Then use:

```text
https://encaisse-3c7fb.web.app/privacy.html
```

(or `https://encaisse-3c7fb.firebaseapp.com/privacy.html`)

**Alternative — GitHub Pages:** make the repo **Public** temporarily → Settings → Pages → Branch `main` / folder `/docs` → URL  
`https://abdelouahedaitessaih.github.io/EnCaisse/play-store/privacy.html`

Paste the live URL in Play Console → **App content** → **Privacy policy**.

---

## B. Store listing (Dashboard → Provide app information)

Path: **Grow users → Store presence → Main store listing**

1. Paste text from `STORE_LISTING.md` (name, short & full description).
2. Upload graphics from `docs/play-store/`:
   - `icon-512.png`
   - `feature-graphic.png`
   - the six phone screenshots in `screenshots/en-US/` (and `screenshots/fr-FR/`
     for the French listing), in file order
3. Set **Application type** / category: **Finance**
4. Contact email: your support email  
5. Save → mark listing tasks complete

---

## C. App content declarations

Complete each item under **Policy → App content** (names vary slightly by Console language).

### 1. Privacy policy
Use the public URL from section A.

### 2. Ads
- **Yes**, my app contains ads  
- AdMob / Google advertising

### 3. App access
- All functionality available without special login restrictions **or**  
- Provide demo credentials if you later lock features (not required for EnCaisse if anyone can sign up)

### 4. Content ratings
Start questionnaire → category **Utility / Productivity / Communication** (or Finance if listed)  
Typical answers for EnCaisse:
- No user-generated public social content beyond private groups  
- No violence, sexual content, gambling, drugs  
- Users can share financial amounts inside private groups  
Submit → apply rating to the app

### 5. Target audience
- Age groups: **18 and over** (recommended; financial apps)  
- Not designed for children

### 6. News app
- No

### 7. Data safety (important)

**Does your app collect or share user data?** Yes  

**Collected (and typically shared with Google services as processors):**

| Data type | Collected | Shared* | Purpose |
|-----------|-----------|---------|---------|
| Name | Yes | Yes (Firebase) | App functionality |
| Email | Yes | Yes | Account |
| User IDs | Yes | Yes | Account |
| Photos (profile / receipts) | Yes (optional) | Yes (Storage) | App functionality |
| Financial info (amounts you enter) | Yes | Yes (Firestore, other members) | App functionality |
| App interactions / diagnostics | Yes (as provided by Play/Firebase) | Yes | Analytics / stability (if enabled) |
| Device or other IDs (AD_ID, FCM) | Yes | Yes (AdMob / FCM) | Advertising / messaging |

\*“Shared” in Play’s sense = sent off the device to third parties / cloud. Group members also see shared group data.

**Security practices:**
- Data encrypted in transit (HTTPS / Firebase)
- Users can request deletion (state yes; provide email in privacy policy)

**Data deletion:** Yes — users can request deletion via the contact email (and can leave/delete groups in-app where allowed).

### 8. Government apps
- No

### 9. Financial features
- EnCaisse tracks shared cash **records**; it is **not** a bank, payment processor, or remittance service  
- Declare accordingly (personal finance / expense tracking — **not** banking)

---

## D. Unlock Closed testing

When store listing + app content show complete:

1. **Test and release → Closed testing** (create a track if needed, e.g. `Closed testing — alpha`)
2. Create a release → upload  
   `build/app/outputs/bundle/release/app-release.aab`  
   (rebuild with `flutter build appbundle --release` if needed)
3. Add a **email list** of testers (or Google Group)
4. Roll out the release → copy the **opt-in link** and send it to testers  
5. Testers must open the link and install from Play

**Production gate for new accounts:**
- ≥ **20** testers opted in  
- Closed test running **≥ 14 days**  
- Then **Apply for production**

Internal testing (up to 100) is fine for early checks, but **does not** replace the closed-test requirements above for production access on new accounts.

---

## E. Before every Play upload checklist

- [ ] Real AdMob app / ad unit IDs (not test-only placeholders in UI)
- [ ] Firebase SHA-1 **from Play App signing** added (Console → App integrity)
- [ ] Fresh `google-services.json` after SHA update
- [ ] `android/key.properties` + `upload-keystore.jks` backed up
- [ ] Privacy policy URL live and matching Data safety answers
- [ ] Version code increased in `pubspec.yaml` (this release: `1.0.11+12`)

---

## F. Files in this folder

| File | Use |
|------|-----|
| `icon-512.png` | Store icon |
| `feature-graphic.png` | Feature graphic |
| `phone-*.png` | Phone screenshots |
| `STORE_LISTING.md` | Listing copy |
| `privacy.html` | Host this as Privacy policy URL |
| `PRIVACY_POLICY.md` | Source / markdown version |
| `CONSOLE_CHECKLIST.md` | This guide |
