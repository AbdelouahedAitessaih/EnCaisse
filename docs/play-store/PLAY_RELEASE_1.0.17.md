# Play release — EnCaisse 1.0.17 (version code 18)

## Summary

- Security: Firestore config documents now require authentication (prevents public exposure of app update config)

## AAB

```
flutter build appbundle --release
```
Output: `build\app\outputs\bundle\release\app-release.aab` — version **1.0.17** / code **18**

Deploy the backend **before** rolling out (Firestore rules must be live):
```
firebase deploy --only firestore:rules
```

## Release notes (What's new — max 500 characters per language)

<en-US>
• Security fix: app configuration (force-update settings, remote config) now requires sign-in
• Prevents public exposure of backend configuration and update logic
• Firestore rules hardened and covered by automated tests
• Under-the-hood stability improvements
</en-US>

<fr-FR>
• Correction de sécurité : la configuration de l'app (mise à jour forcée, config à distance) nécessite une connexion
• Empêche l'exposition publique de la configuration backend et de la logique de mise à jour
• Règles Firestore renforcées et couvertes par des tests automatisés
• Améliorations de stabilité internes
</fr-FR>

<ar>
• إصلاح أمني: تكوين التطبيق (إعدادات التحديث الإجباري، التكوين عن بُعد) يتطلب الآن تسجيل الدخول
• يمنع الكشف العام عن تكوين الخادم ومنطق التحديث
• تم تقوية قواعد Firestore وتغطيتها باختبارات آلية
• تحسينات استقرار داخلية
</ar>