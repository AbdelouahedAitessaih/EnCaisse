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
  String get rememberMe => '记住我';

  @override
  String get showPassword => '显示密码';

  @override
  String get hidePassword => '隐藏密码';

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
  String get noGroupsSubtitle => '可先建个人账本，或创建群组，或用邀请码加入。';

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
  String get languageSystem => '手机语言';

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
  String get selectCurrency => '请选择货币';

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
  String get filters => '筛选';

  @override
  String get applyFilters => '应用';

  @override
  String get filterUser => '用户';

  @override
  String get filterDate => '日期';

  @override
  String get filterAnyTime => '所有日期';

  @override
  String get filterThisMonth => '本月';

  @override
  String get filterLast30Days => '最近30天';

  @override
  String get filterChooseDates => '选择日期';

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
  String get movementDeletedUndo => '流水已删除';

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
  String get onboardingBody1 => '可独自或与朋友记账。共享群组中所有人都能添加存入与支出 — 无管理员层级。';

  @override
  String get onboardingTitle2 => '完整审计记录';

  @override
  String get onboardingBody2 => '每次更改都会被记录。信任来自透明，而非权限。';

  @override
  String get onboardingTitle3 => '用邀请码邀请';

  @override
  String get onboardingBody3 => '创建群组，或使用 6 位邀请码加入。';

  @override
  String get welcomeSubtitle => '独自或与他人一起管理资金。';

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
  String get forceUpdateTitle => '必须更新';

  @override
  String get forceUpdateBody => '需要更新 EnCaisse 才能继续。请从商店更新。';

  @override
  String get updateAvailableTitle => '有可用更新';

  @override
  String get updateAvailableBody => 'EnCaisse 有新版本，包含重要改进。';

  @override
  String get updateNow => '立即更新';

  @override
  String get updateLater => '稍后';

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

  @override
  String get verifyEmailTitle => '验证您的邮箱';

  @override
  String verifyEmailBody(String email) {
    return '我们已向 $email 发送验证链接。打开后点击继续。';
  }

  @override
  String get resendVerification => '重新发送邮件';

  @override
  String get verificationEmailSent => '验证邮件已发送';

  @override
  String get emailVerifiedContinue => '继续';

  @override
  String get emailNotVerifiedYet => '邮箱尚未验证。请检查收件箱。';

  @override
  String get checkVerification => '我已验证';

  @override
  String get settleTitle => '谁欠谁';

  @override
  String get settleSubtitle => '根据存入与支出平均分摊。';

  @override
  String get settleSettled => '大家已结清';

  @override
  String settleOwes(String from, String to) {
    return '$from 欠 $to';
  }

  @override
  String get memberNet => '净值';

  @override
  String get chartsTitle => '图表';

  @override
  String get categoryBreakdown => '按类别的支出';

  @override
  String get exportCsv => '导出 CSV';

  @override
  String get exportPdf => '导出 PDF';

  @override
  String get exportShared => '导出已准备好分享';

  @override
  String get exportFailed => '无法导出';

  @override
  String get notifications => '通知';

  @override
  String get noNotifications => '暂无通知';

  @override
  String get noNotificationsSubtitle => '群组动态将显示在这里。';

  @override
  String get markAllRead => '全部标为已读';

  @override
  String get offlineBanner => '您处于离线状态。有缓存时将显示缓存数据。';

  @override
  String get offlineRetry => '重试';

  @override
  String get forceUpdateBodyIos => '需要更新 EnCaisse。请从 App Store 更新。';

  @override
  String get openStore => '打开商店';

  @override
  String get insightsTitle => '分析';

  @override
  String get insightsOpen => '分析';

  @override
  String get yourCaisses => '你的账本';

  @override
  String get homeOverview => '将所有资金集中管理。';

  @override
  String get personalCaisse => '个人账本';

  @override
  String get personalCaisseSubtitle => '专属个人账本，轻松记录收支。';

  @override
  String get personalCaisseName => '我的账本';

  @override
  String get personalBadge => '个人';

  @override
  String get manageCaisse => '管理个人账本';

  @override
  String get renameCaisse => '重命名账本';

  @override
  String get changeCaissePhoto => '更改账本照片';

  @override
  String get caissePhotoUpdated => '账本照片已更新';

  @override
  String get caisseRenamed => '账本已重命名';

  @override
  String get deleteCaisse => '删除账本';

  @override
  String get deleteCaisseConfirm => '确定删除此账本吗？';

  @override
  String get deleteCaisseHint => '这将永久删除账本及其所有收支记录，且无法撤销。';

  @override
  String get caisseDeleted => '账本已删除';

  @override
  String get howToUse => '如何使用 EnCaisse';

  @override
  String get tourNext => '下一步';

  @override
  String get tourBack => '返回';

  @override
  String get tourSkip => '跳过';

  @override
  String get tourDone => '知道了';

  @override
  String get tourHome1Title => '首页';

  @override
  String get tourHome1Body => '此列表显示您的所有账本。点开即可查看存入、支出和实时余额。';

  @override
  String get tourHome2Title => '独自记账';

  @override
  String get tourHome2Body => '需要私人账本？点 + 选择个人账本。无需邀请码，只有您自己。';

  @override
  String get tourHome3Title => '与他人共享';

  @override
  String get tourHome3Body => '创建群组或用 6 位邀请码加入。所有人看到同一透明记录。';

  @override
  String get tourGroup1Title => '实时余额';

  @override
  String get tourGroup1Body => '绿色卡片始终由流水计算：存入减支出。不是可被篡改的存档总额。';

  @override
  String get tourGroup2Title => '添加流水';

  @override
  String get tourGroup2Body => '点 + 添加存入或支出。可附收据；每次更改都会保留在审计记录中。';

  @override
  String get tourGroup3Title => '邀请与分析';

  @override
  String get tourGroup3Body => '分享邀请码。打开结算与图表查看谁欠谁以及分类支出。';

  @override
  String get tourGroup3BodyPersonal => '打开分析，按类别查看支出。此账本仅供您使用。';

  @override
  String get tapPhotoToChange => '点按照片以更换';

  @override
  String get tapPhotoToView => '点按查看';

  @override
  String get creatingPersonal => '正在打开您的个人账本…';

  @override
  String get categoryFood => '餐饮';

  @override
  String get categoryTransport => '交通';

  @override
  String get categoryRent => '房租';

  @override
  String get categoryUtilities => '水电';

  @override
  String get categoryEntertainment => '娱乐';

  @override
  String get categoryShopping => '购物';

  @override
  String get categoryHealth => '医疗';

  @override
  String get categoryTravel => '旅行';

  @override
  String get categorySalary => '工资';

  @override
  String get categoryGift => '礼物';

  @override
  String get categoryOther => '其他';

  @override
  String get retry => '重试';

  @override
  String get caisseDeleting => '正在删除账本…';

  @override
  String get groupDeleting => '正在删除群组…';

  @override
  String get balancePerCaisse => '不同币种的余额永远不会相加。';

  @override
  String balanceAcrossCaisses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '总计 $count 个账本',
      one: '总计 $count 个账本',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountTitle => '删除账号';

  @override
  String get deleteAccountSubtitle => '删除您的 EnCaisse 账号及所有个人数据';

  @override
  String get deleteAccountConfirm => '删除您的账号？';

  @override
  String get deleteAccountWarning => '此操作无法撤销。出于安全考虑，请在删除前重新登录。';

  @override
  String get security => '安全';

  @override
  String get appLock => '应用锁';

  @override
  String get appLockHint => '打开 EnCaisse 时要求指纹、面容或设备密码';

  @override
  String get appLockUnavailable => '此设备未设置指纹、面容或屏幕锁';

  @override
  String get appLockReason => '解锁 EnCaisse';

  @override
  String get appLockTitle => 'EnCaisse 已锁定';

  @override
  String get appLockUnlock => '解锁';

  @override
  String convertedAmount(String amount) {
    return '= 账本货币 $amount';
  }

  @override
  String get enterValidRate => '请输入有效的汇率';

  @override
  String exchangeRateLabel(String from, String to) {
    return '汇率（1 $from = ? $to）';
  }

  @override
  String get exchangeRateUnavailable => '无法获取汇率，请手动输入。';

  @override
  String get formerMember => '前成员';

  @override
  String homeWidgetMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '另有 $count 个账本',
    );
    return '$_temp0';
  }

  @override
  String homeWidgetUpdated(String time) {
    return '更新于 $time';
  }

  @override
  String get markReceived => '标记为已收到';

  @override
  String markReceivedConfirm(String name, String amount) {
    return '确认已收到 $name 的 $amount？';
  }

  @override
  String paidInCurrency(String amount, String rate) {
    return '原始金额 $amount · 汇率 $rate';
  }

  @override
  String paymentRequestText(String name, String amount, String group) {
    return '你好 $name，你在 EnCaisse 账本“$group”中欠我 $amount。谢谢！';
  }

  @override
  String get recurringBadge => '定期';

  @override
  String get recurringCreatorLeft => '已停止：创建者已离开账本';

  @override
  String get recurringEmpty => '添加收支时选择“重复”，即可自动记录房租、订阅或零花钱。';

  @override
  String recurringNext(String date) {
    return '下次：$date';
  }

  @override
  String recurringSetupFailed(String details) {
    return '收支已保存，但无法设置重复：$details';
  }

  @override
  String get recurringSkippedBalance => '上次执行已跳过：余额不足';

  @override
  String get recurringSkippedSplit => '上次执行已跳过：部分参与者已离开账本';

  @override
  String get recurringStop => '停止';

  @override
  String get recurringStopConfirm => '停止此定期收支？已创建的收支将保留。';

  @override
  String get recurringTitle => '定期收支';

  @override
  String get repeatLabel => '重复';

  @override
  String get repeatNever => '从不';

  @override
  String get repeatWeekly => '每周';

  @override
  String get repeatMonthly => '每月';

  @override
  String get requestPayment => '请求付款';

  @override
  String get searchMovements => '搜索收支';

  @override
  String shareInviteLinkText(String name, String link, String code) {
    return '加入我在 EnCaisse 的账本“$name”：$link\n或在应用中输入邀请码 $code。';
  }

  @override
  String get splitBalanced => '份额与金额一致';

  @override
  String splitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 人分摊',
      one: '1 人',
    );
    return '$_temp0';
  }

  @override
  String get splitCustom => '自定义';

  @override
  String get splitEqually => '平均';

  @override
  String get splitEveryone => '所有人';

  @override
  String get splitJustMe => '仅我';

  @override
  String get splitMustMatch => '份额之和必须等于金额';

  @override
  String get splitPickSomeone => '请至少选择一人';

  @override
  String splitRemaining(String amount) {
    return '待分配：$amount';
  }

  @override
  String get splitTitleDeposit => '出资人';

  @override
  String get splitTitleExpense => '分摊成员';

  @override
  String get you => '你';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get resetPasswordTitle => '重置密码';

  @override
  String get resetPasswordBody => '输入账户邮箱，我们会发送一个设置新密码的链接。';

  @override
  String get resetPasswordSend => '发送链接';

  @override
  String resetPasswordSent(String email) {
    return '如果 $email 存在账户，重置链接即将送达。请查看收件箱和垃圾邮件。';
  }

  @override
  String get resetPasswordTooMany => '尝试次数过多，请稍等几分钟后再试。';

  @override
  String get resetPasswordFailed => '无法发送重置邮件，请检查网络后重试。';

  @override
  String get memberSettled => '已结清';

  @override
  String get addPhoto => '添加照片';

  @override
  String availableInCaisse(String amount) {
    return '可用：$amount';
  }
}
