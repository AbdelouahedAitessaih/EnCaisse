import json
from pathlib import Path

root = Path("lib/l10n")

translations = {
    "en": {"addPhoto": "Add a photo", "availableInCaisse": "Available: {amount}", "paidInCurrency": "Originally {amount} · rate {rate}"},
    "fr": {"addPhoto": "Ajouter une photo", "availableInCaisse": "Disponible : {amount}", "paidInCurrency": "À l'origine {amount} · taux {rate}"},
    "es": {"addPhoto": "Añadir una foto", "availableInCaisse": "Disponible: {amount}", "paidInCurrency": "Originalmente {amount} · tipo {rate}"},
    "pt": {"addPhoto": "Adicionar uma foto", "availableInCaisse": "Disponível: {amount}", "paidInCurrency": "Originalmente {amount} · taxa {rate}"},
    "ar": {"addPhoto": "إضافة صورة", "availableInCaisse": "المتاح: {amount}", "paidInCurrency": "المبلغ الأصلي {amount} · السعر {rate}"},
    "zh": {"addPhoto": "添加照片", "availableInCaisse": "可用：{amount}", "paidInCurrency": "原始金额 {amount} · 汇率 {rate}"},
    "hi": {"addPhoto": "फ़ोटो जोड़ें", "availableInCaisse": "उपलब्ध: {amount}", "paidInCurrency": "मूल राशि {amount} · दर {rate}"},
    "ru": {"addPhoto": "Добавить фото", "availableInCaisse": "Доступно: {amount}", "paidInCurrency": "Исходно {amount} · курс {rate}"},
    "ja": {"addPhoto": "写真を追加", "availableInCaisse": "利用可能: {amount}", "paidInCurrency": "元の金額 {amount} · レート {rate}"},
}

movement_deleted = {
    "en": "Movement deleted",
    "fr": "Mouvement supprimé",
    "es": "Movimiento eliminado",
    "pt": "Movimento eliminado",
    "ar": "تم حذف الحركة",
    "zh": "流水已删除",
    "hi": "लेन-देन हटाया गया",
    "ru": "Операция удалена",
    "ja": "取引を削除しました",
}
for locale, text in movement_deleted.items():
    translations[locale]["movementDeletedUndo"] = text

metadata = {
    "@availableInCaisse": {
        "placeholders": {"amount": {"type": "String"}},
    },
}

for locale, values in translations.items():
    path = root / f"app_{locale}.arb"
    data = json.loads(path.read_text(encoding="utf-8-sig"))
    data.update(values)
    if locale == "en":
        data.update(metadata)
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8-sig",
    )
    print(locale, len(values))
