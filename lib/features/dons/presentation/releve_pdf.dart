import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Une ligne du relevé : date, affectation, mode, montant (déjà mis en forme).
typedef LigneReleve = (
  String date,
  String affectation,
  String mode,
  String montant,
);

/// Relevé annuel des dons en PDF (sans valeur fiscale).
Future<Uint8List> relevePdf({
  required String titre,
  required String eglise,
  required String editeur,
  required String donateur,
  required List<String> entetes,
  required List<LigneReleve> lignes,
  required String total,
  required String avertissement,
  required String emisLe,
}) async {
  final police = pw.Font.ttf(
    await rootBundle.load('assets/google_fonts/NunitoSans-Regular.ttf'),
  );
  final gras = pw.Font.ttf(
    await rootBundle.load('assets/google_fonts/NunitoSans-Bold.ttf'),
  );
  const vert = PdfColor.fromInt(0xFF3D5A2A);
  final doc = pw.Document(
    title: titre,
    author: eglise,
    theme: pw.ThemeData.withFont(base: police, bold: gras),
  );
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        pw.Text(
          eglise,
          style: pw.TextStyle(font: gras, fontSize: 16, color: vert),
        ),
        pw.Text(editeur, style: const pw.TextStyle(fontSize: 9)),
        pw.SizedBox(height: 24),
        pw.Text(titre, style: pw.TextStyle(font: gras, fontSize: 20)),
        pw.SizedBox(height: 4),
        pw.Text(donateur, style: const pw.TextStyle(fontSize: 13)),
        pw.SizedBox(height: 16),
        pw.TableHelper.fromTextArray(
          headers: entetes,
          data: [
            for (final (date, affectation, mode, montant) in lignes)
              [date, affectation, mode, montant],
          ],
          headerStyle: pw.TextStyle(font: gras, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: vert),
          cellAlignments: {3: pw.Alignment.centerRight},
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
        ),
        pw.SizedBox(height: 12),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(total, style: pw.TextStyle(font: gras, fontSize: 14)),
        ),
        pw.SizedBox(height: 32),
        pw.Text(avertissement, style: const pw.TextStyle(fontSize: 9)),
        pw.SizedBox(height: 4),
        pw.Text(emisLe, style: const pw.TextStyle(fontSize: 9)),
      ],
    ),
  );
  return doc.save();
}
