import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Dates dans la langue de l'app.
extension FormatDate on BuildContext {
  String get _langue => Localizations.localeOf(this).languageCode;

  /// « dimanche 12 octobre 2026 »
  String dateLongue(DateTime d) => DateFormat.yMMMMEEEEd(_langue).format(d);

  /// « 12 oct. »
  String dateCourte(DateTime d) => DateFormat.MMMd(_langue).format(d);

  /// « 10:30 »
  String heure(DateTime d) => DateFormat.Hm(_langue).format(d);

  /// « oct. » (mois abrégé, pour les pastilles de date)
  String moisCourt(DateTime d) => DateFormat.MMM(_langue).format(d);

  String get langue => _langue;
}
