# Play release — EnCaisse 1.0.16 (version code 17)

## Summary

- Flexible splits: equal or custom amounts between chosen members
- Foreign-currency expenses converted at a chosen rate
- Recurring expenses and deposits (weekly / monthly)
- Simplified settle-up with one-tap "I paid" and recipient confirmation
- Personal caisse, search and filters, app lock, home-screen widget, invite links
- Instant group deletion, fixed brand title, Crashlytics
- Fixes: French home actions overflow, "you owe" colour on home, settle rows
  alignment, balance formatting consistency, "Phone language" now applies
  without restarting the app

## AAB

```
flutter build appbundle --release
```
Output: `build\app\outputs\bundle\release\app-release.aab` — version **1.0.16** / code **17**

Deploy the backend **before** rolling out (callables for splits, currencies,
recurring and settlements must be live):
```
firebase deploy --only functions,firestore:rules,firestore:indexes
```

## Release notes (What's new — max 500 characters per language)

<en-US>
• Split expenses equally or with custom amounts
• Pay in another currency: converted into the caisse currency
• Recurring expenses and deposits
• Who owes whom, with one-tap "I paid"
• Personal caisse, search & filters, app lock and a home-screen widget
• Invite links, faster group deletion and many fixes
</en-US>

<fr-FR>
• Partagez les dépenses à parts égales ou personnalisées
• Payez dans une autre devise, convertie dans celle de la caisse
• Dépenses et dépôts récurrents
• Qui doit quoi à qui, avec « J’ai payé » en un geste
• Caisse personnelle, recherche et filtres, verrouillage et widget
• Liens d’invitation, suppression de groupe instantanée et corrections
</fr-FR>

<ar>
• قسّم المصاريف بالتساوي أو بمبالغ مخصّصة
• ادفع بعملة أخرى تُحوَّل إلى عملة الصندوق
• مصاريف وإيداعات متكررة
• من يدين لمن، مع زر «دفعت» بلمسة واحدة
• صندوق شخصي، بحث وتصفية، قفل التطبيق وأداة للشاشة الرئيسية
• روابط دعوة، حذف أسرع للمجموعات وإصلاحات عديدة
</ar>

## Store listing

Update the listing at the same time as this release — the new screenshots
show 1.0.16 features. Text and steps: `STORE_LISTING.md`; images:
`screenshots/en-US/` and `screenshots/fr-FR/`.
