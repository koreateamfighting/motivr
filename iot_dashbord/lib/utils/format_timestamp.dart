import 'package:intl/intl.dart';

String formatTimestamp(String original) {
  final dt = DateTime.parse(original);
  return DateFormat('yyyy-MM-dd HH:mm').format(dt);
}