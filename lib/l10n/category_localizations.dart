import 'app_localizations.dart';

extension CategoryLocalizations on AppLocalizations {
  static const List<String> _categoryKeys = [
    'Food',
    'Transport',
    'Rent',
    'Utilities',
    'Entertainment',
    'Shopping',
    'Health',
    'Travel',
    'Salary',
    'Gift',
    'Other',
  ];

  String categoryLabel(String key) {
    return switch (key) {
      'Food' => categoryFood,
      'Transport' => categoryTransport,
      'Rent' => categoryRent,
      'Utilities' => categoryUtilities,
      'Entertainment' => categoryEntertainment,
      'Shopping' => categoryShopping,
      'Health' => categoryHealth,
      'Travel' => categoryTravel,
      'Salary' => categorySalary,
      'Gift' => categoryGift,
      'Other' => categoryOther,
      _ => key,
    };
  }

  List<String> get localizedCategories =>
      _categoryKeys.map(categoryLabel).toList();

  List<({String key, String label})> get localizedCategoryEntries =>
      _categoryKeys.map((k) => (key: k, label: categoryLabel(k))).toList();
}
