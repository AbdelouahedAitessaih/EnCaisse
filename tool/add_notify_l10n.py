from pathlib import Path

root = Path(r"c:\Users\abdel\Bureau\EnCaisse\lib\l10n")
translations = {
    "fr": {
        "depositNotifyTitle": "Nouvel encaissement",
        "expenseNotifyTitle": "Nouveau décaissement",
        "movementUpdatedNotify": "Mouvement modifié",
        "movementDeletedNotify": "Mouvement supprimé",
        "movementRestoredNotify": "Mouvement restauré",
        "addedDepositAmount": "{name} a ajouté un encaissement de {amount} : {title}",
        "addedExpenseAmount": "{name} a ajouté un décaissement de {amount} : {title}",
        "updatedMovementBy": "{name} a modifié : {title}",
        "deletedMovementBy": "{name} a supprimé : {title}",
        "restoredMovementBy": "{name} a restauré : {title}",
    },
    "ar": {
        "depositNotifyTitle": "إيداع جديد",
        "expenseNotifyTitle": "مصروف جديد",
        "movementUpdatedNotify": "تم تعديل الحركة",
        "movementDeletedNotify": "تم حذف الحركة",
        "movementRestoredNotify": "تمت استعادة الحركة",
        "addedDepositAmount": "أضاف {name} إيداعًا بمبلغ {amount}: {title}",
        "addedExpenseAmount": "أضاف {name} مصروفًا بمبلغ {amount}: {title}",
        "updatedMovementBy": "عدّل {name}: {title}",
        "deletedMovementBy": "حذف {name}: {title}",
        "restoredMovementBy": "استعاد {name}: {title}",
    },
    "es": {
        "depositNotifyTitle": "Nuevo ingreso",
        "expenseNotifyTitle": "Nuevo gasto",
        "movementUpdatedNotify": "Movimiento actualizado",
        "movementDeletedNotify": "Movimiento eliminado",
        "movementRestoredNotify": "Movimiento restaurado",
        "addedDepositAmount": "{name} añadió un ingreso de {amount}: {title}",
        "addedExpenseAmount": "{name} añadió un gasto de {amount}: {title}",
        "updatedMovementBy": "{name} actualizó: {title}",
        "deletedMovementBy": "{name} eliminó: {title}",
        "restoredMovementBy": "{name} restauró: {title}",
    },
    "pt": {
        "depositNotifyTitle": "Novo depósito",
        "expenseNotifyTitle": "Nova despesa",
        "movementUpdatedNotify": "Movimento atualizado",
        "movementDeletedNotify": "Movimento eliminado",
        "movementRestoredNotify": "Movimento restaurado",
        "addedDepositAmount": "{name} adicionou um depósito de {amount}: {title}",
        "addedExpenseAmount": "{name} adicionou uma despesa de {amount}: {title}",
        "updatedMovementBy": "{name} atualizou: {title}",
        "deletedMovementBy": "{name} eliminou: {title}",
        "restoredMovementBy": "{name} restaurou: {title}",
    },
    "zh": {
        "depositNotifyTitle": "新存入",
        "expenseNotifyTitle": "新支出",
        "movementUpdatedNotify": "流水已更新",
        "movementDeletedNotify": "流水已删除",
        "movementRestoredNotify": "流水已恢复",
        "addedDepositAmount": "{name} 添加了存入 {amount}：{title}",
        "addedExpenseAmount": "{name} 添加了支出 {amount}：{title}",
        "updatedMovementBy": "{name} 更新了：{title}",
        "deletedMovementBy": "{name} 删除了：{title}",
        "restoredMovementBy": "{name} 恢复了：{title}",
    },
    "hi": {
        "depositNotifyTitle": "नया जमा",
        "expenseNotifyTitle": "नया खर्च",
        "movementUpdatedNotify": "लेन-देन अपडेट",
        "movementDeletedNotify": "लेन-देन हटाया गया",
        "movementRestoredNotify": "लेन-देन पुनर्स्थापित",
        "addedDepositAmount": "{name} ने {amount} का जमा जोड़ा: {title}",
        "addedExpenseAmount": "{name} ने {amount} का खर्च जोड़ा: {title}",
        "updatedMovementBy": "{name} ने अपडेट किया: {title}",
        "deletedMovementBy": "{name} ने हटाया: {title}",
        "restoredMovementBy": "{name} ने पुनर्स्थापित किया: {title}",
    },
    "ru": {
        "depositNotifyTitle": "Новый взнос",
        "expenseNotifyTitle": "Новый расход",
        "movementUpdatedNotify": "Операция обновлена",
        "movementDeletedNotify": "Операция удалена",
        "movementRestoredNotify": "Операция восстановлена",
        "addedDepositAmount": "{name} добавил(а) взнос {amount}: {title}",
        "addedExpenseAmount": "{name} добавил(а) расход {amount}: {title}",
        "updatedMovementBy": "{name} обновил(а): {title}",
        "deletedMovementBy": "{name} удалил(а): {title}",
        "restoredMovementBy": "{name} восстановил(а): {title}",
    },
    "ja": {
        "depositNotifyTitle": "新しい入金",
        "expenseNotifyTitle": "新しい支出",
        "movementUpdatedNotify": "取引が更新されました",
        "movementDeletedNotify": "取引が削除されました",
        "movementRestoredNotify": "取引が復元されました",
        "addedDepositAmount": "{name}が入金 {amount} を追加しました: {title}",
        "addedExpenseAmount": "{name}が支出 {amount} を追加しました: {title}",
        "updatedMovementBy": "{name}が更新しました: {title}",
        "deletedMovementBy": "{name}が削除しました: {title}",
        "restoredMovementBy": "{name}が復元しました: {title}",
    },
}

needle = '  "deletedMarker"'
for locale, vals in translations.items():
    path = root / f"app_{locale}.arb"
    text = path.read_text(encoding="utf-8")
    if '"depositNotifyTitle"' in text:
        print("already", locale)
        continue
    insert = "".join(f'  "{k}": "{v}",\n' for k, v in vals.items())
    if needle not in text:
        raise SystemExit(f"missing {needle} in {path}")
    path.write_text(text.replace(needle, insert + needle, 1), encoding="utf-8", newline="\n")
    print("updated", locale)
