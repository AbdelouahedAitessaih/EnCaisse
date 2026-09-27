# Firestore rules tests

Install the test dependencies with `npm install` from this directory, then run
the suite against the Firestore emulator from the repository root:

```sh
firebase emulators:exec --only firestore "npm --prefix firebase/rules-tests test"
```

The tests load `firebase/firestore.rules` directly and use emulator-only seed
data. They never connect to the production Firebase project.
