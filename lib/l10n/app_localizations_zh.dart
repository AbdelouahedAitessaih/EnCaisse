// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'EnCaisse';

  @override
  String get tagline => 'EnCaisse, ensemble.';

  @override
  String get getStarted => '开始使用';

  @override
  String get alreadyHaveAccount => '我已有账户';

  @override
  String get skip => '跳过';

  @override
  String get next => '下一步';

  @override
  String get createAccount => '创建账户';

  @override
  String get signIn => '登录';

  @override
  String get signOut => '退出登录';

  @override
  String get welcomeBack => '欢迎回来';

  @override
  String get signInSubtitle => '登录您的 EnCaisse 账户。';

  @override
  String get joinEncaisse => '加入 EnCaisse';

  @override
  String get signUpSubtitle => '透明地追踪共享资金。';

  @override
  String get email => '电子邮箱';

  @override
  String get password => '密码';

  @override
  String get displayName => '显示名称';

  @override
  String get or => '或';

  @override
  String get continueWithGoogle => '使用 Google 继续';

  @override
  String get needAccount => '需要账户？注册';

  @override
  String get haveAccount => '已有账户？登录';

  @override
  String get enterEmail => '请输入电子邮箱';

  @override
  String get validEmail => '请输入有效的电子邮箱';

  @override
  String get passwordMin => '密码至少需要 6 个字符';

  @override
  String get enterName => '请输入您的姓名';

  @override
  String get hello => '你好';

  @override
  String helloName(String name) {
    return '你好，$name';
  }

  @override
  String get noGroupsYet => '暂无群组';

  @override
  String get noGroupsSubtitle => '创建一个资金池，或使用邀请码加入。';

  @override
  String get createAGroup => '创建群组';

  @override
  String get joinWithCode => '使用邀请码加入';

  @override
  String get joinWithInviteCode => '使用邀请码加入';

  @override
  String get settings => '设置';

  @override
  String get appearance => '外观';

  @override
  String get language => '语言';

  @override
  String get themeMode => '主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageFrench => '法语';

  @override
  String get languageArabic => '阿拉伯语';

  @override
  String get languageSpanish => '西班牙语';

  @override
  String get languagePortuguese => '葡萄牙语';

  @override
  String get languageChinese => '中文';

  @override
  String get languageHindi => '印地语';

  @override
  String get languageRussian => '俄语';

  @override
  String get languageJapanese => '日语';

  @override
  String get nameYourCaisse => '为资金池命名';

  @override
  String get inviteCodeHint => '您将获得一个 6 位邀请码以便分享。';

  @override
  String get groupName => '群组名称';

  @override
  String get groupNameHint => '周末旅行、合租室友…';

  @override
  String get enterGroupName => '请输入群组名称';

  @override
  String get currency => '货币';

  @override
  String get startingAmountOptional => '起始金额（可选）';

  @override
  String get startingAmountHelper => '之后只有您（创建者）可以修改此金额。';

  @override
  String get createGroup => '创建群组';

  @override
  String get enterInviteCode => '输入邀请码';

  @override
  String askForCode(int length) {
    return '向成员索取 $length 位邀请码。';
  }

  @override
  String get inviteCode => '邀请码';

  @override
  String get joinGroup => '加入群组';

  @override
  String enterCodeLength(int length) {
    return '请输入 $length 位邀请码';
  }

  @override
  String get noGroupForCode => '未找到该邀请码对应的群组。';

  @override
  String get balance => '余额';

  @override
  String get inLabel => '收入';

  @override
  String get outLabel => '支出';

  @override
  String get members => '成员';

  @override
  String get byCategory => '按类别';

  @override
  String get filterAll => '全部';

  @override
  String get filterUser => '用户';

  @override
  String get filterDate => '日期';

  @override
  String get clearFilters => '清除筛选';

  @override
  String get noMatchingMovements => '没有符合这些筛选条件的流水。';

  @override
  String get inviteFriends => '邀请好友';

  @override
  String get shareCodeSoFriends => '分享此邀请码，让好友加入。';

  @override
  String get shareThisCode => '分享此邀请码，让他人加入。';

  @override
  String get copyCode => '复制邀请码';

  @override
  String get share => '分享';

  @override
  String inviteCodeCopied(String code) {
    return '邀请码 $code 已复制';
  }

  @override
  String shareInviteText(String name, String code) {
    return '用邀请码 $code 加入我的 EnCaisse 群组「$name」。EnCaisse, ensemble.';
  }

  @override
  String joinOnEncaisse(String name) {
    return '在 EnCaisse 加入 $name';
  }

  @override
  String get notificationsMuted => '已静音此群组通知';

  @override
  String get notificationsEnabled => '已启用此群组通知';

  @override
  String get unmuteNotifications => '取消静音通知';

  @override
  String get muteNotifications => '静音通知';

  @override
  String get noMovementsYet => '暂无流水';

  @override
  String get noMovementsSubtitle => '为本资金池添加第一笔存入或支出。';

  @override
  String get addMovement => '添加流水';

  @override
  String get editMovement => '编辑流水';

  @override
  String get movement => '流水';

  @override
  String get startingBalance => '起始余额';

  @override
  String get editStartingBalance => '编辑起始余额';

  @override
  String get type => '类型';

  @override
  String get deposit => '存入';

  @override
  String get expense => '支出';

  @override
  String get amount => '金额';

  @override
  String get startingAmount => '起始金额';

  @override
  String get title => '标题';

  @override
  String get titleHint => '杂货、房租分摊…';

  @override
  String get category => '类别';

  @override
  String get addReceipt => '添加收据照片（可选）';

  @override
  String get receiptSelected => '已选择收据';

  @override
  String get saveChanges => '保存更改';

  @override
  String get enterValidAmount => '请输入有效金额';

  @override
  String get enterTitle => '请输入标题';

  @override
  String get onlyCreatorEditStarting => '只有您（创建者）可以更改此金额。';

  @override
  String get onlyCreatorCanEditStarting => '只有创建此资金池的人可以编辑起始余额。';

  @override
  String get onlyYouEditStarting => '只有您可以编辑此起始金额。';

  @override
  String get onlyCreatorEditAmount => '只有资金池创建者可以编辑此金额。';

  @override
  String get createdBy => '创建者';

  @override
  String get created => '创建时间';

  @override
  String get receipt => '收据';

  @override
  String get attached => '已附加';

  @override
  String get auditTrail => '审计记录';

  @override
  String get auditTrailSubtitle => '仅追加历史记录。任何人都无法编辑或删除这些条目。';

  @override
  String get noAuditYet => '暂无审计记录。';

  @override
  String get deleteMovement => '删除流水？';

  @override
  String get deleteStartingBalance => '删除起始余额？';

  @override
  String get softDeleteHint => '这将软删除流水 24 小时。您可以从提示条或此页面撤销。';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get movementDeletedUndo => '流水已删除 — 撤销';

  @override
  String get undo => '撤销';

  @override
  String get movementRestored => '流水已恢复';

  @override
  String get softDeletedCanUndo => '已软删除 — 您仍可在 24 小时内撤销。';

  @override
  String get softDeletedExpired => '已软删除 — 撤销期限已过。';

  @override
  String get undoDelete => '撤销删除';

  @override
  String get actionCreate => '创建';

  @override
  String get actionUpdate => '更新';

  @override
  String get actionDelete => '删除';

  @override
  String get groupNotFound => '未找到群组';

  @override
  String get movementNotFound => '未找到流水';

  @override
  String get couldNotLoadGroups => '无法加载群组。请检查 Firebase 配置。';

  @override
  String get onboardingTitle1 => '一个共享资金池';

  @override
  String get onboardingBody1 => '群组中每个人都可以添加存入和支出。没有管理员层级。';

  @override
  String get onboardingTitle2 => '完整审计记录';

  @override
  String get onboardingBody2 => '每次更改都会被记录。信任来自透明，而非权限。';

  @override
  String get onboardingTitle3 => '用邀请码邀请';

  @override
  String get onboardingBody3 => '创建群组，或使用 6 位邀请码加入。';

  @override
  String get welcomeSubtitle => '共享群组资金，对所有人透明。';

  @override
  String get validStartingAmount => '请输入有效的起始金额（或留空）。';

  @override
  String get manageGroup => '管理群组';

  @override
  String get renameGroup => '重命名群组';

  @override
  String get renameGroupHint => '为此资金池输入新名称。';

  @override
  String get save => '保存';

  @override
  String get manageMembers => '管理成员';

  @override
  String get removeMember => '移除';

  @override
  String removeMemberConfirm(String name) {
    return '将 $name 移出此群组？';
  }

  @override
  String get memberRemoved => '已移除成员';

  @override
  String get cannotRemoveCreator => '不能移除群组创建者。';

  @override
  String get deleteGroup => '删除群组';

  @override
  String get deleteGroupConfirm => '删除此群组？';

  @override
  String get deleteGroupHint => '将永久删除群组、成员及所有流水，无法撤销。';

  @override
  String get groupDeleted => '群组已删除';

  @override
  String get groupRenamed => '群组已重命名';

  @override
  String get creator => '创建者';

  @override
  String get changeGroupPhoto => '更改群组照片';

  @override
  String get groupPhotoUpdated => '群组照片已更新';

  @override
  String get leaveGroup => '退出群组';

  @override
  String get leaveGroupHint => '您将退出此群组，但您的流水仍保留在历史记录中。';

  @override
  String get leftGroup => '已退出群组';

  @override
  String get profile => '个人资料';

  @override
  String get editProfile => '编辑资料';

  @override
  String get changePhoto => '更换照片';

  @override
  String get profileUpdated => '资料已更新';

  @override
  String get incorrectCredentials => '电子邮箱或密码不正确。';

  @override
  String get firebaseNotConfigured => 'Firebase 尚未配置。请添加 google-services.json。';

  @override
  String get signInFailed => '登录失败，请重试。';

  @override
  String get signUpFailed => '注册失败，请重试。';

  @override
  String get googleSignInCanceled => '已取消 Google 登录。';

  @override
  String get googleSignInConfigError =>
      '尚未配置 Google 登录。请在 Firebase 中添加应用的 SHA-1，然后下载新的 google-services.json。';

  @override
  String get googleSignInFailed => 'Google 登录失败，请重试。';

  @override
  String get emailAlreadyInUse => '该电子邮箱已有账户。';

  @override
  String get weakPassword => '请选择更强的密码。';

  @override
  String get member => '成员';

  @override
  String get aMember => '一名成员';

  @override
  String get someoneJoined => '有人加入';

  @override
  String memberJoinedBody(String name, String group) {
    return '$name 加入了 $group';
  }

  @override
  String get joinAGroup => '加入群组';

  @override
  String errorWithDetails(String error) {
    return '错误：$error';
  }

  @override
  String get enterValidAmountGtZero => '请输入大于零的有效金额。';

  @override
  String couldNotLoadAudit(String error) {
    return '无法加载审计记录：$error';
  }

  @override
  String get newMovementNotify => '新流水';

  @override
  String get depositNotifyTitle => '新存入';

  @override
  String get expenseNotifyTitle => '新支出';

  @override
  String get movementUpdatedNotify => '流水已更新';

  @override
  String get movementDeletedNotify => '流水已删除';

  @override
  String get movementRestoredNotify => '流水已恢复';

  @override
  String addedDeposit(String name, String title) {
    return '$name 添加了存入：$title';
  }

  @override
  String addedExpense(String name, String title) {
    return '$name 添加了支出：$title';
  }

  @override
  String addedDepositAmount(String name, String amount, String title) {
    return '$name 添加了存入 $amount：$title';
  }

  @override
  String addedExpenseAmount(String name, String amount, String title) {
    return '$name 添加了支出 $amount：$title';
  }

  @override
  String updatedMovementBy(String name, String title) {
    return '$name 更新了：$title';
  }

  @override
  String deletedMovementBy(String name, String title) {
    return '$name 删除了：$title';
  }

  @override
  String restoredMovementBy(String name, String title) {
    return '$name 恢复了：$title';
  }

  @override
  String get deletedMarker => '已删除';

  @override
  String get insufficientBalance => '余额不足。这会使钱箱变为负数。';

  @override
  String get dateLabel => '日期';

  @override
  String get timeLabel => '时间';
}
