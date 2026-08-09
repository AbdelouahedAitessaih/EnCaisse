// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'إنكايس';

  @override
  String get tagline => 'إنكايس، معًا.';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get alreadyHaveAccount => 'لدي حساب بالفعل';

  @override
  String get skip => 'تخطّي';

  @override
  String get next => 'التالي';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String get signInSubtitle => 'سجّل الدخول إلى حساب إنكايس.';

  @override
  String get joinEncaisse => 'انضم إلى إنكايس';

  @override
  String get signUpSubtitle => 'تتبّع الصندوق المشترك بشفافية كاملة.';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get displayName => 'الاسم المعروض';

  @override
  String get or => 'أو';

  @override
  String get continueWithGoogle => 'المتابعة مع Google';

  @override
  String get needAccount => 'ليس لديك حساب؟ سجّل';

  @override
  String get haveAccount => 'لديك حساب؟ سجّل الدخول';

  @override
  String get enterEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get validEmail => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get passwordMin => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get enterName => 'أدخل اسمك';

  @override
  String get hello => 'مرحبًا';

  @override
  String helloName(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String get noGroupsYet => 'لا توجد مجموعات بعد';

  @override
  String get noGroupsSubtitle => 'أنشئ صندوقًا أو انضم عبر رمز الدعوة.';

  @override
  String get createAGroup => 'إنشاء مجموعة';

  @override
  String get joinWithCode => 'الانضمام برمز';

  @override
  String get joinWithInviteCode => 'الانضمام برمز الدعوة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get themeMode => 'السمة';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageFrench => 'الفرنسية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageSpanish => 'الإسبانية';

  @override
  String get languagePortuguese => 'البرتغالية';

  @override
  String get languageChinese => 'الصينية';

  @override
  String get languageHindi => 'الهندية';

  @override
  String get languageRussian => 'الروسية';

  @override
  String get languageJapanese => 'اليابانية';

  @override
  String get nameYourCaisse => 'سمِّ صندوقك';

  @override
  String get inviteCodeHint => 'ستحصل على رمز دعوة من 6 أحرف للمشاركة.';

  @override
  String get groupName => 'اسم المجموعة';

  @override
  String get groupNameHint => 'رحلة، شقة مشتركة…';

  @override
  String get enterGroupName => 'أدخل اسم المجموعة';

  @override
  String get currency => 'العملة';

  @override
  String get startingAmountOptional => 'المبلغ الابتدائي (اختياري)';

  @override
  String get startingAmountHelper =>
      'أنت فقط (المنشئ) يمكنك تعديل هذا المبلغ لاحقًا.';

  @override
  String get createGroup => 'إنشاء المجموعة';

  @override
  String get enterInviteCode => 'أدخل رمز الدعوة';

  @override
  String askForCode(int length) {
    return 'اطلب من عضو الرمز المكوّن من $length أحرف.';
  }

  @override
  String get inviteCode => 'رمز الدعوة';

  @override
  String get joinGroup => 'الانضمام للمجموعة';

  @override
  String enterCodeLength(int length) {
    return 'أدخل رمزًا من $length أحرف';
  }

  @override
  String get noGroupForCode => 'لا توجد مجموعة لهذا الرمز.';

  @override
  String get balance => 'الرصيد';

  @override
  String get inLabel => 'داخل';

  @override
  String get outLabel => 'خارج';

  @override
  String get members => 'الأعضاء';

  @override
  String get byCategory => 'حسب الفئة';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterUser => 'المستخدم';

  @override
  String get filterDate => 'التاريخ';

  @override
  String get clearFilters => 'مسح الفلاتر';

  @override
  String get noMatchingMovements => 'لا توجد حركات تطابق هذه الفلاتر.';

  @override
  String get inviteFriends => 'دعوة الأصدقاء';

  @override
  String get shareCodeSoFriends => 'شارك هذا الرمز لينضم الأصدقاء.';

  @override
  String get shareThisCode => 'شارك هذا الرمز لينضم الآخرون.';

  @override
  String get copyCode => 'نسخ الرمز';

  @override
  String get share => 'مشاركة';

  @override
  String inviteCodeCopied(String code) {
    return 'تم نسخ الرمز $code';
  }

  @override
  String shareInviteText(String name, String code) {
    return 'انضم إلى مجموعتي «$name» على إنكايس بالرمز $code. إنكايس، معًا.';
  }

  @override
  String joinOnEncaisse(String name) {
    return 'انضم إلى $name على إنكايس';
  }

  @override
  String get notificationsMuted => 'تم كتم الإشعارات لهذه المجموعة';

  @override
  String get notificationsEnabled => 'تم تفعيل الإشعارات لهذه المجموعة';

  @override
  String get unmuteNotifications => 'إلغاء كتم الإشعارات';

  @override
  String get muteNotifications => 'كتم الإشعارات';

  @override
  String get noMovementsYet => 'لا توجد حركات بعد';

  @override
  String get noMovementsSubtitle => 'أضف أول إيداع أو مصروف لهذا الصندوق.';

  @override
  String get addMovement => 'إضافة حركة';

  @override
  String get editMovement => 'تعديل الحركة';

  @override
  String get movement => 'حركة';

  @override
  String get startingBalance => 'الرصيد الابتدائي';

  @override
  String get editStartingBalance => 'تعديل الرصيد الابتدائي';

  @override
  String get type => 'النوع';

  @override
  String get deposit => 'إيداع';

  @override
  String get expense => 'مصروف';

  @override
  String get amount => 'المبلغ';

  @override
  String get startingAmount => 'المبلغ الابتدائي';

  @override
  String get title => 'العنوان';

  @override
  String get titleHint => 'مشتريات، إيجار…';

  @override
  String get category => 'الفئة';

  @override
  String get addReceipt => 'إضافة صورة إيصال (اختياري)';

  @override
  String get receiptSelected => 'تم اختيار الإيصال';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get enterValidAmount => 'أدخل مبلغًا صالحًا';

  @override
  String get enterTitle => 'أدخل عنوانًا';

  @override
  String get onlyCreatorEditStarting =>
      'أنت فقط (المنشئ) يمكنك تغيير هذا المبلغ.';

  @override
  String get onlyCreatorCanEditStarting =>
      'فقط من أنشأ الصندوق يمكنه تعديل الرصيد الابتدائي.';

  @override
  String get onlyYouEditStarting => 'أنت فقط يمكنك تعديل هذا المبلغ الابتدائي.';

  @override
  String get onlyCreatorEditAmount =>
      'فقط من أنشأ الصندوق يمكنه تعديل هذا المبلغ.';

  @override
  String get createdBy => 'أنشئ بواسطة';

  @override
  String get created => 'تاريخ الإنشاء';

  @override
  String get receipt => 'إيصال';

  @override
  String get attached => 'مرفق';

  @override
  String get auditTrail => 'سجل التغييرات';

  @override
  String get auditTrailSubtitle =>
      'سجل للإضافة فقط. لا يمكن لأي شخص تعديل هذه الإدخالات أو حذفها.';

  @override
  String get noAuditYet => 'لا توجد إدخالات بعد.';

  @override
  String get deleteMovement => 'حذف الحركة؟';

  @override
  String get deleteStartingBalance => 'حذف الرصيد الابتدائي؟';

  @override
  String get softDeleteHint =>
      'حذف مؤقت لمدة 24 ساعة. يمكنك التراجع من الشريط أو هذه الشاشة.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get movementDeletedUndo => 'تم حذف الحركة — تراجع';

  @override
  String get undo => 'تراجع';

  @override
  String get movementRestored => 'تمت استعادة الحركة';

  @override
  String get softDeletedCanUndo => 'حذف مؤقت — يمكنك التراجع خلال 24 ساعة.';

  @override
  String get softDeletedExpired => 'حذف مؤقت — انتهت مهلة التراجع.';

  @override
  String get undoDelete => 'التراجع عن الحذف';

  @override
  String get actionCreate => 'إنشاء';

  @override
  String get actionUpdate => 'تعديل';

  @override
  String get actionDelete => 'حذف';

  @override
  String get groupNotFound => 'المجموعة غير موجودة';

  @override
  String get movementNotFound => 'الحركة غير موجودة';

  @override
  String get couldNotLoadGroups => 'تعذّر تحميل المجموعات. تحقق من Firebase.';

  @override
  String get onboardingTitle1 => 'صندوق مشترك واحد';

  @override
  String get onboardingBody1 =>
      'يمكن للجميع إضافة الإيداعات والمصروفات. بلا تسلسل إداري.';

  @override
  String get onboardingTitle2 => 'سجل شفاف كامل';

  @override
  String get onboardingBody2 =>
      'كل تغيير يُسجَّل. الثقة من الشفافية لا من الصلاحيات.';

  @override
  String get onboardingTitle3 => 'دعوة برمز';

  @override
  String get onboardingBody3 => 'أنشئ مجموعة أو انضم برمز من 6 أحرف.';

  @override
  String get welcomeSubtitle => 'صندوق جماعي مشترك وشفاف للجميع.';

  @override
  String get validStartingAmount =>
      'أدخل مبلغًا ابتدائيًا صالحًا (أو اتركه فارغًا).';

  @override
  String get manageGroup => 'إدارة المجموعة';

  @override
  String get renameGroup => 'إعادة تسمية المجموعة';

  @override
  String get renameGroupHint => 'أدخل اسمًا جديدًا لهذا الصندوق.';

  @override
  String get save => 'حفظ';

  @override
  String get manageMembers => 'إدارة الأعضاء';

  @override
  String get removeMember => 'إزالة';

  @override
  String removeMemberConfirm(String name) {
    return 'إزالة $name من هذه المجموعة؟';
  }

  @override
  String get memberRemoved => 'تمت إزالة العضو';

  @override
  String get cannotRemoveCreator => 'لا يمكنك إزالة منشئ المجموعة.';

  @override
  String get deleteGroup => 'حذف المجموعة';

  @override
  String get deleteGroupConfirm => 'حذف هذه المجموعة؟';

  @override
  String get deleteGroupHint =>
      'سيُحذف المجموعة والأعضاء وجميع الحركات نهائيًا. لا يمكن التراجع.';

  @override
  String get groupDeleted => 'تم حذف المجموعة';

  @override
  String get groupRenamed => 'تمت إعادة تسمية المجموعة';

  @override
  String get creator => 'المنشئ';

  @override
  String get changeGroupPhoto => 'تغيير صورة المجموعة';

  @override
  String get groupPhotoUpdated => 'تم تحديث صورة المجموعة';

  @override
  String get leaveGroup => 'مغادرة المجموعة';

  @override
  String get leaveGroupHint => 'ستغادر هذه المجموعة، لكن حركاتك تبقى في السجل.';

  @override
  String get leftGroup => 'غادرت المجموعة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي';

  @override
  String get incorrectCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get firebaseNotConfigured =>
      'لم يُضبط Firebase بعد. أضف google-services.json.';

  @override
  String get signInFailed => 'فشل تسجيل الدخول. حاول مرة أخرى.';

  @override
  String get signUpFailed => 'فشل إنشاء الحساب. حاول مرة أخرى.';

  @override
  String get googleSignInCanceled => 'تم إلغاء تسجيل الدخول عبر Google.';

  @override
  String get googleSignInConfigError =>
      'تسجيل الدخول عبر Google غير مضبوط. أضف SHA-1 للتطبيق في Firebase ثم نزّل google-services.json جديدًا.';

  @override
  String get googleSignInFailed =>
      'فشل تسجيل الدخول عبر Google. حاول مرة أخرى.';

  @override
  String get emailAlreadyInUse => 'يوجد حساب بهذا البريد بالفعل.';

  @override
  String get weakPassword => 'اختر كلمة مرور أقوى.';

  @override
  String get member => 'عضو';

  @override
  String get aMember => 'عضو';

  @override
  String get someoneJoined => 'انضم شخص ما';

  @override
  String memberJoinedBody(String name, String group) {
    return 'انضم $name إلى $group';
  }

  @override
  String get joinAGroup => 'الانضمام إلى مجموعة';

  @override
  String errorWithDetails(String error) {
    return 'خطأ: $error';
  }

  @override
  String get enterValidAmountGtZero => 'أدخل مبلغًا صالحًا أكبر من صفر.';

  @override
  String couldNotLoadAudit(String error) {
    return 'تعذّر تحميل السجل: $error';
  }

  @override
  String get newMovementNotify => 'حركة جديدة';

  @override
  String get depositNotifyTitle => 'إيداع جديد';

  @override
  String get expenseNotifyTitle => 'مصروف جديد';

  @override
  String get movementUpdatedNotify => 'تم تعديل الحركة';

  @override
  String get movementDeletedNotify => 'تم حذف الحركة';

  @override
  String get movementRestoredNotify => 'تمت استعادة الحركة';

  @override
  String addedDeposit(String name, String title) {
    return 'أضاف $name إيداعًا: $title';
  }

  @override
  String addedExpense(String name, String title) {
    return 'أضاف $name مصروفًا: $title';
  }

  @override
  String addedDepositAmount(String name, String amount, String title) {
    return 'أضاف $name إيداعًا بمبلغ $amount: $title';
  }

  @override
  String addedExpenseAmount(String name, String amount, String title) {
    return 'أضاف $name مصروفًا بمبلغ $amount: $title';
  }

  @override
  String updatedMovementBy(String name, String title) {
    return 'عدّل $name: $title';
  }

  @override
  String deletedMovementBy(String name, String title) {
    return 'حذف $name: $title';
  }

  @override
  String restoredMovementBy(String name, String title) {
    return 'استعاد $name: $title';
  }

  @override
  String get deletedMarker => 'محذوف';

  @override
  String get insufficientBalance => 'رصيد غير كافٍ. هذا سيجعل الصندوق سالباً.';

  @override
  String get dateLabel => 'التاريخ';

  @override
  String get timeLabel => 'الوقت';
}
