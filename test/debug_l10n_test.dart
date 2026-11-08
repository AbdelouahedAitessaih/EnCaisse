import 'package:encaisse/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('debug plural output', () {
    final l10n = AppLocalizationsEn();
    // ignore: avoid_print
    print('count=1 -> [${l10n.balanceAcrossCaisses(1)}]');
    // ignore: avoid_print
    print('count=2 -> [${l10n.balanceAcrossCaisses(2)}]');
    // ignore: avoid_print
    print('count=5 -> [${l10n.balanceAcrossCaisses(5)}]');
  });
}
