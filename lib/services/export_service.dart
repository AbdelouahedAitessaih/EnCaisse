import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../core/utils/formatters.dart';
import '../core/utils/settle.dart';
import '../models/models.dart';

class ExportService {
  Future<void> shareCsv({
    required Group group,
    required List<Movement> movements,
    required List<GroupMember> members,
    List<Settlement> settlements = const [],
  }) async {
    final buf = StringBuffer();
    buf.writeln('id,type,amount,title,category,createdBy,createdAt,deleted');
    for (final m in movements) {
      if (m.deleted && !m.canUndo) continue;
      buf.writeln(
        [
          _csv(m.id),
          _csv(m.type.value),
          m.amount.toStringAsFixed(2),
          _csv(m.title),
          _csv(m.category),
          _csv(m.createdByName),
          _csv(m.createdAt.toIso8601String()),
          m.deleted,
        ].join(','),
      );
    }

    final settle = computeSettle(
      members: members,
      movements: movements,
      settlements: settlements,
    );
    buf.writeln();
    buf.writeln('settle_from,settle_to,amount');
    for (final t in settle.transfers) {
      buf.writeln(
        '${_csv(t.fromName)},${_csv(t.toName)},${t.amount.toStringAsFixed(2)}',
      );
    }
    buf.writeln();
    buf.writeln('payment_from,payment_to,amount,status,created_at');
    for (final payment in settlements) {
      buf.writeln(
        '${_csv(payment.fromName)},${_csv(payment.toName)},'
        '${payment.amount.toStringAsFixed(2)},${payment.status.name},'
        '${_csv(payment.createdAt.toIso8601String())}',
      );
    }

    final dir = await getTemporaryDirectory();
    final safe = group.name.replaceAll(RegExp(r'[^\w\-]+'), '_');
    final file = File('${dir.path}/encaisse_${safe}_${group.id}.csv');
    await file.writeAsString(buf.toString());
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        subject: 'EnCaisse — ${group.name}',
      ),
    );
  }

  Future<void> sharePdf({
    required Group group,
    required List<Movement> movements,
    required List<GroupMember> members,
    required BalanceSummary balance,
    List<Settlement> settlements = const [],
  }) async {
    final settle = computeSettle(
      members: members,
      movements: movements,
      settlements: settlements,
    );
    final active = movements.where((m) => !m.deleted).toList();
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'EnCaisse — ${group.name}',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text('Currency: ${group.currency}'),
          pw.SizedBox(height: 8),
          pw.Text(
            'Balance: ${formatMoney(balance.total, currency: group.currency)}',
          ),
          pw.Text(
            'In: ${formatMoney(balance.deposits, currency: group.currency)} · '
            'Out: ${formatMoney(balance.expenses, currency: group.currency)}',
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Settle',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          if (settle.transfers.isEmpty)
            pw.Text('Everyone is even')
          else
            ...settle.transfers.map(
              (t) => pw.Text(
                '${t.fromName} → ${t.toName}: '
                '${formatMoney(t.amount, currency: group.currency)}',
              ),
            ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Recent repayments',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          if (settlements.isEmpty)
            pw.Text('No repayments recorded')
          else
            ...settlements
                .take(20)
                .map(
                  (payment) => pw.Text(
                    '${payment.fromName} → ${payment.toName}: '
                    '${formatMoney(payment.amount, currency: group.currency)} '
                    '(${payment.status.name})',
                  ),
                ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Movements',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.TableHelper.fromTextArray(
            headers: const ['Date', 'Type', 'Title', 'Amount', 'By'],
            data: active.map((m) {
              return [
                formatMovementDate(m.createdAt),
                m.type.value,
                m.title,
                formatMoney(m.amount, currency: group.currency),
                m.createdByName,
              ];
            }).toList(),
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final safe = group.name.replaceAll(RegExp(r'[^\w\-]+'), '_');
    final file = File('${dir.path}/encaisse_${safe}_${group.id}.pdf');
    await file.writeAsBytes(await doc.save());
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'EnCaisse — ${group.name}',
      ),
    );
  }

  String _csv(Object? value) {
    final s = '$value'.replaceAll('"', '""');
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"$s"';
    }
    return s;
  }
}
