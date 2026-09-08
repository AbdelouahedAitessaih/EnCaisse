// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'EnCaisse';

  @override
  String get tagline => 'EnCaisse, ensemble.';

  @override
  String get getStarted => 'Get started';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get createAccount => 'Create account';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in to your EnCaisse account.';

  @override
  String get joinEncaisse => 'Join EnCaisse';

  @override
  String get signUpSubtitle => 'Track shared cash with full transparency.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get displayName => 'Display name';

  @override
  String get or => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get needAccount => 'Need an account? Sign up';

  @override
  String get haveAccount => 'Already have an account? Sign in';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get validEmail => 'Enter a valid email';

  @override
  String get passwordMin => 'Password must be at least 6 characters';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get enterName => 'Enter your name';

  @override
  String get hello => 'Hello';

  @override
  String helloName(String name) {
    return 'Hello, $name';
  }

  @override
  String get noGroupsYet => 'No groups yet';

  @override
  String get noGroupsSubtitle =>
      'Create a caisse or join one with an invite code.';

  @override
  String get createAGroup => 'Create a group';

  @override
  String get joinWithCode => 'Join with invite code';

  @override
  String get joinWithInviteCode => 'Join with invite code';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Phone language';

  @override
  String get themeMode => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'French';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get nameYourCaisse => 'Name your caisse';

  @override
  String get inviteCodeHint =>
      'You will get a 6-character invite code to share.';

  @override
  String get groupName => 'Group name';

  @override
  String get groupNameHint => 'Weekend trip, Flatmates…';

  @override
  String get enterGroupName => 'Enter a group name';

  @override
  String get currency => 'Currency';

  @override
  String get selectCurrency => 'Select a currency';

  @override
  String get startingAmountOptional => 'Starting amount (optional)';

  @override
  String get startingAmountHelper =>
      'Only you (the creator) can edit this amount later.';

  @override
  String get createGroup => 'Create group';

  @override
  String get enterInviteCode => 'Enter invite code';

  @override
  String askForCode(int length) {
    return 'Ask a member for the $length-character code.';
  }

  @override
  String get inviteCode => 'Invite code';

  @override
  String get joinGroup => 'Join group';

  @override
  String enterCodeLength(int length) {
    return 'Enter a $length-character code';
  }

  @override
  String get noGroupForCode => 'No group found for this invite code.';

  @override
  String get balance => 'Balance';

  @override
  String get inLabel => 'In';

  @override
  String get outLabel => 'Out';

  @override
  String get members => 'Members';

  @override
  String get byCategory => 'By category';

  @override
  String get filterAll => 'All';

  @override
  String get filterUser => 'User';

  @override
  String get filterDate => 'Date';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get noMatchingMovements => 'No movements match these filters.';

  @override
  String get inviteFriends => 'Invite friends';

  @override
  String get shareCodeSoFriends => 'Share this code so friends can join.';

  @override
  String get shareThisCode => 'Share this code so others can join.';

  @override
  String get copyCode => 'Copy code';

  @override
  String get share => 'Share';

  @override
  String inviteCodeCopied(String code) {
    return 'Invite code $code copied';
  }

  @override
  String shareInviteText(String name, String code) {
    return 'Join my EnCaisse group \"$name\" with code $code. EnCaisse, ensemble.';
  }

  @override
  String joinOnEncaisse(String name) {
    return 'Join $name on EnCaisse';
  }

  @override
  String get notificationsMuted => 'Notifications muted for this group';

  @override
  String get notificationsEnabled => 'Notifications enabled for this group';

  @override
  String get unmuteNotifications => 'Unmute notifications';

  @override
  String get muteNotifications => 'Mute notifications';

  @override
  String get noMovementsYet => 'No movements yet';

  @override
  String get noMovementsSubtitle =>
      'Add the first deposit or expense for this caisse.';

  @override
  String get addMovement => 'Add movement';

  @override
  String get editMovement => 'Edit movement';

  @override
  String get movement => 'Movement';

  @override
  String get startingBalance => 'Starting balance';

  @override
  String get editStartingBalance => 'Edit starting balance';

  @override
  String get type => 'Type';

  @override
  String get deposit => 'Deposit';

  @override
  String get expense => 'Expense';

  @override
  String get amount => 'Amount';

  @override
  String get startingAmount => 'Starting amount';

  @override
  String get title => 'Title';

  @override
  String get titleHint => 'Groceries, rent share…';

  @override
  String get category => 'Category';

  @override
  String get addReceipt => 'Add receipt photo (optional)';

  @override
  String get receiptSelected => 'Receipt selected';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String get enterTitle => 'Enter a title';

  @override
  String get onlyCreatorEditStarting =>
      'Only you (the creator) can change this amount.';

  @override
  String get onlyCreatorCanEditStarting =>
      'Only the person who created this caisse can edit the starting balance.';

  @override
  String get onlyYouEditStarting => 'Only you can edit this starting amount.';

  @override
  String get onlyCreatorEditAmount =>
      'Only the caisse creator can edit this amount.';

  @override
  String get createdBy => 'Created by';

  @override
  String get created => 'Created';

  @override
  String get receipt => 'Receipt';

  @override
  String get attached => 'Attached';

  @override
  String get auditTrail => 'Audit trail';

  @override
  String get auditTrailSubtitle =>
      'Append-only history. Nobody can edit or delete these entries.';

  @override
  String get noAuditYet => 'No audit entries yet.';

  @override
  String get deleteMovement => 'Delete movement?';

  @override
  String get deleteStartingBalance => 'Delete starting balance?';

  @override
  String get softDeleteHint =>
      'This soft-deletes the movement for 24 hours. You can undo from the snackbar or this screen.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get movementDeletedUndo => 'Movement deleted — Undo';

  @override
  String get undo => 'Undo';

  @override
  String get movementRestored => 'Movement restored';

  @override
  String get softDeletedCanUndo =>
      'Soft-deleted — you can still undo within 24 hours.';

  @override
  String get softDeletedExpired => 'Soft-deleted — undo window expired.';

  @override
  String get undoDelete => 'Undo delete';

  @override
  String get actionCreate => 'Create';

  @override
  String get actionUpdate => 'Update';

  @override
  String get actionDelete => 'Delete';

  @override
  String get groupNotFound => 'Group not found';

  @override
  String get movementNotFound => 'Movement not found';

  @override
  String get couldNotLoadGroups =>
      'Could not load groups. Check Firebase setup.';

  @override
  String get onboardingTitle1 => 'One shared caisse';

  @override
  String get onboardingBody1 =>
      'Everyone in the group can add deposits and expenses. No admin hierarchy.';

  @override
  String get onboardingTitle2 => 'Full audit trail';

  @override
  String get onboardingBody2 =>
      'Every change is logged. Trust comes from transparency, not permissions.';

  @override
  String get onboardingTitle3 => 'Invite with a code';

  @override
  String get onboardingBody3 =>
      'Create a group or join with a 6-character invite code.';

  @override
  String get welcomeSubtitle => 'Shared group cash, transparent for everyone.';

  @override
  String get validStartingAmount =>
      'Enter a valid starting amount (or leave empty).';

  @override
  String get manageGroup => 'Manage group';

  @override
  String get renameGroup => 'Rename group';

  @override
  String get renameGroupHint => 'Enter a new name for this caisse.';

  @override
  String get save => 'Save';

  @override
  String get manageMembers => 'Manage members';

  @override
  String get removeMember => 'Remove';

  @override
  String removeMemberConfirm(String name) {
    return 'Remove $name from this group?';
  }

  @override
  String get memberRemoved => 'Member removed';

  @override
  String get cannotRemoveCreator => 'You cannot remove the group creator.';

  @override
  String get deleteGroup => 'Delete group';

  @override
  String get deleteGroupConfirm => 'Delete this group?';

  @override
  String get deleteGroupHint =>
      'This permanently deletes the group, members, and all movements. This cannot be undone.';

  @override
  String get groupDeleted => 'Group deleted';

  @override
  String get groupRenamed => 'Group renamed';

  @override
  String get creator => 'Creator';

  @override
  String get changeGroupPhoto => 'Change group photo';

  @override
  String get groupPhotoUpdated => 'Group photo updated';

  @override
  String get leaveGroup => 'Leave group';

  @override
  String get leaveGroupHint =>
      'You will leave this group, but your movements stay in the history.';

  @override
  String get leftGroup => 'You left the group';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get incorrectCredentials => 'Email or password is incorrect.';

  @override
  String get firebaseNotConfigured =>
      'Firebase is not configured yet. Add your google-services.json.';

  @override
  String get signInFailed => 'Sign-in failed. Please try again.';

  @override
  String get signUpFailed => 'Sign-up failed. Please try again.';

  @override
  String get googleSignInCanceled => 'Google sign-in was canceled.';

  @override
  String get googleSignInConfigError =>
      'Google sign-in is temporarily unavailable. Please create an account with email, or try Google again later.';

  @override
  String get googleSignInFailed => 'Google sign-in failed. Please try again.';

  @override
  String get forceUpdateTitle => 'Update required';

  @override
  String get forceUpdateBody =>
      'A new version of EnCaisse is required to continue. Please update from Google Play.';

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String get updateAvailableBody =>
      'A newer version of EnCaisse is available with important improvements.';

  @override
  String get updateNow => 'Update now';

  @override
  String get updateLater => 'Later';

  @override
  String get emailAlreadyInUse => 'An account already exists for this email.';

  @override
  String get weakPassword => 'Choose a stronger password.';

  @override
  String get member => 'Member';

  @override
  String get aMember => 'A member';

  @override
  String get someoneJoined => 'Someone joined';

  @override
  String memberJoinedBody(String name, String group) {
    return '$name joined $group';
  }

  @override
  String get joinAGroup => 'Join a group';

  @override
  String errorWithDetails(String error) {
    return 'Error: $error';
  }

  @override
  String get enterValidAmountGtZero =>
      'Enter a valid amount greater than zero.';

  @override
  String couldNotLoadAudit(String error) {
    return 'Could not load audit: $error';
  }

  @override
  String get newMovementNotify => 'New movement';

  @override
  String get depositNotifyTitle => 'New deposit';

  @override
  String get expenseNotifyTitle => 'New expense';

  @override
  String get movementUpdatedNotify => 'Movement updated';

  @override
  String get movementDeletedNotify => 'Movement deleted';

  @override
  String get movementRestoredNotify => 'Movement restored';

  @override
  String addedDeposit(String name, String title) {
    return '$name added a deposit: $title';
  }

  @override
  String addedExpense(String name, String title) {
    return '$name added an expense: $title';
  }

  @override
  String addedDepositAmount(String name, String amount, String title) {
    return '$name added a deposit of $amount: $title';
  }

  @override
  String addedExpenseAmount(String name, String amount, String title) {
    return '$name added an expense of $amount: $title';
  }

  @override
  String updatedMovementBy(String name, String title) {
    return '$name updated: $title';
  }

  @override
  String deletedMovementBy(String name, String title) {
    return '$name deleted: $title';
  }

  @override
  String restoredMovementBy(String name, String title) {
    return '$name restored: $title';
  }

  @override
  String get deletedMarker => 'deleted';

  @override
  String get insufficientBalance =>
      'Not enough balance. This would make the caisse negative.';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Time';
}
