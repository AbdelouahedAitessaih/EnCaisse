import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'EnCaisse'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'EnCaisse, ensemble.'**
  String get tagline;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your EnCaisse account.'**
  String get signInSubtitle;

  /// No description provided for @joinEncaisse.
  ///
  /// In en, this message translates to:
  /// **'Join EnCaisse'**
  String get joinEncaisse;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track shared cash with full transparency.'**
  String get signUpSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @needAccount.
  ///
  /// In en, this message translates to:
  /// **'Need an account? Sign up'**
  String get needAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccount;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @validEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validEmail;

  /// No description provided for @passwordMin.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMin;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterName;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @helloName.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String helloName(String name);

  /// No description provided for @noGroupsYet.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get noGroupsYet;

  /// No description provided for @noGroupsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a caisse or join one with an invite code.'**
  String get noGroupsSubtitle;

  /// No description provided for @createAGroup.
  ///
  /// In en, this message translates to:
  /// **'Create a group'**
  String get createAGroup;

  /// No description provided for @joinWithCode.
  ///
  /// In en, this message translates to:
  /// **'Join with invite code'**
  String get joinWithCode;

  /// No description provided for @joinWithInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Join with invite code'**
  String get joinWithInviteCode;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeMode;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePortuguese;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get languageHindi;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussian;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJapanese;

  /// No description provided for @nameYourCaisse.
  ///
  /// In en, this message translates to:
  /// **'Name your caisse'**
  String get nameYourCaisse;

  /// No description provided for @inviteCodeHint.
  ///
  /// In en, this message translates to:
  /// **'You will get a 6-character invite code to share.'**
  String get inviteCodeHint;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Weekend trip, Flatmates…'**
  String get groupNameHint;

  /// No description provided for @enterGroupName.
  ///
  /// In en, this message translates to:
  /// **'Enter a group name'**
  String get enterGroupName;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @startingAmountOptional.
  ///
  /// In en, this message translates to:
  /// **'Starting amount (optional)'**
  String get startingAmountOptional;

  /// No description provided for @startingAmountHelper.
  ///
  /// In en, this message translates to:
  /// **'Only you (the creator) can edit this amount later.'**
  String get startingAmountHelper;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createGroup;

  /// No description provided for @enterInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Enter invite code'**
  String get enterInviteCode;

  /// No description provided for @askForCode.
  ///
  /// In en, this message translates to:
  /// **'Ask a member for the {length}-character code.'**
  String askForCode(int length);

  /// No description provided for @inviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCode;

  /// No description provided for @joinGroup.
  ///
  /// In en, this message translates to:
  /// **'Join group'**
  String get joinGroup;

  /// No description provided for @enterCodeLength.
  ///
  /// In en, this message translates to:
  /// **'Enter a {length}-character code'**
  String enterCodeLength(int length);

  /// No description provided for @noGroupForCode.
  ///
  /// In en, this message translates to:
  /// **'No group found for this invite code.'**
  String get noGroupForCode;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @inLabel.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get inLabel;

  /// No description provided for @outLabel.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get outLabel;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get byCategory;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get filterUser;

  /// No description provided for @filterDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get filterDate;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @noMatchingMovements.
  ///
  /// In en, this message translates to:
  /// **'No movements match these filters.'**
  String get noMatchingMovements;

  /// No description provided for @inviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get inviteFriends;

  /// No description provided for @shareCodeSoFriends.
  ///
  /// In en, this message translates to:
  /// **'Share this code so friends can join.'**
  String get shareCodeSoFriends;

  /// No description provided for @shareThisCode.
  ///
  /// In en, this message translates to:
  /// **'Share this code so others can join.'**
  String get shareThisCode;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get copyCode;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @inviteCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite code {code} copied'**
  String inviteCodeCopied(String code);

  /// No description provided for @shareInviteText.
  ///
  /// In en, this message translates to:
  /// **'Join my EnCaisse group \"{name}\" with code {code}. EnCaisse, ensemble.'**
  String shareInviteText(String name, String code);

  /// No description provided for @joinOnEncaisse.
  ///
  /// In en, this message translates to:
  /// **'Join {name} on EnCaisse'**
  String joinOnEncaisse(String name);

  /// No description provided for @notificationsMuted.
  ///
  /// In en, this message translates to:
  /// **'Notifications muted for this group'**
  String get notificationsMuted;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled for this group'**
  String get notificationsEnabled;

  /// No description provided for @unmuteNotifications.
  ///
  /// In en, this message translates to:
  /// **'Unmute notifications'**
  String get unmuteNotifications;

  /// No description provided for @muteNotifications.
  ///
  /// In en, this message translates to:
  /// **'Mute notifications'**
  String get muteNotifications;

  /// No description provided for @noMovementsYet.
  ///
  /// In en, this message translates to:
  /// **'No movements yet'**
  String get noMovementsYet;

  /// No description provided for @noMovementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add the first deposit or expense for this caisse.'**
  String get noMovementsSubtitle;

  /// No description provided for @addMovement.
  ///
  /// In en, this message translates to:
  /// **'Add movement'**
  String get addMovement;

  /// No description provided for @editMovement.
  ///
  /// In en, this message translates to:
  /// **'Edit movement'**
  String get editMovement;

  /// No description provided for @movement.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get movement;

  /// No description provided for @startingBalance.
  ///
  /// In en, this message translates to:
  /// **'Starting balance'**
  String get startingBalance;

  /// No description provided for @editStartingBalance.
  ///
  /// In en, this message translates to:
  /// **'Edit starting balance'**
  String get editStartingBalance;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @startingAmount.
  ///
  /// In en, this message translates to:
  /// **'Starting amount'**
  String get startingAmount;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Groceries, rent share…'**
  String get titleHint;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @addReceipt.
  ///
  /// In en, this message translates to:
  /// **'Add receipt photo (optional)'**
  String get addReceipt;

  /// No description provided for @receiptSelected.
  ///
  /// In en, this message translates to:
  /// **'Receipt selected'**
  String get receiptSelected;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get enterTitle;

  /// No description provided for @onlyCreatorEditStarting.
  ///
  /// In en, this message translates to:
  /// **'Only you (the creator) can change this amount.'**
  String get onlyCreatorEditStarting;

  /// No description provided for @onlyCreatorCanEditStarting.
  ///
  /// In en, this message translates to:
  /// **'Only the person who created this caisse can edit the starting balance.'**
  String get onlyCreatorCanEditStarting;

  /// No description provided for @onlyYouEditStarting.
  ///
  /// In en, this message translates to:
  /// **'Only you can edit this starting amount.'**
  String get onlyYouEditStarting;

  /// No description provided for @onlyCreatorEditAmount.
  ///
  /// In en, this message translates to:
  /// **'Only the caisse creator can edit this amount.'**
  String get onlyCreatorEditAmount;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get createdBy;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @attached.
  ///
  /// In en, this message translates to:
  /// **'Attached'**
  String get attached;

  /// No description provided for @auditTrail.
  ///
  /// In en, this message translates to:
  /// **'Audit trail'**
  String get auditTrail;

  /// No description provided for @auditTrailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Append-only history. Nobody can edit or delete these entries.'**
  String get auditTrailSubtitle;

  /// No description provided for @noAuditYet.
  ///
  /// In en, this message translates to:
  /// **'No audit entries yet.'**
  String get noAuditYet;

  /// No description provided for @deleteMovement.
  ///
  /// In en, this message translates to:
  /// **'Delete movement?'**
  String get deleteMovement;

  /// No description provided for @deleteStartingBalance.
  ///
  /// In en, this message translates to:
  /// **'Delete starting balance?'**
  String get deleteStartingBalance;

  /// No description provided for @softDeleteHint.
  ///
  /// In en, this message translates to:
  /// **'This soft-deletes the movement for 24 hours. You can undo from the snackbar or this screen.'**
  String get softDeleteHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @movementDeletedUndo.
  ///
  /// In en, this message translates to:
  /// **'Movement deleted — Undo'**
  String get movementDeletedUndo;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @movementRestored.
  ///
  /// In en, this message translates to:
  /// **'Movement restored'**
  String get movementRestored;

  /// No description provided for @softDeletedCanUndo.
  ///
  /// In en, this message translates to:
  /// **'Soft-deleted — you can still undo within 24 hours.'**
  String get softDeletedCanUndo;

  /// No description provided for @softDeletedExpired.
  ///
  /// In en, this message translates to:
  /// **'Soft-deleted — undo window expired.'**
  String get softDeletedExpired;

  /// No description provided for @undoDelete.
  ///
  /// In en, this message translates to:
  /// **'Undo delete'**
  String get undoDelete;

  /// No description provided for @actionCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get actionCreate;

  /// No description provided for @actionUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get actionUpdate;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @groupNotFound.
  ///
  /// In en, this message translates to:
  /// **'Group not found'**
  String get groupNotFound;

  /// No description provided for @movementNotFound.
  ///
  /// In en, this message translates to:
  /// **'Movement not found'**
  String get movementNotFound;

  /// No description provided for @couldNotLoadGroups.
  ///
  /// In en, this message translates to:
  /// **'Could not load groups. Check Firebase setup.'**
  String get couldNotLoadGroups;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'One shared caisse'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Everyone in the group can add deposits and expenses. No admin hierarchy.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Full audit trail'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Every change is logged. Trust comes from transparency, not permissions.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Invite with a code'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Create a group or join with a 6-character invite code.'**
  String get onboardingBody3;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shared group cash, transparent for everyone.'**
  String get welcomeSubtitle;

  /// No description provided for @validStartingAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid starting amount (or leave empty).'**
  String get validStartingAmount;

  /// No description provided for @manageGroup.
  ///
  /// In en, this message translates to:
  /// **'Manage group'**
  String get manageGroup;

  /// No description provided for @renameGroup.
  ///
  /// In en, this message translates to:
  /// **'Rename group'**
  String get renameGroup;

  /// No description provided for @renameGroupHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a new name for this caisse.'**
  String get renameGroupHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @manageMembers.
  ///
  /// In en, this message translates to:
  /// **'Manage members'**
  String get manageMembers;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeMember;

  /// No description provided for @removeMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from this group?'**
  String removeMemberConfirm(String name);

  /// No description provided for @memberRemoved.
  ///
  /// In en, this message translates to:
  /// **'Member removed'**
  String get memberRemoved;

  /// No description provided for @cannotRemoveCreator.
  ///
  /// In en, this message translates to:
  /// **'You cannot remove the group creator.'**
  String get cannotRemoveCreator;

  /// No description provided for @deleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete group'**
  String get deleteGroup;

  /// No description provided for @deleteGroupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this group?'**
  String get deleteGroupConfirm;

  /// No description provided for @deleteGroupHint.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes the group, members, and all movements. This cannot be undone.'**
  String get deleteGroupHint;

  /// No description provided for @groupDeleted.
  ///
  /// In en, this message translates to:
  /// **'Group deleted'**
  String get groupDeleted;

  /// No description provided for @groupRenamed.
  ///
  /// In en, this message translates to:
  /// **'Group renamed'**
  String get groupRenamed;

  /// No description provided for @creator.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get creator;

  /// No description provided for @changeGroupPhoto.
  ///
  /// In en, this message translates to:
  /// **'Change group photo'**
  String get changeGroupPhoto;

  /// No description provided for @groupPhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Group photo updated'**
  String get groupPhotoUpdated;

  /// No description provided for @leaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get leaveGroup;

  /// No description provided for @leaveGroupHint.
  ///
  /// In en, this message translates to:
  /// **'You will leave this group, but your movements stay in the history.'**
  String get leaveGroupHint;

  /// No description provided for @leftGroup.
  ///
  /// In en, this message translates to:
  /// **'You left the group'**
  String get leftGroup;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @incorrectCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get incorrectCredentials;

  /// No description provided for @firebaseNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Firebase is not configured yet. Add your google-services.json.'**
  String get firebaseNotConfigured;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again.'**
  String get signInFailed;

  /// No description provided for @signUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-up failed. Please try again.'**
  String get signUpFailed;

  /// No description provided for @googleSignInCanceled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was canceled.'**
  String get googleSignInCanceled;

  /// No description provided for @googleSignInConfigError.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is not configured. Add this app\'s SHA-1 in Firebase Console (Project settings → Your apps), enable Google sign-in, then download a new google-services.json.'**
  String get googleSignInConfigError;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get googleSignInFailed;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for this email.'**
  String get emailAlreadyInUse;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password.'**
  String get weakPassword;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @aMember.
  ///
  /// In en, this message translates to:
  /// **'A member'**
  String get aMember;

  /// No description provided for @someoneJoined.
  ///
  /// In en, this message translates to:
  /// **'Someone joined'**
  String get someoneJoined;

  /// No description provided for @memberJoinedBody.
  ///
  /// In en, this message translates to:
  /// **'{name} joined {group}'**
  String memberJoinedBody(String name, String group);

  /// No description provided for @joinAGroup.
  ///
  /// In en, this message translates to:
  /// **'Join a group'**
  String get joinAGroup;

  /// No description provided for @errorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithDetails(String error);

  /// No description provided for @enterValidAmountGtZero.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount greater than zero.'**
  String get enterValidAmountGtZero;

  /// No description provided for @couldNotLoadAudit.
  ///
  /// In en, this message translates to:
  /// **'Could not load audit: {error}'**
  String couldNotLoadAudit(String error);

  /// No description provided for @newMovementNotify.
  ///
  /// In en, this message translates to:
  /// **'New movement'**
  String get newMovementNotify;

  /// No description provided for @depositNotifyTitle.
  ///
  /// In en, this message translates to:
  /// **'New deposit'**
  String get depositNotifyTitle;

  /// No description provided for @expenseNotifyTitle.
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get expenseNotifyTitle;

  /// No description provided for @movementUpdatedNotify.
  ///
  /// In en, this message translates to:
  /// **'Movement updated'**
  String get movementUpdatedNotify;

  /// No description provided for @movementDeletedNotify.
  ///
  /// In en, this message translates to:
  /// **'Movement deleted'**
  String get movementDeletedNotify;

  /// No description provided for @movementRestoredNotify.
  ///
  /// In en, this message translates to:
  /// **'Movement restored'**
  String get movementRestoredNotify;

  /// No description provided for @addedDeposit.
  ///
  /// In en, this message translates to:
  /// **'{name} added a deposit: {title}'**
  String addedDeposit(String name, String title);

  /// No description provided for @addedExpense.
  ///
  /// In en, this message translates to:
  /// **'{name} added an expense: {title}'**
  String addedExpense(String name, String title);

  /// No description provided for @addedDepositAmount.
  ///
  /// In en, this message translates to:
  /// **'{name} added a deposit of {amount}: {title}'**
  String addedDepositAmount(String name, String amount, String title);

  /// No description provided for @addedExpenseAmount.
  ///
  /// In en, this message translates to:
  /// **'{name} added an expense of {amount}: {title}'**
  String addedExpenseAmount(String name, String amount, String title);

  /// No description provided for @updatedMovementBy.
  ///
  /// In en, this message translates to:
  /// **'{name} updated: {title}'**
  String updatedMovementBy(String name, String title);

  /// No description provided for @deletedMovementBy.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted: {title}'**
  String deletedMovementBy(String name, String title);

  /// No description provided for @restoredMovementBy.
  ///
  /// In en, this message translates to:
  /// **'{name} restored: {title}'**
  String restoredMovementBy(String name, String title);

  /// No description provided for @deletedMarker.
  ///
  /// In en, this message translates to:
  /// **'deleted'**
  String get deletedMarker;

  /// No description provided for @insufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Not enough balance. This would make the caisse negative.'**
  String get insufficientBalance;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'es',
    'fr',
    'hi',
    'ja',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
