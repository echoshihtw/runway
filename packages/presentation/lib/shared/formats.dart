import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// The reader's locale, in the form intl takes.
String intlLocale(BuildContext context) =>
    Localizations.localeOf(context).toString();

/// Whole amounts grouped the reader's way: 1,234 or 1 234 or 1.234.
NumberFormat amountFormat(BuildContext context) =>
    NumberFormat('#,##0', intlLocale(context));
