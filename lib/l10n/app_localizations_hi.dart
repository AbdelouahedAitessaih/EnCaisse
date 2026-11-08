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
  String get noGroupsSubtitle =>
      'व्यक्तिगत कैश से शुरू करें, समूह बनाएँ, या कोड से जुड़ें।';

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
  String get filters => 'फ़िल्टर';

  @override
  String get applyFilters => 'लागू करें';

  @override
  String get filterUser => 'उपयोगकर्ता';

  @override
  String get filterDate => 'तारीख';

  @override
  String get filterAnyTime => 'कोई भी तारीख';

  @override
  String get filterThisMonth => 'इस महीने';

  @override
  String get filterLast30Days => 'पिछले 30 दिन';

  @override
  String get filterChooseDates => 'तारीखें चुनें';

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
  String get movementDeletedUndo => 'लेन-देन हटाया गया';

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
      'अकेले या दोस्तों के साथ ट्रैक करें। साझा समूह में सभी जमा/खर्च जोड़ सकते हैं — कोई एडमिन पदानुक्रम नहीं।';

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
  String get welcomeSubtitle => 'अपना पैसा अकेले या दूसरों के साथ संभालें।';

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
      'जारी रखने के लिए EnCaisse का नया संस्करण आवश्यक है। स्टोर से अपडेट करें।';

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

  @override
  String get verifyEmailTitle => 'अपना ईमेल सत्यापित करें';

  @override
  String verifyEmailBody(String email) {
    return 'हमने $email पर सत्यापन लिंक भेजा है। खोलें, फिर जारी रखें टैप करें।';
  }

  @override
  String get resendVerification => 'ईमेल फिर भेजें';

  @override
  String get verificationEmailSent => 'सत्यापन ईमेल भेजा गया';

  @override
  String get emailVerifiedContinue => 'जारी रखें';

  @override
  String get emailNotVerifiedYet => 'ईमेल अभी सत्यापित नहीं। इनबॉक्स देखें।';

  @override
  String get checkVerification => 'मैंने सत्यापित कर लिया';

  @override
  String get settleTitle => 'किसका कितना बकाया';

  @override
  String get settleSubtitle => 'जमा और खर्च के आधार पर बराबर हिस्सा।';

  @override
  String get settleSettled => 'सब बराबर हैं';

  @override
  String settleOwes(String from, String to) {
    return '$from का $to को बकाया';
  }

  @override
  String get memberNet => 'नेट';

  @override
  String get chartsTitle => 'चार्ट';

  @override
  String get categoryBreakdown => 'श्रेणी के अनुसार खर्च';

  @override
  String get exportCsv => 'CSV निर्यात';

  @override
  String get exportPdf => 'PDF निर्यात';

  @override
  String get exportShared => 'निर्यात साझा करने के लिए तैयार';

  @override
  String get exportFailed => 'निर्यात नहीं हो सका';

  @override
  String get notifications => 'सूचनाएँ';

  @override
  String get noNotifications => 'अभी कोई सूचना नहीं';

  @override
  String get noNotificationsSubtitle => 'आपके समूहों की गतिविधि यहाँ दिखेगी।';

  @override
  String get markAllRead => 'सभी पढ़ा चिह्नित करें';

  @override
  String get offlineBanner =>
      'आप ऑफ़लाइन हैं। उपलब्ध होने पर कैश डेटा दिख रहा है।';

  @override
  String get offlineRetry => 'फिर कोशिश करें';

  @override
  String get forceUpdateBodyIos =>
      'EnCaisse का नया संस्करण आवश्यक है। App Store से अपडेट करें।';

  @override
  String get openStore => 'स्टोर खोलें';

  @override
  String get insightsTitle => 'विश्लेषण';

  @override
  String get insightsOpen => 'विश्लेषण';

  @override
  String get yourCaisses => 'आपकी कैश';

  @override
  String get homeOverview => 'आपका पैसा, एक ही जगह पर।';

  @override
  String get personalCaisse => 'व्यक्तिगत कैश';

  @override
  String get personalCaisseSubtitle => 'अपने पैसे का हिसाब रखने की निजी जगह।';

  @override
  String get personalCaisseName => 'मेरी कैश';

  @override
  String get personalBadge => 'व्यक्तिगत';

  @override
  String get manageCaisse => 'अपनी कैश प्रबंधित करें';

  @override
  String get renameCaisse => 'कैश का नाम बदलें';

  @override
  String get changeCaissePhoto => 'कैश की फ़ोटो बदलें';

  @override
  String get caissePhotoUpdated => 'कैश की फ़ोटो अपडेट हुई';

  @override
  String get caisseRenamed => 'कैश का नाम बदल दिया गया';

  @override
  String get deleteCaisse => 'कैश हटाएँ';

  @override
  String get deleteCaisseConfirm => 'क्या यह कैश हटाएँ?';

  @override
  String get deleteCaisseHint =>
      'इससे आपकी कैश और उसके सभी लेनदेन स्थायी रूप से हट जाएँगे। इसे पूर्ववत नहीं किया जा सकता।';

  @override
  String get caisseDeleted => 'कैश हटा दी गई';

  @override
  String get howToUse => 'EnCaisse कैसे उपयोग करें';

  @override
  String get tourNext => 'आगे';

  @override
  String get tourBack => 'पीछे';

  @override
  String get tourSkip => 'छोड़ें';

  @override
  String get tourDone => 'समझ गया';

  @override
  String get tourHome1Title => 'आपका होम';

  @override
  String get tourHome1Body =>
      'यह सूची आपकी सभी कैश दिखाती है। जमा, खर्च और लाइव बैलेंस देखने के लिए टैप करें।';

  @override
  String get tourHome2Title => 'अकेले ट्रैक करें';

  @override
  String get tourHome2Body =>
      'निजी नोटबुक चाहिए? + दबाकर व्यक्तिगत कैश चुनें। कोई कोड नहीं, सिर्फ आप।';

  @override
  String get tourHome3Title => 'दूसरों के साथ साझा करें';

  @override
  String get tourHome3Body =>
      'समूह बनाएँ या 6-अक्षर कोड से जुड़ें। सभी को एक ही पारदर्शी इतिहास दिखता है।';

  @override
  String get tourGroup1Title => 'लाइव बैलेंस';

  @override
  String get tourGroup1Body =>
      'हरा कार्ड हमेशा लेन-देन से बनता है — जमा घटा खर्च। धोखा देने योग्य संग्रहीत कुल नहीं।';

  @override
  String get tourGroup2Title => 'लेन-देन जोड़ें';

  @override
  String get tourGroup2Body =>
      'जमा या खर्च के लिए + टैप करें। रसीद जोड़ सकते हैं; हर बदलाव ऑडिट में रहता है।';

  @override
  String get tourGroup3Title => 'आमंत्रण और विश्लेषण';

  @override
  String get tourGroup3Body =>
      'कोड साझा करें। सेटल और चार्ट में देखें किसका कितना बकाया और श्रेणी खर्च।';

  @override
  String get tourGroup3BodyPersonal =>
      'खर्चों को श्रेणी के अनुसार देखने के लिए Insights खोलें। यह कैश सिर्फ आपकी है।';

  @override
  String get tapPhotoToChange => 'फोटो बदलने के लिए टैप करें';

  @override
  String get tapPhotoToView => 'देखने के लिए टैप करें';

  @override
  String get creatingPersonal => 'आपकी व्यक्तिगत कैश खुल रही है…';

  @override
  String get categoryFood => 'खाना';

  @override
  String get categoryTransport => 'परिवहन';

  @override
  String get categoryRent => 'किराया';

  @override
  String get categoryUtilities => 'सार्वजनिक सेवाएं';

  @override
  String get categoryEntertainment => 'मनोरंजन';

  @override
  String get categoryShopping => 'खरीदारी';

  @override
  String get categoryHealth => 'स्वास्थ्य';

  @override
  String get categoryTravel => 'यात्रा';

  @override
  String get categorySalary => 'वेतन';

  @override
  String get categoryGift => 'उपहार';

  @override
  String get categoryOther => 'अन्य';

  @override
  String get retry => 'फिर कोशिश करें';

  @override
  String get caisseDeleting => 'कैश हटाया जा रहा है…';

  @override
  String get groupDeleting => 'समूह हटाया जा रहा है…';

  @override
  String get balancePerCaisse =>
      'अलग-अलग मुद्राओं के बैलेंस कभी नहीं जोड़े जाते।';

  @override
  String balanceAcrossCaisses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'कुल $count कैश में',
      one: 'कुल $count कैश में',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountTitle => 'खाता हटाएं';

  @override
  String get deleteAccountSubtitle =>
      'अपना EnCaisse खाता और सभी निजी डेटा हटाएं';

  @override
  String get deleteAccountConfirm => 'क्या आप अपना खाता हटाएं?';

  @override
  String get deleteAccountWarning =>
      'यह कार्रवाई पूर्ववत नहीं की जा सकती। सुरक्षा के लिए, हटाने से पहले फिर से साइन इन करें।';

  @override
  String get security => 'सुरक्षा';

  @override
  String get appLock => 'ऐप लॉक';

  @override
  String get appLockHint =>
      'EnCaisse खोलते समय फ़िंगरप्रिंट, चेहरा या डिवाइस PIN माँगें';

  @override
  String get appLockUnavailable =>
      'इस डिवाइस पर कोई फ़िंगरप्रिंट, चेहरा या स्क्रीन लॉक सेट नहीं है';

  @override
  String get appLockReason => 'EnCaisse अनलॉक करें';

  @override
  String get appLockTitle => 'EnCaisse लॉक है';

  @override
  String get appLockUnlock => 'अनलॉक करें';

  @override
  String convertedAmount(String amount) {
    return '= कैश की मुद्रा में $amount';
  }

  @override
  String get enterValidRate => 'मान्य विनिमय दर दर्ज करें';

  @override
  String exchangeRateLabel(String from, String to) {
    return 'विनिमय दर (1 $from = ? $to)';
  }

  @override
  String get exchangeRateUnavailable => 'दर नहीं मिल सकी। इसे स्वयं दर्ज करें।';

  @override
  String get formerMember => 'पूर्व सदस्य';

  @override
  String homeWidgetMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count और कैश',
      one: '+1 और कैश',
    );
    return '$_temp0';
  }

  @override
  String homeWidgetUpdated(String time) {
    return '$time पर अपडेट किया गया';
  }

  @override
  String get markReceived => 'प्राप्त के रूप में चिह्नित करें';

  @override
  String markReceivedConfirm(String name, String amount) {
    return 'पुष्टि करें कि आपको $name से $amount मिले?';
  }

  @override
  String paidInCurrency(String amount, String rate) {
    return 'मूल राशि $amount · दर $rate';
  }

  @override
  String paymentRequestText(String name, String amount, String group) {
    return 'नमस्ते $name, EnCaisse पर कैश \"$group\" में आप पर मेरे $amount बाकी हैं। धन्यवाद!';
  }

  @override
  String get recurringBadge => 'आवर्ती';

  @override
  String get recurringCreatorLeft => 'रोका गया: इसके निर्माता ने कैश छोड़ दिया';

  @override
  String get recurringEmpty =>
      'किराया, सदस्यता या जेब खर्च स्वचालित करने के लिए लेन-देन जोड़ते समय \"दोहराएँ\" चुनें।';

  @override
  String recurringNext(String date) {
    return 'अगला: $date';
  }

  @override
  String recurringSetupFailed(String details) {
    return 'लेन-देन सहेजा गया, लेकिन दोहराव सेट नहीं हो सका: $details';
  }

  @override
  String get recurringSkippedBalance => 'पिछला रन छोड़ा गया: पर्याप्त शेष नहीं';

  @override
  String get recurringSkippedSplit =>
      'पिछला रन छोड़ा गया: कुछ प्रतिभागियों ने कैश छोड़ दिया';

  @override
  String get recurringStop => 'रोकें';

  @override
  String get recurringStopConfirm =>
      'यह आवर्ती लेन-देन रोकें? पहले से बने लेन-देन बने रहेंगे।';

  @override
  String get recurringTitle => 'आवर्ती लेन-देन';

  @override
  String get repeatLabel => 'दोहराएँ';

  @override
  String get repeatNever => 'कभी नहीं';

  @override
  String get repeatWeekly => 'हर सप्ताह';

  @override
  String get repeatMonthly => 'हर महीने';

  @override
  String get requestPayment => 'भुगतान का अनुरोध करें';

  @override
  String get searchMovements => 'लेन-देन खोजें';

  @override
  String shareInviteLinkText(String name, String link, String code) {
    return 'EnCaisse पर मेरे कैश \"$name\" से जुड़ें: $link\nया ऐप में कोड $code दर्ज करें।';
  }

  @override
  String get splitBalanced => 'हिस्से राशि से मेल खाते हैं';

  @override
  String splitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count में बँटा',
      one: '1 व्यक्ति के लिए',
    );
    return '$_temp0';
  }

  @override
  String get splitCustom => 'कस्टम';

  @override
  String get splitEqually => 'बराबर';

  @override
  String get splitEveryone => 'सभी';

  @override
  String get splitJustMe => 'केवल मैं';

  @override
  String get splitMustMatch => 'हिस्सों का योग राशि के बराबर होना चाहिए';

  @override
  String get splitPickSomeone => 'कम से कम एक व्यक्ति चुनें';

  @override
  String splitRemaining(String amount) {
    return 'बाँटना शेष: $amount';
  }

  @override
  String get splitTitleDeposit => 'योगदानकर्ता';

  @override
  String get splitTitleExpense => 'इनके बीच बँटा';

  @override
  String get you => 'आप';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get resetPasswordTitle => 'पासवर्ड रीसेट करें';

  @override
  String get resetPasswordBody =>
      'अपने खाते का ईमेल दर्ज करें, हम नया पासवर्ड चुनने का लिंक भेजेंगे।';

  @override
  String get resetPasswordSend => 'लिंक भेजें';

  @override
  String resetPasswordSent(String email) {
    return 'यदि $email के लिए खाता है, तो रीसेट लिंक आ रहा है। इनबॉक्स और स्पैम देखें।';
  }

  @override
  String get resetPasswordTooMany =>
      'बहुत अधिक प्रयास। कुछ मिनट रुककर फिर कोशिश करें।';

  @override
  String get resetPasswordFailed =>
      'ईमेल नहीं भेजा जा सका। कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String get memberSettled => 'बराबर';

  @override
  String get addPhoto => 'फ़ोटो जोड़ें';

  @override
  String availableInCaisse(String amount) {
    return 'उपलब्ध: $amount';
  }
}
