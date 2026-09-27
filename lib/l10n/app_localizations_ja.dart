// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'EnCaisse';

  @override
  String get tagline => 'EnCaisse, ensemble.';

  @override
  String get getStarted => 'はじめる';

  @override
  String get alreadyHaveAccount => 'すでにアカウントがあります';

  @override
  String get skip => 'スキップ';

  @override
  String get next => '次へ';

  @override
  String get createAccount => 'アカウント作成';

  @override
  String get signIn => 'サインイン';

  @override
  String get signOut => 'サインアウト';

  @override
  String get welcomeBack => 'おかえりなさい';

  @override
  String get signInSubtitle => 'EnCaisseアカウントにサインインしてください。';

  @override
  String get joinEncaisse => 'EnCaisseに参加';

  @override
  String get signUpSubtitle => '共有のお金を透明に管理しましょう。';

  @override
  String get email => 'メール';

  @override
  String get password => 'パスワード';

  @override
  String get displayName => '表示名';

  @override
  String get or => 'または';

  @override
  String get continueWithGoogle => 'Googleで続行';

  @override
  String get needAccount => 'アカウントが必要ですか？登録';

  @override
  String get haveAccount => 'すでにアカウントがありますか？サインイン';

  @override
  String get enterEmail => 'メールアドレスを入力';

  @override
  String get validEmail => '有効なメールアドレスを入力';

  @override
  String get passwordMin => 'パスワードは6文字以上にしてください';

  @override
  String get rememberMe => 'ログイン情報を記憶';

  @override
  String get showPassword => 'パスワードを表示';

  @override
  String get hidePassword => 'パスワードを隠す';

  @override
  String get enterName => '名前を入力';

  @override
  String get hello => 'こんにちは';

  @override
  String helloName(String name) {
    return 'こんにちは、$name';
  }

  @override
  String get noGroupsYet => 'まだグループがありません';

  @override
  String get noGroupsSubtitle => '個人の金庫から始めるか、グループを作成、またはコードで参加。';

  @override
  String get createAGroup => 'グループを作成';

  @override
  String get joinWithCode => 'コードで参加';

  @override
  String get joinWithInviteCode => '招待コードで参加';

  @override
  String get settings => '設定';

  @override
  String get appearance => '外観';

  @override
  String get language => '言語';

  @override
  String get languageSystem => '端末の言語';

  @override
  String get themeMode => 'テーマ';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageFrench => 'フランス語';

  @override
  String get languageArabic => 'アラビア語';

  @override
  String get languageSpanish => 'スペイン語';

  @override
  String get languagePortuguese => 'ポルトガル語';

  @override
  String get languageChinese => '中国語';

  @override
  String get languageHindi => 'ヒンディー語';

  @override
  String get languageRussian => 'ロシア語';

  @override
  String get languageJapanese => '日本語';

  @override
  String get nameYourCaisse => 'カイスに名前を付ける';

  @override
  String get inviteCodeHint => '共有用の6文字の招待コードが発行されます。';

  @override
  String get groupName => 'グループ名';

  @override
  String get groupNameHint => '週末旅行、ルームメイト…';

  @override
  String get enterGroupName => 'グループ名を入力';

  @override
  String get currency => '通貨';

  @override
  String get selectCurrency => '通貨を選択';

  @override
  String get startingAmountOptional => '開始金額（任意）';

  @override
  String get startingAmountHelper => '後でこの金額を編集できるのはあなた（作成者）だけです。';

  @override
  String get createGroup => 'グループを作成';

  @override
  String get enterInviteCode => '招待コードを入力';

  @override
  String askForCode(int length) {
    return 'メンバーに$length文字のコードを聞いてください。';
  }

  @override
  String get inviteCode => '招待コード';

  @override
  String get joinGroup => 'グループに参加';

  @override
  String enterCodeLength(int length) {
    return '$length文字のコードを入力';
  }

  @override
  String get noGroupForCode => 'この招待コードのグループは見つかりません。';

  @override
  String get balance => '残高';

  @override
  String get inLabel => '入金';

  @override
  String get outLabel => '出金';

  @override
  String get members => 'メンバー';

  @override
  String get byCategory => 'カテゴリ別';

  @override
  String get filterAll => 'すべて';

  @override
  String get filters => 'フィルター';

  @override
  String get applyFilters => '適用';

  @override
  String get filterUser => 'ユーザー';

  @override
  String get filterDate => '日付';

  @override
  String get filterAnyTime => 'すべての日付';

  @override
  String get filterThisMonth => '今月';

  @override
  String get filterLast30Days => '過去30日間';

  @override
  String get filterChooseDates => '日付を選択';

  @override
  String get clearFilters => 'フィルターをクリア';

  @override
  String get noMatchingMovements => 'これらのフィルターに一致する取引はありません。';

  @override
  String get inviteFriends => '友達を招待';

  @override
  String get shareCodeSoFriends => 'このコードを共有して友達に参加してもらいましょう。';

  @override
  String get shareThisCode => 'このコードを共有して他の人に参加してもらいましょう。';

  @override
  String get copyCode => 'コードをコピー';

  @override
  String get share => '共有';

  @override
  String inviteCodeCopied(String code) {
    return '招待コード $code をコピーしました';
  }

  @override
  String shareInviteText(String name, String code) {
    return 'コード $code で私のEnCaisseグループ「$name」に参加してください。EnCaisse, ensemble.';
  }

  @override
  String joinOnEncaisse(String name) {
    return 'EnCaisseで$nameに参加';
  }

  @override
  String get notificationsMuted => 'このグループの通知をミュートしました';

  @override
  String get notificationsEnabled => 'このグループの通知を有効にしました';

  @override
  String get unmuteNotifications => '通知のミュートを解除';

  @override
  String get muteNotifications => '通知をミュート';

  @override
  String get noMovementsYet => 'まだ取引がありません';

  @override
  String get noMovementsSubtitle => 'このカイスの最初の入金または支出を追加してください。';

  @override
  String get addMovement => '取引を追加';

  @override
  String get editMovement => '取引を編集';

  @override
  String get movement => '取引';

  @override
  String get startingBalance => '開始残高';

  @override
  String get editStartingBalance => '開始残高を編集';

  @override
  String get type => '種類';

  @override
  String get deposit => '入金';

  @override
  String get expense => '支出';

  @override
  String get amount => '金額';

  @override
  String get startingAmount => '開始金額';

  @override
  String get title => 'タイトル';

  @override
  String get titleHint => '食料品、家賃の分担…';

  @override
  String get category => 'カテゴリ';

  @override
  String get addReceipt => '領収書の写真を追加（任意）';

  @override
  String get receiptSelected => '領収書を選択済み';

  @override
  String get saveChanges => '変更を保存';

  @override
  String get enterValidAmount => '有効な金額を入力';

  @override
  String get enterTitle => 'タイトルを入力';

  @override
  String get onlyCreatorEditStarting => 'この金額を変更できるのはあなた（作成者）だけです。';

  @override
  String get onlyCreatorCanEditStarting => '開始残高を編集できるのは、このカイスを作成した人だけです。';

  @override
  String get onlyYouEditStarting => 'この開始金額を編集できるのはあなただけです。';

  @override
  String get onlyCreatorEditAmount => 'この金額を編集できるのはカイスの作成者だけです。';

  @override
  String get createdBy => '作成者';

  @override
  String get created => '作成日時';

  @override
  String get receipt => '領収書';

  @override
  String get attached => '添付済み';

  @override
  String get auditTrail => '監査ログ';

  @override
  String get auditTrailSubtitle => '追加のみの履歴です。これらのエントリを編集・削除できる人はいません。';

  @override
  String get noAuditYet => 'まだ監査エントリがありません。';

  @override
  String get deleteMovement => '取引を削除しますか？';

  @override
  String get deleteStartingBalance => '開始残高を削除しますか？';

  @override
  String get softDeleteHint => '取引は24時間ソフト削除されます。スナックバーまたはこの画面から元に戻せます。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get movementDeletedUndo => '取引を削除しました — 元に戻す';

  @override
  String get undo => '元に戻す';

  @override
  String get movementRestored => '取引を復元しました';

  @override
  String get softDeletedCanUndo => 'ソフト削除済み — 24時間以内なら元に戻せます。';

  @override
  String get softDeletedExpired => 'ソフト削除済み — 取り消し期限が切れました。';

  @override
  String get undoDelete => '削除を取り消す';

  @override
  String get actionCreate => '作成';

  @override
  String get actionUpdate => '更新';

  @override
  String get actionDelete => '削除';

  @override
  String get groupNotFound => 'グループが見つかりません';

  @override
  String get movementNotFound => '取引が見つかりません';

  @override
  String get couldNotLoadGroups => 'グループを読み込めませんでした。Firebaseの設定を確認してください。';

  @override
  String get onboardingTitle1 => 'ひとつの共有カイス';

  @override
  String get onboardingBody1 =>
      '一人でも友人とでも記録できます。共有グループでは全員が入金・支出を追加でき、管理者の階層はありません。';

  @override
  String get onboardingTitle2 => '完全な監査ログ';

  @override
  String get onboardingBody2 => 'すべての変更が記録されます。信頼は権限ではなく透明性から生まれます。';

  @override
  String get onboardingTitle3 => 'コードで招待';

  @override
  String get onboardingBody3 => 'グループを作成するか、6文字の招待コードで参加します。';

  @override
  String get welcomeSubtitle => '一人でも、みんなと一緒でもお金を管理できます。';

  @override
  String get validStartingAmount => '有効な開始金額を入力するか、空のままにしてください。';

  @override
  String get manageGroup => 'グループを管理';

  @override
  String get renameGroup => 'グループ名を変更';

  @override
  String get renameGroupHint => 'このカイスの新しい名前を入力してください。';

  @override
  String get save => '保存';

  @override
  String get manageMembers => 'メンバーを管理';

  @override
  String get removeMember => '削除';

  @override
  String removeMemberConfirm(String name) {
    return '$name をこのグループから削除しますか？';
  }

  @override
  String get memberRemoved => 'メンバーを削除しました';

  @override
  String get cannotRemoveCreator => 'グループの作成者は削除できません。';

  @override
  String get deleteGroup => 'グループを削除';

  @override
  String get deleteGroupConfirm => 'このグループを削除しますか？';

  @override
  String get deleteGroupHint => 'グループ、メンバー、すべての取引が完全に削除されます。元に戻せません。';

  @override
  String get groupDeleted => 'グループを削除しました';

  @override
  String get groupRenamed => 'グループ名を変更しました';

  @override
  String get creator => '作成者';

  @override
  String get changeGroupPhoto => 'グループ写真を変更';

  @override
  String get groupPhotoUpdated => 'グループ写真を更新しました';

  @override
  String get leaveGroup => 'グループを退出';

  @override
  String get leaveGroupHint => 'グループを退出しますが、取引履歴は残ります。';

  @override
  String get leftGroup => 'グループを退出しました';

  @override
  String get profile => 'プロフィール';

  @override
  String get editProfile => 'プロフィールを編集';

  @override
  String get changePhoto => '写真を変更';

  @override
  String get profileUpdated => 'プロフィールを更新しました';

  @override
  String get incorrectCredentials => 'メールまたはパスワードが正しくありません。';

  @override
  String get firebaseNotConfigured =>
      'Firebaseはまだ設定されていません。google-services.jsonを追加してください。';

  @override
  String get signInFailed => 'サインインに失敗しました。もう一度お試しください。';

  @override
  String get signUpFailed => '登録に失敗しました。もう一度お試しください。';

  @override
  String get googleSignInCanceled => 'Googleログインがキャンセルされました。';

  @override
  String get googleSignInConfigError =>
      'Googleログインが未設定です。FirebaseにSHA-1を追加し、新しいgoogle-services.jsonをダウンロードしてください。';

  @override
  String get googleSignInFailed => 'Googleログインに失敗しました。もう一度お試しください。';

  @override
  String get forceUpdateTitle => 'アップデートが必要です';

  @override
  String get forceUpdateBody => '続行するには新しいバージョンの EnCaisse が必要です。ストアから更新してください。';

  @override
  String get updateAvailableTitle => 'アップデートがあります';

  @override
  String get updateAvailableBody => '重要な改善を含む新しいバージョンの EnCaisse があります。';

  @override
  String get updateNow => '今すぐ更新';

  @override
  String get updateLater => '後で';

  @override
  String get emailAlreadyInUse => 'このメールのアカウントは既に存在します。';

  @override
  String get weakPassword => 'より強力なパスワードを選んでください。';

  @override
  String get member => 'メンバー';

  @override
  String get aMember => 'メンバー';

  @override
  String get someoneJoined => '誰かが参加しました';

  @override
  String memberJoinedBody(String name, String group) {
    return '$nameが$groupに参加しました';
  }

  @override
  String get joinAGroup => 'グループに参加';

  @override
  String errorWithDetails(String error) {
    return 'エラー: $error';
  }

  @override
  String get enterValidAmountGtZero => '0より大きい有効な金額を入力してください。';

  @override
  String couldNotLoadAudit(String error) {
    return '監査ログを読み込めませんでした: $error';
  }

  @override
  String get newMovementNotify => '新しい取引';

  @override
  String get depositNotifyTitle => '新しい入金';

  @override
  String get expenseNotifyTitle => '新しい支出';

  @override
  String get movementUpdatedNotify => '取引が更新されました';

  @override
  String get movementDeletedNotify => '取引が削除されました';

  @override
  String get movementRestoredNotify => '取引が復元されました';

  @override
  String addedDeposit(String name, String title) {
    return '$nameが入金を追加しました: $title';
  }

  @override
  String addedExpense(String name, String title) {
    return '$nameが支出を追加しました: $title';
  }

  @override
  String addedDepositAmount(String name, String amount, String title) {
    return '$nameが入金 $amount を追加しました: $title';
  }

  @override
  String addedExpenseAmount(String name, String amount, String title) {
    return '$nameが支出 $amount を追加しました: $title';
  }

  @override
  String updatedMovementBy(String name, String title) {
    return '$nameが更新しました: $title';
  }

  @override
  String deletedMovementBy(String name, String title) {
    return '$nameが削除しました: $title';
  }

  @override
  String restoredMovementBy(String name, String title) {
    return '$nameが復元しました: $title';
  }

  @override
  String get deletedMarker => '削除済み';

  @override
  String get insufficientBalance => '残高不足です。これでは金庫がマイナスになります。';

  @override
  String get dateLabel => '日付';

  @override
  String get timeLabel => '時刻';

  @override
  String get verifyEmailTitle => 'メールを確認してください';

  @override
  String verifyEmailBody(String email) {
    return '$email に確認リンクを送りました。開いてから続行をタップしてください。';
  }

  @override
  String get resendVerification => 'メールを再送';

  @override
  String get verificationEmailSent => '確認メールを送信しました';

  @override
  String get emailVerifiedContinue => '続行';

  @override
  String get emailNotVerifiedYet => 'メールはまだ確認されていません。受信箱を確認してください。';

  @override
  String get checkVerification => '確認しました';

  @override
  String get settleTitle => '誰が誰に払うか';

  @override
  String get settleSubtitle => '入金と支出に基づく均等な分け方です。';

  @override
  String get settleSettled => '全員清算済み';

  @override
  String settleOwes(String from, String to) {
    return '$from は $to に支払う';
  }

  @override
  String get memberNet => '純額';

  @override
  String get chartsTitle => 'グラフ';

  @override
  String get categoryBreakdown => 'カテゴリ別';

  @override
  String get exportCsv => 'CSVを書き出す';

  @override
  String get exportPdf => 'PDFを書き出す';

  @override
  String get exportShared => '共有の準備ができました';

  @override
  String get exportFailed => '書き出せませんでした';

  @override
  String get notifications => '通知';

  @override
  String get noNotifications => '通知はまだありません';

  @override
  String get noNotificationsSubtitle => 'グループの活動がここに表示されます。';

  @override
  String get markAllRead => 'すべて既読にする';

  @override
  String get offlineBanner => 'オフラインです。キャッシュがあれば表示します。';

  @override
  String get offlineRetry => '再試行';

  @override
  String get forceUpdateBodyIos =>
      '新しいバージョンの EnCaisse が必要です。App Store から更新してください。';

  @override
  String get openStore => 'ストアを開く';

  @override
  String get insightsTitle => '分析';

  @override
  String get insightsOpen => '分析';

  @override
  String get yourCaisses => 'あなたの金庫';

  @override
  String get homeOverview => 'お金をひと目でまとめて確認。';

  @override
  String get personalCaisse => '個人の金庫';

  @override
  String get personalCaisseSubtitle => '自分のお金を記録する専用スペース。';

  @override
  String get personalCaisseName => '自分の金庫';

  @override
  String get personalBadge => '個人';

  @override
  String get manageCaisse => '自分の金庫を管理';

  @override
  String get renameCaisse => '金庫の名前を変更';

  @override
  String get changeCaissePhoto => '金庫の写真を変更';

  @override
  String get caissePhotoUpdated => '金庫の写真を更新しました';

  @override
  String get caisseRenamed => '金庫の名前を変更しました';

  @override
  String get deleteCaisse => '金庫を削除';

  @override
  String get deleteCaisseConfirm => 'この金庫を削除しますか？';

  @override
  String get deleteCaisseHint => '金庫とすべての取引が完全に削除されます。この操作は取り消せません。';

  @override
  String get caisseDeleted => '金庫を削除しました';

  @override
  String get howToUse => 'EnCaisse の使い方';

  @override
  String get tourNext => '次へ';

  @override
  String get tourBack => '戻る';

  @override
  String get tourSkip => 'スキップ';

  @override
  String get tourDone => '了解';

  @override
  String get tourHome1Title => 'ホーム';

  @override
  String get tourHome1Body => '参加中の金庫が一覧表示されます。タップして入金・支出・残高を確認できます。';

  @override
  String get tourHome2Title => '一人で記録';

  @override
  String get tourHome2Body => '個人用ノートが必要なら + から個人の金庫を選びます。招待コードは不要です。';

  @override
  String get tourHome3Title => 'みんなと共有';

  @override
  String get tourHome3Body => 'グループを作るか、6文字のコードで参加。全員が同じ透明な履歴を見ます。';

  @override
  String get tourGroup1Title => 'ライブ残高';

  @override
  String get tourGroup1Body => '緑のカードは常に取引から計算されます（入金−支出）。改ざんできる保存残高ではありません。';

  @override
  String get tourGroup2Title => '取引を追加';

  @override
  String get tourGroup2Body => '+ で入金または支出を追加。領収書も添付でき、変更は監査ログに残ります。';

  @override
  String get tourGroup3Title => '招待と分析';

  @override
  String get tourGroup3Body => '招待コードを共有。精算とグラフで誰が誰に払うか、カテゴリ別支出を確認できます。';

  @override
  String get tourGroup3BodyPersonal => '分析からカテゴリ別の支出を確認できます。この金庫はあなた専用です。';

  @override
  String get tapPhotoToChange => 'タップして写真を変更';

  @override
  String get tapPhotoToView => 'タップして表示';

  @override
  String get creatingPersonal => '個人の金庫を開いています…';
}
