import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../services/hive_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SwitchListTile(
            value: true,
            onChanged: null,
            title: Text('Push Notifications'),
          ),
          const ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('Privacy'),
            subtitle: Text('Manage data and privacy'),
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Export Data as PDF'),
            onTap: () async {
              final doc = pw.Document();
              final moods = Hive.box(HiveService.moodsBox).values.toList().cast<Map>();
              final journals = Hive.box(HiveService.journalBox).values.toList().cast<Map>();
              doc.addPage(
                pw.MultiPage(
                  build: (ctx) => [
                    pw.Header(level: 0, child: pw.Text('Student Mental Wellness Export')),
                    pw.Paragraph(text: 'Moods'),
                    pw.TableHelper.fromTextArray(
                      headers: ['Date', 'Mood', 'Note'],
                      data: moods.map((m) => [m['date'], m['mood'].toString(), (m['note'] ?? '') as String]).toList(),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Paragraph(text: 'Journal Entries'),
                    pw.TableHelper.fromTextArray(
                      headers: ['Date', 'Sentiment', 'Text'],
                      data: journals.map((j) => [j['createdAt'], ((j['sentiment'] as num).toDouble()).toStringAsFixed(2), (j['text'] ?? '') as String]).toList(),
                    ),
                  ],
                ),
              );
              await Printing.layoutPdf(onLayout: (format) async => doc.save());
            },
          ),
        ],
      ),
    );
  }
}


