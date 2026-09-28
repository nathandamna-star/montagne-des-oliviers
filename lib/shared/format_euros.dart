import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

extension FormatEuros on BuildContext {
  /// « 50 € », « 12,50 € » dans la langue de l'app.
  String euros(double montant) => NumberFormat.currency(
    locale: Localizations.localeOf(this).toLanguageTag(),
    symbol: '€',
    decimalDigits: montant == montant.roundToDouble() ? 0 : 2,
  ).format(montant);
}
