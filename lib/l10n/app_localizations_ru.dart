// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'EnCaisse';

  @override
  String get tagline => 'EnCaisse, ensemble.';

  @override
  String get getStarted => 'Начать';

  @override
  String get alreadyHaveAccount => 'У меня уже есть аккаунт';

  @override
  String get skip => 'Пропустить';

  @override
  String get next => 'Далее';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get signIn => 'Войти';

  @override
  String get signOut => 'Выйти';

  @override
  String get welcomeBack => 'С возвращением';

  @override
  String get signInSubtitle => 'Войдите в свой аккаунт EnCaisse.';

  @override
  String get joinEncaisse => 'Присоединиться к EnCaisse';

  @override
  String get signUpSubtitle =>
      'Отслеживайте общие средства с полной прозрачностью.';

  @override
  String get email => 'Эл. почта';

  @override
  String get password => 'Пароль';

  @override
  String get displayName => 'Отображаемое имя';

  @override
  String get or => 'или';

  @override
  String get continueWithGoogle => 'Продолжить с Google';

  @override
  String get needAccount => 'Нужен аккаунт? Зарегистрируйтесь';

  @override
  String get haveAccount => 'Уже есть аккаунт? Войти';

  @override
  String get enterEmail => 'Введите эл. почту';

  @override
  String get validEmail => 'Введите корректный адрес эл. почты';

  @override
  String get passwordMin => 'Пароль должен содержать не менее 6 символов';

  @override
  String get rememberMe => 'Запомнить меня';

  @override
  String get showPassword => 'Показать пароль';

  @override
  String get hidePassword => 'Скрыть пароль';

  @override
  String get enterName => 'Введите ваше имя';

  @override
  String get hello => 'Здравствуйте';

  @override
  String helloName(String name) {
    return 'Здравствуйте, $name';
  }

  @override
  String get noGroupsYet => 'Пока нет групп';

  @override
  String get noGroupsSubtitle =>
      'Начните с личной кассы, создайте группу или войдите по коду.';

  @override
  String get createAGroup => 'Создать группу';

  @override
  String get joinWithCode => 'Войти по коду';

  @override
  String get joinWithInviteCode => 'Войти по коду приглашения';

  @override
  String get settings => 'Настройки';

  @override
  String get appearance => 'Оформление';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Язык телефона';

  @override
  String get themeMode => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageFrench => 'Французский';

  @override
  String get languageArabic => 'Арабский';

  @override
  String get languageSpanish => 'Испанский';

  @override
  String get languagePortuguese => 'Португальский';

  @override
  String get languageChinese => 'Китайский';

  @override
  String get languageHindi => 'Хинди';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageJapanese => 'Японский';

  @override
  String get nameYourCaisse => 'Назовите вашу кассу';

  @override
  String get inviteCodeHint =>
      'Вы получите 6-символьный код приглашения для обмена.';

  @override
  String get groupName => 'Название группы';

  @override
  String get groupNameHint => 'Поездка на выходные, Соседи…';

  @override
  String get enterGroupName => 'Введите название группы';

  @override
  String get currency => 'Валюта';

  @override
  String get selectCurrency => 'Выберите валюту';

  @override
  String get startingAmountOptional => 'Начальная сумма (необязательно)';

  @override
  String get startingAmountHelper =>
      'Позже изменить эту сумму сможете только вы (создатель).';

  @override
  String get createGroup => 'Создать группу';

  @override
  String get enterInviteCode => 'Введите код приглашения';

  @override
  String askForCode(int length) {
    return 'Попросите у участника код из $length символов.';
  }

  @override
  String get inviteCode => 'Код приглашения';

  @override
  String get joinGroup => 'Присоединиться к группе';

  @override
  String enterCodeLength(int length) {
    return 'Введите код из $length символов';
  }

  @override
  String get noGroupForCode => 'Группа с этим кодом приглашения не найдена.';

  @override
  String get balance => 'Баланс';

  @override
  String get inLabel => 'Приход';

  @override
  String get outLabel => 'Расход';

  @override
  String get members => 'Участники';

  @override
  String get byCategory => 'По категориям';

  @override
  String get filterAll => 'Все';

  @override
  String get filters => 'Фильтры';

  @override
  String get applyFilters => 'Применить';

  @override
  String get filterUser => 'Пользователь';

  @override
  String get filterDate => 'Дата';

  @override
  String get filterAnyTime => 'За всё время';

  @override
  String get filterThisMonth => 'В этом месяце';

  @override
  String get filterLast30Days => 'Последние 30 дней';

  @override
  String get filterChooseDates => 'Выбрать даты';

  @override
  String get clearFilters => 'Сбросить фильтры';

  @override
  String get noMatchingMovements =>
      'Нет операций, соответствующих этим фильтрам.';

  @override
  String get inviteFriends => 'Пригласить друзей';

  @override
  String get shareCodeSoFriends =>
      'Поделитесь этим кодом, чтобы друзья присоединились.';

  @override
  String get shareThisCode =>
      'Поделитесь этим кодом, чтобы другие присоединились.';

  @override
  String get copyCode => 'Скопировать код';

  @override
  String get share => 'Поделиться';

  @override
  String inviteCodeCopied(String code) {
    return 'Код $code скопирован';
  }

  @override
  String shareInviteText(String name, String code) {
    return 'Присоединяйся к моей группе EnCaisse «$name» с кодом $code. EnCaisse, ensemble.';
  }

  @override
  String joinOnEncaisse(String name) {
    return 'Присоединиться к $name в EnCaisse';
  }

  @override
  String get notificationsMuted => 'Уведомления для этой группы отключены';

  @override
  String get notificationsEnabled => 'Уведомления для этой группы включены';

  @override
  String get unmuteNotifications => 'Включить уведомления';

  @override
  String get muteNotifications => 'Отключить уведомления';

  @override
  String get noMovementsYet => 'Пока нет операций';

  @override
  String get noMovementsSubtitle =>
      'Добавьте первый взнос или расход для этой кассы.';

  @override
  String get addMovement => 'Добавить операцию';

  @override
  String get editMovement => 'Изменить операцию';

  @override
  String get movement => 'Операция';

  @override
  String get startingBalance => 'Начальный баланс';

  @override
  String get editStartingBalance => 'Изменить начальный баланс';

  @override
  String get type => 'Тип';

  @override
  String get deposit => 'Взнос';

  @override
  String get expense => 'Расход';

  @override
  String get amount => 'Сумма';

  @override
  String get startingAmount => 'Начальная сумма';

  @override
  String get title => 'Название';

  @override
  String get titleHint => 'Продукты, доля аренды…';

  @override
  String get category => 'Категория';

  @override
  String get addReceipt => 'Добавить фото чека (необязательно)';

  @override
  String get receiptSelected => 'Чек выбран';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get enterValidAmount => 'Введите корректную сумму';

  @override
  String get enterTitle => 'Введите название';

  @override
  String get onlyCreatorEditStarting =>
      'Только вы (создатель) можете изменить эту сумму.';

  @override
  String get onlyCreatorCanEditStarting =>
      'Только создатель кассы может изменить начальный баланс.';

  @override
  String get onlyYouEditStarting =>
      'Только вы можете изменить эту начальную сумму.';

  @override
  String get onlyCreatorEditAmount =>
      'Только создатель кассы может изменить эту сумму.';

  @override
  String get createdBy => 'Создал(а)';

  @override
  String get created => 'Создано';

  @override
  String get receipt => 'Чек';

  @override
  String get attached => 'Прикреплено';

  @override
  String get auditTrail => 'Журнал аудита';

  @override
  String get auditTrailSubtitle =>
      'История только на добавление. Никто не может изменить или удалить эти записи.';

  @override
  String get noAuditYet => 'Пока нет записей аудита.';

  @override
  String get deleteMovement => 'Удалить операцию?';

  @override
  String get deleteStartingBalance => 'Удалить начальный баланс?';

  @override
  String get softDeleteHint =>
      'Операция будет мягко удалена на 24 часа. Можно отменить из уведомления или с этого экрана.';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get movementDeletedUndo => 'Операция удалена — Отменить';

  @override
  String get undo => 'Отменить';

  @override
  String get movementRestored => 'Операция восстановлена';

  @override
  String get softDeletedCanUndo =>
      'Мягко удалено — вы ещё можете отменить в течение 24 часов.';

  @override
  String get softDeletedExpired => 'Мягко удалено — срок отмены истёк.';

  @override
  String get undoDelete => 'Отменить удаление';

  @override
  String get actionCreate => 'Создание';

  @override
  String get actionUpdate => 'Обновление';

  @override
  String get actionDelete => 'Удаление';

  @override
  String get groupNotFound => 'Группа не найдена';

  @override
  String get movementNotFound => 'Операция не найдена';

  @override
  String get couldNotLoadGroups =>
      'Не удалось загрузить группы. Проверьте настройку Firebase.';

  @override
  String get onboardingTitle1 => 'Одна общая касса';

  @override
  String get onboardingBody1 =>
      'Учёт в одиночку или с друзьями. В общей группе все могут добавлять взносы и расходы — без иерархии админов.';

  @override
  String get onboardingTitle2 => 'Полный журнал аудита';

  @override
  String get onboardingBody2 =>
      'Каждое изменение записывается. Доверие строится на прозрачности, а не на правах.';

  @override
  String get onboardingTitle3 => 'Приглашение по коду';

  @override
  String get onboardingBody3 =>
      'Создайте группу или присоединитесь по 6-символьному коду.';

  @override
  String get welcomeSubtitle =>
      'Учитывайте свои деньги сами или вместе с другими.';

  @override
  String get validStartingAmount =>
      'Введите корректную начальную сумму (или оставьте пустым).';

  @override
  String get manageGroup => 'Управление группой';

  @override
  String get renameGroup => 'Переименовать группу';

  @override
  String get renameGroupHint => 'Введите новое название этой кассы.';

  @override
  String get save => 'Сохранить';

  @override
  String get manageMembers => 'Управление участниками';

  @override
  String get removeMember => 'Удалить';

  @override
  String removeMemberConfirm(String name) {
    return 'Удалить $name из этой группы?';
  }

  @override
  String get memberRemoved => 'Участник удалён';

  @override
  String get cannotRemoveCreator => 'Нельзя удалить создателя группы.';

  @override
  String get deleteGroup => 'Удалить группу';

  @override
  String get deleteGroupConfirm => 'Удалить эту группу?';

  @override
  String get deleteGroupHint =>
      'Группа, участники и все операции будут удалены безвозвратно.';

  @override
  String get groupDeleted => 'Группа удалена';

  @override
  String get groupRenamed => 'Группа переименована';

  @override
  String get creator => 'Создатель';

  @override
  String get changeGroupPhoto => 'Изменить фото группы';

  @override
  String get groupPhotoUpdated => 'Фото группы обновлено';

  @override
  String get leaveGroup => 'Покинуть группу';

  @override
  String get leaveGroupHint =>
      'Вы покинете группу, но ваши операции останутся в истории.';

  @override
  String get leftGroup => 'Вы покинули группу';

  @override
  String get profile => 'Профиль';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get changePhoto => 'Изменить фото';

  @override
  String get profileUpdated => 'Профиль обновлён';

  @override
  String get incorrectCredentials => 'Неверная эл. почта или пароль.';

  @override
  String get firebaseNotConfigured =>
      'Firebase ещё не настроен. Добавьте google-services.json.';

  @override
  String get signInFailed => 'Не удалось войти. Попробуйте снова.';

  @override
  String get signUpFailed => 'Не удалось зарегистрироваться. Попробуйте снова.';

  @override
  String get googleSignInCanceled => 'Вход через Google отменён.';

  @override
  String get googleSignInConfigError =>
      'Google Sign-In не настроен. Добавьте SHA-1 в Firebase и скачайте новый google-services.json.';

  @override
  String get googleSignInFailed =>
      'Не удалось войти через Google. Попробуйте снова.';

  @override
  String get forceUpdateTitle => 'Требуется обновление';

  @override
  String get forceUpdateBody =>
      'Нужна новая версия EnCaisse. Обновите из магазина.';

  @override
  String get updateAvailableTitle => 'Доступно обновление';

  @override
  String get updateAvailableBody =>
      'Доступна новая версия EnCaisse с важными улучшениями.';

  @override
  String get updateNow => 'Обновить';

  @override
  String get updateLater => 'Позже';

  @override
  String get emailAlreadyInUse => 'Аккаунт с этой эл. почтой уже существует.';

  @override
  String get weakPassword => 'Выберите более надёжный пароль.';

  @override
  String get member => 'Участник';

  @override
  String get aMember => 'Участник';

  @override
  String get someoneJoined => 'Кто-то присоединился';

  @override
  String memberJoinedBody(String name, String group) {
    return '$name присоединился(ась) к $group';
  }

  @override
  String get joinAGroup => 'Присоединиться к группе';

  @override
  String errorWithDetails(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get enterValidAmountGtZero => 'Введите корректную сумму больше нуля.';

  @override
  String couldNotLoadAudit(String error) {
    return 'Не удалось загрузить аудит: $error';
  }

  @override
  String get newMovementNotify => 'Новая операция';

  @override
  String get depositNotifyTitle => 'Новый взнос';

  @override
  String get expenseNotifyTitle => 'Новый расход';

  @override
  String get movementUpdatedNotify => 'Операция обновлена';

  @override
  String get movementDeletedNotify => 'Операция удалена';

  @override
  String get movementRestoredNotify => 'Операция восстановлена';

  @override
  String addedDeposit(String name, String title) {
    return '$name добавил(а) взнос: $title';
  }

  @override
  String addedExpense(String name, String title) {
    return '$name добавил(а) расход: $title';
  }

  @override
  String addedDepositAmount(String name, String amount, String title) {
    return '$name добавил(а) взнос $amount: $title';
  }

  @override
  String addedExpenseAmount(String name, String amount, String title) {
    return '$name добавил(а) расход $amount: $title';
  }

  @override
  String updatedMovementBy(String name, String title) {
    return '$name обновил(а): $title';
  }

  @override
  String deletedMovementBy(String name, String title) {
    return '$name удалил(а): $title';
  }

  @override
  String restoredMovementBy(String name, String title) {
    return '$name восстановил(а): $title';
  }

  @override
  String get deletedMarker => 'удалено';

  @override
  String get insufficientBalance =>
      'Недостаточно средств. Касса стала бы отрицательной.';

  @override
  String get dateLabel => 'Дата';

  @override
  String get timeLabel => 'Время';

  @override
  String get verifyEmailTitle => 'Подтвердите email';

  @override
  String verifyEmailBody(String email) {
    return 'Мы отправили ссылку на $email. Откройте её, затем нажмите Продолжить.';
  }

  @override
  String get resendVerification => 'Отправить письмо снова';

  @override
  String get verificationEmailSent => 'Письмо для подтверждения отправлено';

  @override
  String get emailVerifiedContinue => 'Продолжить';

  @override
  String get emailNotVerifiedYet =>
      'Email ещё не подтверждён. Проверьте почту.';

  @override
  String get checkVerification => 'Я подтвердил';

  @override
  String get settleTitle => 'Кто кому должен';

  @override
  String get settleSubtitle => 'Равная доля кассы по взносам и расходам.';

  @override
  String get settleSettled => 'Все в расчёте';

  @override
  String settleOwes(String from, String to) {
    return '$from должен $to';
  }

  @override
  String get memberNet => 'Итого';

  @override
  String get chartsTitle => 'Графики';

  @override
  String get categoryBreakdown => 'По категориям';

  @override
  String get exportCsv => 'Экспорт CSV';

  @override
  String get exportPdf => 'Экспорт PDF';

  @override
  String get exportShared => 'Экспорт готов к отправке';

  @override
  String get exportFailed => 'Не удалось экспортировать';

  @override
  String get notifications => 'Уведомления';

  @override
  String get noNotifications => 'Пока нет уведомлений';

  @override
  String get noNotificationsSubtitle =>
      'Активность ваших групп появится здесь.';

  @override
  String get markAllRead => 'Отметить всё прочитанным';

  @override
  String get offlineBanner =>
      'Нет сети. Показаны кэшированные данные, если есть.';

  @override
  String get offlineRetry => 'Повторить';

  @override
  String get forceUpdateBodyIos =>
      'Нужна новая версия EnCaisse. Обновите из App Store.';

  @override
  String get openStore => 'Открыть магазин';

  @override
  String get insightsTitle => 'Аналитика';

  @override
  String get insightsOpen => 'Аналитика';

  @override
  String get yourCaisses => 'Ваши кассы';

  @override
  String get homeOverview => 'Все ваши деньги в одном месте.';

  @override
  String get personalCaisse => 'Личная касса';

  @override
  String get personalCaisseSubtitle =>
      'Личное пространство для учёта ваших денег.';

  @override
  String get personalCaisseName => 'Моя касса';

  @override
  String get personalBadge => 'Личное';

  @override
  String get manageCaisse => 'Управление вашей кассой';

  @override
  String get renameCaisse => 'Переименовать кассу';

  @override
  String get changeCaissePhoto => 'Изменить фото кассы';

  @override
  String get caissePhotoUpdated => 'Фото кассы обновлено';

  @override
  String get caisseRenamed => 'Касса переименована';

  @override
  String get deleteCaisse => 'Удалить кассу';

  @override
  String get deleteCaisseConfirm => 'Удалить эту кассу?';

  @override
  String get deleteCaisseHint =>
      'Касса и все её операции будут удалены безвозвратно. Это действие нельзя отменить.';

  @override
  String get caisseDeleted => 'Касса удалена';

  @override
  String get howToUse => 'Как пользоваться EnCaisse';

  @override
  String get tourNext => 'Далее';

  @override
  String get tourBack => 'Назад';

  @override
  String get tourSkip => 'Пропустить';

  @override
  String get tourDone => 'Понятно';

  @override
  String get tourHome1Title => 'Главная';

  @override
  String get tourHome1Body =>
      'Список всех ваших касс. Нажмите, чтобы открыть взносы, расходы и живой баланс.';

  @override
  String get tourHome2Title => 'Учёт в одиночку';

  @override
  String get tourHome2Body =>
      'Нужен личный блокнот? Нажмите + и выберите Личная касса. Без кода — только вы.';

  @override
  String get tourHome3Title => 'Делиться с другими';

  @override
  String get tourHome3Body =>
      'Создайте группу или войдите по коду из 6 символов. У всех одна прозрачная история.';

  @override
  String get tourGroup1Title => 'Живой баланс';

  @override
  String get tourGroup1Body =>
      'Зелёная карточка всегда считается из движений: взносы минус расходы. Это не сохранённая сумма, которую можно подделать.';

  @override
  String get tourGroup2Title => 'Добавить движение';

  @override
  String get tourGroup2Body =>
      'Нажмите +, чтобы добавить взнос или расход. Можно прикрепить чек; каждое изменение остаётся в аудите.';

  @override
  String get tourGroup3Title => 'Приглашение и аналитика';

  @override
  String get tourGroup3Body =>
      'Поделитесь кодом. Откройте Расчёт и графики, чтобы увидеть кто кому должен и траты по категориям.';

  @override
  String get tourGroup3BodyPersonal =>
      'Откройте аналитику расходов по категориям. Эта касса только для вас.';

  @override
  String get tapPhotoToChange => 'Нажмите фото, чтобы изменить';

  @override
  String get tapPhotoToView => 'Нажмите, чтобы посмотреть';

  @override
  String get creatingPersonal => 'Открываем вашу личную кассу…';
}
