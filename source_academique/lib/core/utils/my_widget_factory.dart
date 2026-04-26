import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:html/dom.dart' as dom;

class MathWidgetFactory extends WidgetFactory {
  // Détecte les formules LaTeX avec délimiteurs
  static final RegExp _latexDelimiter = RegExp(
    r'\$\$(.+?)\$\$|\$(.+?)\$|\\\((.+?)\\\)|\\\[(.+?)\\\]',
    dotAll: true,
  );

  @override
  Widget build(BuildContext context, BuildTree tree) {
    final element = tree.element;
    final className = element.className ?? '';

    // 1. Détection des balises <span class="arithmatex">...</span> (Markdown + pymdownx.arithmatex)
    if (className.contains('arithmatex') || element.localName == 'math') {
      final mathContent = _extractMathFromElement(element);
      if (mathContent != null && mathContent.isNotEmpty) {
        return _buildMathWidget(mathContent);
      }
    }

    // 2. Détection des formules directement dans le texte (sans balise)
    final text = element.text;
    if (_latexDelimiter.hasMatch(text)) {
      final match = _latexDelimiter.firstMatch(text);
      if (match != null) {
        final mathContent = match.group(1) ?? match.group(2) ?? match.group(3) ?? match.group(4);
        if (mathContent != null && mathContent.isNotEmpty) {
          return _buildMathWidget(mathContent.trim());
        }
      }
    }

    // 3. Pour tout autre élément, comportement par défaut
    return super.buildBodyWidget(context, tree as Widget);
  }

  /// Extrait le contenu LaTeX d'un élément HTML (ex: <span class="arithmatex">\(x^2\)</span>)
  String? _extractMathFromElement(dom.Element element) {
    // innerText donne le texte brut sans balises internes
    String raw = element.innerHtml.trim();
    if (raw.isEmpty) return null;

    // Supprime les délimiteurs résiduels
    final cleaned = raw
        .replaceAll(RegExp(r'\\\(|\\\)|\\\[|\\\]|\$\$|\$'), '')
        .trim();
    return cleaned.isEmpty ? null : cleaned;
  }

  /// Construit le widget d'affichage de la formule mathématique
  Widget _buildMathWidget(String texSource) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Math.tex(
            texSource,
            mathStyle: MathStyle.display,
            textStyle: const TextStyle(fontSize: 18),
            onErrorFallback: (error) => Text(
              texSource,
              style: const TextStyle(
                color: Colors.redAccent,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ),
    );
  }
}