// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'EnCaisse';

  @override
  String get tagline => 'EnCaisse, ensemble.';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get alreadyHaveAccount => 'मेरा पहले से खाता है';

  @override
  String get skip => 'छोड़ें';

  @override
  String get next => 'अगला';

  @override
  String get createAccount => 'खाता बनाएँ';

  @override
  String get signIn => 'साइन इन';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get welcomeBack => 'वापसी पर स्वागत है';

  @override
  String get signInSubtitle => 'अपने EnCaisse खाते में साइन इन करें।';

  @override
  String get joinEncaisse => 'EnCaisse से जुड़ें';

  @override
  String get signUpSubtitle => 'पूर्ण पारदर्शिता के साथ साझा नकद ट्रैक करें।';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get displayName => 'प्रदर्शित नाम';

  @override
  String get or => 'या';

  @override
  String get continueWithGoogle => 'Google के साथ जारी रखें';

  @override
  String get needAccount => 'खाता चाहिए? साइन अप करें';

  @override
  String get haveAccount => 'पहले से खाता है? साइन इन करें';

  @override
  String get enterEmail => 'अपना ईमेल दर्ज करें';

  @override
  String get validEmail => 'मान्य ईमेल दर्ज करें';

  @override
  String get passwordMin => 'पासवर्ड कम से कम 6 अक्षर का होना चाहिए';

  @override
  String get rememberMe => 'मुझे याद रखें';

  @override
  String get showPassword => 'पासवर्ड दिखाएं';

  @override
  String get hidePassword => 'पासवर्ड छिपाएं';

  @override
  String get enterName => 'अपना नाम दर्ज करें';

  @override
  String get hello => 'नमस्ते';

  @override
  String helloName(String name) {
    return 'नमस्ते, $name';
  }

  @override
  String get noGroupsYet => 'अभी कोई समूह नहीं';

  @override
  String get noGroupsSubtitle => 'एक कैस बनाएँ या आमंत्रण कोड से जुड़ें।';

  @override
  String get createAGroup => 'समूह बनाएँ';

  @override
  String get joinWithCode => 'कोड से जुड़ें';

  @override
  String get joinWithInviteCode => 'आमंत्रण कोड से जुड़ें';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get appearance => 'दिखावट';

  @override
  String get language => 'भाषा';

  @override
  String get languageSystem => 'फ़ोन की भाषा';

  @override
  String get themeMode => 'थीम';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get languageEnglish => 'अंग्रेज़ी';

  @override
  String get languageFrench => 'फ़्रेंच';

  @override
  String get languageArabic => 'अरबी';

  @override
  String get languageSpanish => 'स्पेनिश';

  @override
  String get languagePortuguese => 'पुर्तगाली';

  @override
  String get languageChinese => 'चीनी';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageRussian => 'रूसी';

  @override
  String get languageJapanese => 'जापानी';

  @override
  String get nameYourCaisse => 'अपने कैस का नाम रखें';

  @override
  String get inviteCodeHint =>
      'साझा करने के लिए आपको 6 अक्षर का आमंत्रण कोड मिलेगा।';

  @override
  String get groupName => 'समूह का नाम';

  @override
  String get groupNameHint => 'वीकेंड ट्रिप, फ्लैटमैट्स…';

  @override
  String get enterGroupName => 'समूह का नाम दर्ज करें';

  @override
  String get currency => 'मुद्रा';

  @override
  String get selectCurrency => 'मुद्रा चुनें';

  @override
  String get startingAmountOptional => 'प्रारंभिक राशि (वैकल्पिक)';

  @override
  String get startingAmountHelper =>
      'बाद में केवल आप (निर्माता) ही इस राशि को संपादित कर सकते हैं।';

  @override
  String get createGroup => 'समूह बनाएँ';

  @override
  String get enterInviteCode => 'आमंत्रण कोड दर्ज करें';

  @override
  String askForCode(int length) {
    return 'किसी सदस्य से $length-अक्षर का कोड माँगें।';
  }

  @override
  String get inviteCode => 'आमंत्रण कोड';

  @override
  String get joinGroup => 'समूह में जुड़ें';

  @override
  String enterCodeLength(int length) {
    return '$length-अक्षर का कोड दर्ज करें';
  }

  @override
  String get noGroupForCode => 'इस आमंत्रण कोड के लिए कोई समूह नहीं मिला।';

  @override
  String get balance => 'शेष राशि';

  @override
  String get inLabel => 'आवक';

  @override
  String get outLabel => 'जावक';

  @override
  String get members => 'सदस्य';

  @override
  String get byCategory => 'श्रेणी के अनुसार';

  @override
  String get filterAll => 'सभी';

  @override
  String get filterUser => 'उपयोगकर्ता';

  @override
  String get filterDate => 'तारीख';

  @override
  String get clearFilters => 'फ़िल्टर हटाएँ';

  @override
  String get noMatchingMovements => 'इन फ़िल्टर से कोई लेन-देन मेल नहीं खाता।';

  @override
  String get inviteFriends => 'मित्रों को आमंत्रित करें';

  @override
  String get shareCodeSoFriends => 'दोस्तों के जुड़ने के लिए यह कोड साझा करें।';

  @override
  String get shareThisCode => 'दूसरों के जुड़ने के लिए यह कोड साझा करें।';

  @override
  String get copyCode => 'कोड कॉपी करें';

  @override
  String get share => 'साझा करें';

  @override
  String inviteCodeCopied(String code) {
    return 'आमंत्रण कोड $code कॉपी हो गया';
  }

  @override
  String shareInviteText(String name, String code) {
    return 'कोड $code से मेरे EnCaisse समूह \"$name\" में जुड़ें। EnCaisse, ensemble.';
  }

  @override
  String joinOnEncaisse(String name) {
    return 'EnCaisse पर $name में जुड़ें';
  }

  @override
  String get notificationsMuted => 'इस समूह की सूचनाएँ म्यूट हैं';

  @override
  String get notificationsEnabled => 'इस समूह की सूचनाएँ चालू हैं';

  @override
  String get unmuteNotifications => 'सूचनाएँ अनम्यूट करें';

  @override
  String get muteNotifications => 'सूचनाएँ म्यूट करें';

  @override
  String get noMovementsYet => 'अभी कोई लेन-देन नहीं';

  @override
  String get noMovementsSubtitle => 'इस कैस के लिए पहला जमा या खर्च जोड़ें।';

  @override
  String get addMovement => 'लेन-देन जोड़ें';

  @override
  String get editMovement => 'लेन-देन संपादित करें';

  @override
  String get movement => 'लेन-देन';

  @override
  String get startingBalance => 'प्रारंभिक शेष';

  @override
  String get editStartingBalance => 'प्रारंभिक शेष संपादित करें';

  @override
  String get type => 'प्रकार';

  @override
  String get deposit => 'जमा';

  @override
  String get expense => 'खर्च';

  @override
  String get amount => 'राशि';

  @override
  String get startingAmount => 'प्रारंभिक राशि';

  @override
  String get title => 'शीर्षक';

  @override
  String get titleHint => 'किराना, किराया हिस्सा…';

  @override
  String get category => 'श्रेणी';

  @override
  String get addReceipt => 'रसीद फ़ोटो जोड़ें (वैकल्पिक)';

  @override
  String get receiptSelected => 'रसीद चयनित';

  @override
  String get saveChanges => 'परिवर्तन सहेजें';

  @override
  String get enterValidAmount => 'मान्य राशि दर्ज करें';

  @override
  String get enterTitle => 'शीर्षक दर्ज करें';

  @override
  String get onlyCreatorEditStarting =>
      'केवल आप (निर्माता) ही इस राशि को बदल सकते हैं।';

  @override
  String get onlyCreatorCanEditStarting =>
      'केवल जिसने यह कैस बनाया है वही प्रारंभिक शेष संपादित कर सकता है।';

  @override
  String get onlyYouEditStarting =>
      'केवल आप ही इस प्रारंभिक राशि को संपादित कर सकते हैं।';

  @override
  String get onlyCreatorEditAmount =>
      'केवल कैस निर्माता ही इस राशि को संपादित कर सकता है।';

  @override
  String get createdBy => 'द्वारा बनाया गया';

  @override
  String get created => 'बनाया गया';

  @override
  String get receipt => 'रसीद';

  @override
  String get attached => 'संलग्न';

  @override
  String get auditTrail => 'ऑडिट ट्रेल';

  @override
  String get auditTrailSubtitle =>
      'केवल जोड़ने वाला इतिहास। कोई भी इन प्रविष्टियों को संपादित या हटा नहीं सकता।';

  @override
  String get noAuditYet => 'अभी कोई ऑडिट प्रविष्टि नहीं।';

  @override
  String get deleteMovement => 'लेन-देन हटाएँ?';

  @override
  String get deleteStartingBalance => 'प्रारंभिक शेष हटाएँ?';

  @override
  String get softDeleteHint =>
      'यह लेन-देन को 24 घंटे के लिए सॉफ्ट-डिलीट करता है। आप स्नैकबार या इस स्क्रीन से पूर्ववत कर सकते हैं।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएँ';

  @override
  String get movementDeletedUndo => 'लेन-देन हटाया गया — पूर्ववत';

  @override
  String get undo => 'पूर्ववत';

  @override
  String get movementRestored => 'लेन-देन पुनर्स्थापित';

  @override
  String get softDeletedCanUndo =>
      'सॉफ्ट-डिलीट — आप अभी भी 24 घंटे में पूर्ववत कर सकते हैं।';

  @override
  String get softDeletedExpired => 'सॉफ्ट-डिलीट — पूर्ववत की समय सीमा समाप्त।';

  @override
  String get undoDelete => 'हटाना पूर्ववत करें';

  @override
  String get actionCreate => 'बनाएँ';

  @override
  String get actionUpdate => 'अपडेट';

  @override
  String get actionDelete => 'हटाएँ';

  @override
  String get groupNotFound => 'समूह नहीं मिला';

  @override
  String get movementNotFound => 'लेन-देन नहीं मिला';

  @override
  String get couldNotLoadGroups =>
      'समूह लोड नहीं हो सके। Firebase सेटअप जाँचें।';

  @override
  String get onboardingTitle1 => 'एक साझा कैस';

  @override
  String get onboardingBody1 =>
      'समूह का हर कोई जमा और खर्च जोड़ सकता है। कोई एडमिन पदानुक्रम नहीं।';

  @override
  String get onboardingTitle2 => 'पूर्ण ऑडिट ट्रेल';

  @override
  String get onboardingBody2 =>
      'हर बदलाव लॉग होता है। विश्वास पारदर्शिता से आता है, अनुमति से नहीं।';

  @override
  String get onboardingTitle3 => 'कोड से आमंत्रित करें';

  @override
  String get onboardingBody3 =>
      'समूह बनाएँ या 6-अक्षर के आमंत्रण कोड से जुड़ें।';

  @override
  String get welcomeSubtitle => 'साझा समूह नकद, सभी के लिए पारदर्शी।';

  @override
  String get validStartingAmount =>
      'मान्य प्रारंभिक राशि दर्ज करें (या खाली छोड़ें)।';

  @override
  String get manageGroup => 'समूह प्रबंधित करें';

  @override
  String get renameGroup => 'समूह का नाम बदलें';

  @override
  String get renameGroupHint => 'इस कैस के लिए नया नाम दर्ज करें।';

  @override
  String get save => 'सहेजें';

  @override
  String get manageMembers => 'सदस्य प्रबंधित करें';

  @override
  String get removeMember => 'हटाएँ';

  @override
  String removeMemberConfirm(String name) {
    return '$name को इस समूह से हटाएँ?';
  }

  @override
  String get memberRemoved => 'सदस्य हटाया गया';

  @override
  String get cannotRemoveCreator => 'आप समूह निर्माता को नहीं हटा सकते।';

  @override
  String get deleteGroup => 'समूह हटाएँ';

  @override
  String get deleteGroupConfirm => 'यह समूह हटाएँ?';

  @override
  String get deleteGroupHint =>
      'यह समूह, सदस्यों और सभी लेन-देन को स्थायी रूप से हटा देगा। पूर्ववत नहीं हो सकता।';

  @override
  String get groupDeleted => 'समूह हटाया गया';

  @override
  String get groupRenamed => 'समूह का नाम बदला गया';

  @override
  String get creator => 'निर्माता';

  @override
  String get changeGroupPhoto => 'समूह फ़ोटो बदलें';

  @override
  String get groupPhotoUpdated => 'समूह फ़ोटो अपडेट हुई';

  @override
  String get leaveGroup => 'समूह छोड़ें';

  @override
  String get leaveGroupHint =>
      'आप यह समूह छोड़ देंगे, लेकिन आपके लेन-देन इतिहास में रहेंगे।';

  @override
  String get leftGroup => 'आपने समूह छोड़ दिया';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get changePhoto => 'फ़ोटो बदलें';

  @override
  String get profileUpdated => 'प्रोफ़ाइल अपडेट हुई';

  @override
  String get incorrectCredentials => 'ईमेल या पासवर्ड गलत है।';

  @override
  String get firebaseNotConfigured =>
      'Firebase अभी कॉन्फ़िगर नहीं है। अपना google-services.json जोड़ें।';

  @override
  String get signInFailed => 'साइन इन विफल। कृपया फिर कोशिश करें।';

  @override
  String get signUpFailed => 'साइन अप विफल। कृपया फिर कोशिश करें।';

  @override
  String get googleSignInCanceled => 'Google साइन-इन रद्द किया गया।';

  @override
  String get googleSignInConfigError =>
      'Google साइन-इन कॉन्फ़िगर नहीं है। Firebase में SHA-1 जोड़ें और नया google-services.json डाउनलोड करें।';

  @override
  String get googleSignInFailed => 'Google साइन-इन विफल। कृपया फिर कोशिश करें।';

  @override
  String get forceUpdateTitle => 'अपडेट आवश्यक';

  @override
  String get forceUpdateBody =>
      'जारी रखने के लिए EnCaisse का नया संस्करण आवश्यक है। Google Play से अपडेट करें।';

  @override
  String get updateAvailableTitle => 'अपडेट उपलब्ध';

  @override
  String get updateAvailableBody =>
      'EnCaisse का नया संस्करण उपलब्ध है जिसमें महत्वपूर्ण सुधार हैं।';

  @override
  String get updateNow => 'अभी अपडेट करें';

  @override
  String get updateLater => 'बाद में';

  @override
  String get emailAlreadyInUse => 'इस ईमेल के लिए खाता पहले से मौजूद है।';

  @override
  String get weakPassword => 'मज़बूत पासवर्ड चुनें।';

  @override
  String get member => 'सदस्य';

  @override
  String get aMember => 'एक सदस्य';

  @override
  String get someoneJoined => 'कोई जुड़ा';

  @override
  String memberJoinedBody(String name, String group) {
    return '$name $group में जुड़ा';
  }

  @override
  String get joinAGroup => 'समूह में जुड़ें';

  @override
  String errorWithDetails(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get enterValidAmountGtZero => 'शून्य से अधिक मान्य राशि दर्ज करें।';

  @override
  String couldNotLoadAudit(String error) {
    return 'ऑडिट लोड नहीं हो सका: $error';
  }

  @override
  String get newMovementNotify => 'नया लेन-देन';

  @override
  String get depositNotifyTitle => 'नया जमा';

  @override
  String get expenseNotifyTitle => 'नया खर्च';

  @override
  String get movementUpdatedNotify => 'लेन-देन अपडेट';

  @override
  String get movementDeletedNotify => 'लेन-देन हटाया गया';

  @override
  String get movementRestoredNotify => 'लेन-देन पुनर्स्थापित';

  @override
  String addedDeposit(String name, String title) {
    return '$name ने जमा जोड़ा: $title';
  }

  @override
  String addedExpense(String name, String title) {
    return '$name ने खर्च जोड़ा: $title';
  }

  @override
  String addedDepositAmount(String name, String amount, String title) {
    return '$name ने $amount का जमा जोड़ा: $title';
  }

  @override
  String addedExpenseAmount(String name, String amount, String title) {
    return '$name ने $amount का खर्च जोड़ा: $title';
  }

  @override
  String updatedMovementBy(String name, String title) {
    return '$name ने अपडेट किया: $title';
  }

  @override
  String deletedMovementBy(String name, String title) {
    return '$name ने हटाया: $title';
  }

  @override
  String restoredMovementBy(String name, String title) {
    return '$name ने पुनर्स्थापित किया: $title';
  }

  @override
  String get deletedMarker => 'हटाया गया';

  @override
  String get insufficientBalance =>
      'पर्याप्त शेष नहीं। इससे कैश नकारात्मक हो जाएगा।';

  @override
  String get dateLabel => 'तारीख';

  @override
  String get timeLabel => 'समय';
}
