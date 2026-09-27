import 'package:flutter/widgets.dart';

class EngagementCopy {
  EngagementCopy._(this._values);

  final Map<String, String> _values;

  factory EngagementCopy.of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    const english = {
      'record': 'I paid',
      'confirm': 'Confirm received',
      'pending': 'Waiting for recipient confirmation',
      'confirmed': 'Payment confirmed',
      'explain': 'Record a real payment. The recipient confirms it before balances change.',
      'history': 'Recent repayments',
      'fromTo': '{from} paid {to}',
      'recorded': 'Payment recorded. Waiting for confirmation.',
      'success': 'Payment confirmed. Group balances are updated.',
      'owe': 'You owe',
      'owed': 'You are owed',
      'even': 'You are settled up',
      'owes': 'owes',
      'receives': 'is owed',
      'cancel': 'Cancel payment',
      'cancelled': 'Payment cancelled',
      'activityNotifications': 'Group activity',
      'activityNotificationsHint': 'Get alerts when members add activity or join.',
      'reminderNotifications': 'Helpful reminders',
      'reminderNotificationsHint': 'At most once a week, only when there is something to check.',
    };
    const translations = <String, Map<String, String>>{
      'fr': {
        'activityNotifications': 'Activité des groupes',
        'activityNotificationsHint': 'Recevez une alerte quand un membre ajoute une activité ou rejoint le groupe.',
        'reminderNotifications': 'Rappels utiles',
        'reminderNotificationsHint': 'Au maximum une fois par semaine, uniquement si une action est à faire.',
        'record': 'J’ai payé',
        'confirm': 'Confirmer la réception',
        'pending': 'En attente de confirmation',
        'confirmed': 'Paiement confirmé',
        'explain': 'Enregistrez un paiement réel. Le bénéficiaire le confirme avant la mise à jour des soldes.',
        'history': 'Remboursements récents',
        'fromTo': '{from} a payé {to}',
        'recorded': 'Paiement enregistré. En attente de confirmation.',
        'success': 'Paiement confirmé. Les soldes sont à jour.',
        'owe': 'Vous devez',
        'owed': 'On vous doit',
        'even': 'Vos comptes sont à jour',
        'owes': 'doit',
        'receives': 'doit recevoir',
        'cancel': 'Annuler le paiement',
        'cancelled': 'Paiement annulé',
      },
      'es': {
        'activityNotifications': 'Actividad del grupo',
        'activityNotificationsHint': 'Recibe avisos cuando alguien añade movimientos o se une.',
        'reminderNotifications': 'Recordatorios útiles',
        'reminderNotificationsHint': 'Como máximo una vez por semana, solo si hay algo que revisar.',
        'record': 'Ya pagué',
        'confirm': 'Confirmar recepción',
        'pending': 'Esperando confirmación',
        'confirmed': 'Pago confirmado',
        'explain': 'Registra un pago real. El destinatario lo confirma antes de actualizar los saldos.',
        'history': 'Pagos recientes',
        'fromTo': '{from} pagó a {to}',
        'recorded': 'Pago registrado. Esperando confirmación.',
        'success': 'Pago confirmado. Los saldos están actualizados.',
        'owe': 'Debes',
        'owed': 'Te deben',
        'even': 'Estás al día',
        'owes': 'debe',
        'receives': 'recibe',
        'cancel': 'Cancelar pago',
        'cancelled': 'Pago cancelado',
      },
      'pt': {
        'activityNotifications': 'Atividade do grupo',
        'activityNotificationsHint': 'Receba alertas quando alguém adicionar movimentos ou entrar no grupo.',
        'reminderNotifications': 'Lembretes úteis',
        'reminderNotificationsHint': 'No máximo uma vez por semana, apenas quando houver algo para ver.',
        'record': 'Já paguei',
        'confirm': 'Confirmar recebimento',
        'pending': 'Aguardando confirmação',
        'confirmed': 'Pagamento confirmado',
        'explain': 'Registe um pagamento real. O destinatário confirma antes de atualizar os saldos.',
        'history': 'Pagamentos recentes',
        'fromTo': '{from} pagou {to}',
        'recorded': 'Pagamento registado. Aguardando confirmação.',
        'success': 'Pagamento confirmado. Os saldos foram atualizados.',
        'owe': 'Você deve',
        'owed': 'Devem a você',
        'even': 'Está tudo acertado',
        'owes': 'deve',
        'receives': 'tem a receber',
        'cancel': 'Cancelar pagamento',
        'cancelled': 'Pagamento cancelado',
      },
      'ar': {
        'activityNotifications': 'نشاط المجموعة',
        'activityNotificationsHint': 'تلقي تنبيهات عند إضافة حركة أو انضمام عضو.',
        'reminderNotifications': 'تذكيرات مفيدة',
        'reminderNotificationsHint': 'مرة واحدة أسبوعياً كحد أقصى، عند وجود نشاط يستحق المراجعة.',
        'record': 'لقد دفعت',
        'confirm': 'تأكيد الاستلام',
        'pending': 'بانتظار تأكيد المستلم',
        'confirmed': 'تم تأكيد الدفع',
        'explain': 'سجّل دفعة فعلية. يؤكد المستلم استلامها قبل تحديث الأرصدة.',
        'history': 'الدفعات الأخيرة',
        'fromTo': 'دفع {from} إلى {to}',
        'recorded': 'تم تسجيل الدفعة. بانتظار التأكيد.',
        'success': 'تم تأكيد الدفعة وتحديث الأرصدة.',
        'owe': 'عليك',
        'owed': 'لك',
        'even': 'حسابك متوازن',
        'owes': 'عليه',
        'receives': 'له',
        'cancel': 'إلغاء الدفعة',
        'cancelled': 'تم إلغاء الدفعة',
      },
      'zh': {
        'activityNotifications': '群组动态',
        'activityNotificationsHint': '成员添加记录或加入群组时接收提醒。',
        'reminderNotifications': '实用提醒',
        'reminderNotificationsHint': '每周最多一次，仅在有新动态需要查看时提醒。',
        'record': '我已付款',
        'confirm': '确认已收款',
        'pending': '等待收款人确认',
        'confirmed': '付款已确认',
        'explain': '记录实际付款，收款人确认后才会更新余额。',
        'history': '最近的还款',
        'fromTo': '{from} 已向 {to} 付款',
        'recorded': '付款已记录，等待确认。',
        'success': '付款已确认，余额已更新。',
        'owe': '你需要支付',
        'owed': '你应收',
        'even': '账目已结清',
        'owes': '应付',
        'receives': '应收',
        'cancel': '取消付款',
        'cancelled': '付款已取消',
      },
      'hi': {
        'activityNotifications': 'समूह गतिविधि',
        'activityNotificationsHint': 'कोई सदस्य गतिविधि जोड़े या समूह में शामिल हो तो सूचना पाएँ।',
        'reminderNotifications': 'उपयोगी रिमाइंडर',
        'reminderNotificationsHint': 'सप्ताह में अधिकतम एक बार, केवल तब जब देखने के लिए नई गतिविधि हो।',
        'record': 'मैंने भुगतान किया',
        'confirm': 'प्राप्ति की पुष्टि करें',
        'pending': 'प्राप्तकर्ता की पुष्टि बाकी है',
        'confirmed': 'भुगतान की पुष्टि हुई',
        'explain': 'वास्तविक भुगतान दर्ज करें। शेष राशि बदलने से पहले प्राप्तकर्ता इसकी पुष्टि करता है।',
        'history': 'हाल के भुगतान',
        'fromTo': '{from} ने {to} को भुगतान किया',
        'recorded': 'भुगतान दर्ज हुआ। पुष्टि बाकी है।',
        'success': 'भुगतान की पुष्टि हुई और शेष राशि अपडेट हुई।',
        'owe': 'आपको देना है',
        'owed': 'आपको मिलना है',
        'even': 'आपका हिसाब बराबर है',
        'owes': 'देना है',
        'receives': 'मिलना है',
        'cancel': 'भुगतान रद्द करें',
        'cancelled': 'भुगतान रद्द हुआ',
      },
      'ru': {
        'activityNotifications': 'Активность группы',
        'activityNotificationsHint': 'Получайте уведомления о новых операциях и участниках.',
        'reminderNotifications': 'Полезные напоминания',
        'reminderNotificationsHint': 'Не чаще раза в неделю и только при наличии новых событий.',
        'record': 'Я заплатил(а)',
        'confirm': 'Подтвердить получение',
        'pending': 'Ожидает подтверждения получателя',
        'confirmed': 'Платёж подтверждён',
        'explain': 'Запишите реальный платёж. Получатель подтверждает его до обновления баланса.',
        'history': 'Последние платежи',
        'fromTo': '{from} заплатил(а) {to}',
        'recorded': 'Платёж записан. Ожидается подтверждение.',
        'success': 'Платёж подтверждён, баланс обновлён.',
        'owe': 'Вы должны',
        'owed': 'Вам должны',
        'even': 'Расчёты завершены',
        'owes': 'должен',
        'receives': 'должны',
        'cancel': 'Отменить платёж',
        'cancelled': 'Платёж отменён',
      },
      'ja': {
        'activityNotifications': 'グループのアクティビティ',
        'activityNotificationsHint': 'メンバーの記録追加や参加を通知します。',
        'reminderNotifications': '便利なリマインダー',
        'reminderNotificationsHint': '確認する新しい動きがある場合のみ、週1回まで通知します。',
        'record': '支払いました',
        'confirm': '受け取りを確認',
        'pending': '受取人の確認待ち',
        'confirmed': '支払いを確認しました',
        'explain': '実際の支払いを記録します。残高の更新前に受取人が確認します。',
        'history': '最近の支払い',
        'fromTo': '{from} から {to} への支払い',
        'recorded': '支払いを記録しました。確認待ちです。',
        'success': '支払いを確認し、残高を更新しました。',
        'owe': '支払う金額',
        'owed': '受け取る金額',
        'even': '精算済み',
        'owes': '支払う',
        'receives': '受け取る',
        'cancel': '支払いを取り消す',
        'cancelled': '支払いを取り消しました',
      },
    };
    return EngagementCopy._(translations[code] ?? english);
  }

  String get recordPayment => _values['record']!;
  String get confirmReceived => _values['confirm']!;
  String get awaitingConfirmation => _values['pending']!;
  String get paymentConfirmed => _values['confirmed']!;
  String get settlementExplanation => _values['explain']!;
  String get settlementHistory => _values['history']!;
  String get paymentRecordedMessage => _values['recorded']!;
  String get paymentConfirmedMessage => _values['success']!;
  String get youOwe => _values['owe']!;
  String get youAreOwed => _values['owed']!;
  String get youAreSettled => _values['even']!;
  String get memberOwes => _values['owes']!;
  String get memberIsOwed => _values['receives']!;
  String get cancelPayment => _values['cancel']!;
  String get paymentCancelled => _values['cancelled']!;
  String get activityNotifications =>
      _values['activityNotifications'] ?? 'Group activity';
  String get activityNotificationsHint => _values['activityNotificationsHint'] ??
      'Get alerts when members add activity or join.';
  String get reminderNotifications =>
      _values['reminderNotifications'] ?? 'Helpful reminders';
  String get reminderNotificationsHint => _values['reminderNotificationsHint'] ??
      'At most once a week, only when there is something to check.';
  String get recent => _values['recent'] ?? 'Recent';
  String get repeatLastExpense =>
      _values['repeat'] ?? 'Repeat last expense';

  String paymentLine(String from, String to) =>
      _values['fromTo']!.replaceAll('{from}', from).replaceAll('{to}', to);
}
