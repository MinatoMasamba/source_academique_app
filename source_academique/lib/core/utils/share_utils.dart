import 'package:share_plus/share_plus.dart';

class ShareUtils {
  static Future<void> shareDocument(String title, String url) async {
    final message = "Regarde ce document académique : $title\n\nLien : $url\n\nPartagé via Source Académique";
    await Share.share(message, subject: "Partage de document : $title");
  }
}