import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

DateTime? parseDate(dynamic val) {
  if (val == null) return null;
  if (val is Timestamp) return val.toDate();
  if (val is DateTime) return val;
  if (val is String) {
    if (val.isEmpty) return null;
    return DateTime.tryParse(val);
  }
  return null;
}

String formatFirebaseDate(dynamic val, String pattern) {
  final d = parseDate(val);
  if (d == null) return '';
  return DateFormat(pattern).format(d.toLocal());
}
