import json
from pathlib import Path

root = Path("lib/l10n")

translations = {
    "en": {"memberSettled": "Even", "categoryBreakdown": "Spending by category"},
    "fr": {"memberSettled": "À jour", "categoryBreakdown": "Dépenses par catégorie"},
    "es": {"memberSettled": "Al día", "categoryBreakdown": "Gastos por categoría"},
    "pt": {"memberSettled": "Acertado", "categoryBreakdown": "Despesas por categoria"},
    "ar": {"memberSettled": "متوازن", "categoryBreakdown": "المصاريف حسب الفئة"},
    "zh": {"memberSettled": "已结清", "categoryBreakdown": "按类别的支出"},
    "hi": {"memberSettled": "बराबर", "categoryBreakdown": "श्रेणी के अनुसार खर्च"},
    "ru": {"memberSettled": "В расчёте", "categoryBreakdown": "Расходы по категориям"},
    "ja": {"memberSettled": "精算済み", "categoryBreakdown": "カテゴリ別の支出"},
}

for locale, values in translations.items():
    path = root / f"app_{locale}.arb"
    data = json.loads(path.read_text(encoding="utf-8-sig"))
    data.update(values)
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8-sig",
    )
    print(locale, len(values))
