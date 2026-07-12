import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static String relative(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String short(DateTime date) => DateFormat('MMM d, yyyy').format(date);

  static String dayMonth(DateTime date) => DateFormat('MMM d').format(date);
}
