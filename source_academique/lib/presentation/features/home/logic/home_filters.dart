import 'package:source_academique/features/auth/domain/entities/academic_document.dart';

extension DocumentFilter on List<AcademicDocument> {
  /// Filtre la liste par faculté et par recherche textuelle (titre, faculté, auteur)
  List<AcademicDocument> applyFilters(String query, String faculty) {
    return where((doc) {
      final matchesFaculty = faculty == "Tous" || doc.faculty == faculty;
      final matchesQuery = query.isEmpty ||
          doc.title.toLowerCase().contains(query.toLowerCase()) ||
          doc.faculty.toLowerCase().contains(query.toLowerCase()) ||
          doc.author.toLowerCase().contains(query.toLowerCase());
      return matchesFaculty && matchesQuery;
    }).toList();
  }
}



extension ArticleFilter on List<Article> {
  /// Filtre la liste par faculté et par recherche textuelle (titre, faculté, auteur)
  List<Article> applyFilters(String query, String faculty) {
    return where((act) {
      final matchesFaculty = faculty == "Tous" || act.domaineNom == faculty;
      final matchesQuery = query.isEmpty ||
          act.titre.toLowerCase().contains(query.toLowerCase()) ||
          act.domaineNom.toLowerCase().contains(query.toLowerCase()) ||
          act.categorie.toLowerCase().contains(query.toLowerCase());
      return matchesFaculty && matchesQuery;
    }).toList();
  }
}