import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class AppFormatters {
  // Initialisation des locales françaises
  static Future<void> init() async {
    await initializeDateFormatting('fr_FR', null);
  }

  // Format date complète
  static String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'fr_FR').format(date);
  }

  // Format date avec heure
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(date);
  }

  // Format "il y a X temps"
  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 30) {
      return formatDate(date);
    }
    if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return "Il y a $weeks semaine${weeks > 1 ? 's' : ''}";
    }
    if (difference.inDays > 0) {
      return "Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}";
    }
    if (difference.inHours > 0) {
      return "Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}";
    }
    if (difference.inMinutes > 0) {
      return "Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}";
    }
    return "À l'instant";
  }

  // Format taille de fichier
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes.toString().length - 1) ~/ 3;
    var size = bytes / (1024 * i);
    return "${size.toStringAsFixed(1)} ${suffixes[i]}";
  }

  // Format nombre avec séparateurs (ex: 1,234)
  static String formatNumber(int number) {
    return NumberFormat('#,###', 'fr_FR').format(number);
  }

  // Format pourcentage
  static String formatPercentage(double value) {
    return "${value.toStringAsFixed(0)}%";
  }

  // Format promotion académique (ex: 2024-2025)
  static String formatAcademicYear(DateTime date) {
    final year = date.year;
    return "$year-${year + 1}";
  }

  // Troncature de texte avec élégance
  static String truncateText(String text, int maxLength, {String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  // Nettoyer et capitaliser un nom
  static String formatName(String name) {
    return name
        .trim()
        .toLowerCase()
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? word[0].toUpperCase() + word.substring(1) 
            : '')
        .join(' ');
  }
}