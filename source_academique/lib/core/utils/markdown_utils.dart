class MarkdownUtils {
  // Supprime les balises Markdown pour créer un aperçu en texte brut
  static String removeMarkdown(String markdown) {
    if (markdown.isEmpty) return '';
    
    var text = markdown;
    
    // Supprimer les titres #
    text = text.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
    
    // Supprimer le gras et italique
    text = text.replaceAll(RegExp(r'\*\*\*(.*?)\*\*\*'), r'$1');
    text = text.replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1');
    text = text.replaceAll(RegExp(r'\*(.*?)\*'), r'$1');
    text = text.replaceAll(RegExp(r'__(.*?)__'), r'$1');
    text = text.replaceAll(RegExp(r'_(.*?)_'), r'$1');
    
    // Supprimer les liens [texte](url)
    text = text.replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1');
    
    // Supprimer les images ![alt](url)
    text = text.replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '');
    
    // Supprimer le code inline
    text = text.replaceAll(RegExp(r'`(.*?)`'), r'$1');
    
    // Supprimer les blocs de code
    text = text.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    
    // Supprimer les citations
    text = text.replaceAll(RegExp(r'^>\s+', multiLine: true), '');
    
    // Supprimer les listes
    text = text.replaceAll(RegExp(r'^[\*\-\+]\s+', multiLine: true), '');
    text = text.replaceAll(RegExp(r'^\d+\.\s+', multiLine: true), '');
    
    // Nettoyer les lignes vides multiples
    text = text.replaceAll(RegExp(r'\n\s*\n'), '\n\n');
    
    return text.trim();
  }

  // Extrait un résumé de X caractères
  static String getSummary(String text, {int length = 150, bool preserveSentences = true}) {
    final plainText = removeMarkdown(text);
    if (plainText.length <= length) return plainText;
    
    if (preserveSentences) {
      // Essayer de couper à la fin d'une phrase
      var truncated = plainText.substring(0, length);
      final lastPeriod = truncated.lastIndexOf('.');
      final lastQuestion = truncated.lastIndexOf('?');
      final lastExclamation = truncated.lastIndexOf('!');
      
      final lastSentenceEnd = [lastPeriod, lastQuestion, lastExclamation]
          .where((i) => i > 0)
          .fold(0, (max, i) => i > max ? i : max);
      
      if (lastSentenceEnd > length * 0.6) {
        truncated = plainText.substring(0, lastSentenceEnd + 1);
      }
      
      return "$truncated...";
    }
    
    return "${plainText.substring(0, length)}...";
  }

  // Extraire la première image d'un contenu Markdown
  static String? extractFirstImage(String markdown) {
    final imageRegex = RegExp(r'!\[.*?\]\((.*?)\)');
    final match = imageRegex.firstMatch(markdown);
    return match?.group(1);
  }

  // Compter le temps de lecture approximatif (mots/minute)
  static int estimateReadingTime(String markdown) {
    final plainText = removeMarkdown(markdown);
    final wordCount = plainText.split(RegExp(r'\s+')).length;
    const wordsPerMinute = 200;
    return (wordCount / wordsPerMinute).ceil();
  }

  // Générer un texte de lecture formaté
  static String formatReadingTime(String markdown) {
    final minutes = estimateReadingTime(markdown);
    if (minutes < 1) return "Moins d'1 min de lecture";
    return "$minutes min de lecture";
  }

  // Extraire les titres (h1, h2) pour créer une table des matières
  static List<Map<String, dynamic>> extractHeadings(String markdown) {
    final headings = <Map<String, dynamic>>[];
    final headingRegex = RegExp(r'^(#{1,6})\s+(.+)$', multiLine: true);
    
    for (final match in headingRegex.allMatches(markdown)) {
      final level = match.group(1)!.length;
      final title = match.group(2)!.trim();
      final id = title.toLowerCase().replaceAll(' ', '-');
      
      headings.add({
        'level': level,
        'title': title,
        'id': id,
      });
    }
    
    return headings;
  }

  // Convertir les URLs en liens propres pour l'affichage
  static String extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceAll('www.', '');
    } catch (_) {
      return url;
    }
  }
}