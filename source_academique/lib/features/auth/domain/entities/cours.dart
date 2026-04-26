// lib/features/auth/domain/entities/cours.dart
class Cours {
  final int id;
  final String description;
  final String? fichier;
  final String? fichierUrl;
  final String promotion;
  final DateTime dateAjout;
  final String? statut;
  final int? universiter;
  final int? faculter;
  final int? departement;
  final String universiterNom;
  final String faculterNom;
  final String departementNom;

  Cours({
    required this.id,
    required this.description,
    this.fichier,
    this.fichierUrl,
    required this.promotion,
    required this.dateAjout,
    this.statut,
    this.universiter,
    this.faculter,
    this.departement,
    required this.universiterNom,
    required this.faculterNom,
    required this.departementNom,
  });

  factory Cours.fromJson(Map<String, dynamic> json) => Cours(
    id: json['id'],
    description: json['description'] ?? '',
    fichier: json['fichier'],
    fichierUrl: json['fichier_url'],
    promotion: json['promotion'] ?? '',
    dateAjout: DateTime.parse(json['date_ajout']),
    statut: json['statut'],
    universiter: json['universiter'],
    faculter: json['faculter'],
    departement: json['departement'],
    universiterNom: json['universiter_nom'] ?? '',
    faculterNom: json['faculter_nom'] ?? '',
    departementNom: json['departement_nom'] ?? '',
  );
}