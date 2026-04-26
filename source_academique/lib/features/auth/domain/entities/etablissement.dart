// etablissement.dart

class Faculte {
  final int? id;
  final String? nom;

  Faculte({this.id, this.nom});

  factory Faculte.fromJson(Map<String, dynamic> json) {
    return Faculte(
      id: json['id'],
      nom: json['nom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
    };
  }
}


class Departement {
  final int? id;
  final String nom;
  final Faculte? faculte;

  Departement({
    this.id,
    required this.nom,
    this.faculte,
  });

  factory Departement.fromJson(Map<String, dynamic> json) {
    return Departement(
      id: json['id'],
      nom: json['nom'] ?? '',
      // Si l'API renvoie l'objet faculte imbriqué
      faculte: json['faculte'] != null ? Faculte.fromJson(json['faculte']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'faculte': faculte?.toJson(),
    };
  }
}

class Universite {
  final int? id;
  final String nom;
  final String? description;
  final String? logo; // URL de l'image
  final List<Faculte> facultes;
  final String? siteWeb;
  final String? adresse;
  final int? anneeFondation;
  final String? pays;
  final String? recteur;
  final String? province;

  Universite({
    this.id,
    required this.nom,
    this.description,
    this.logo,
    this.facultes = const [],
    this.siteWeb,
    this.adresse,
    this.anneeFondation,
    this.pays,
    this.recteur,
    this.province,
  });

  factory Universite.fromJson(Map<String, dynamic> json) {
    return Universite(
      id: json['id'],
      nom: json['nom'] ?? '',
      description: json['description'],
      logo: json['logo'], // Django Rest Framework renvoie l'URL complète
      facultes: json['faculter'] != null
          ? List<Faculte>.from(json['faculter'].map((x) => Faculte.fromJson(x)))
          : [],
      siteWeb: json['site_web'],
      adresse: json['adresse'],
      anneeFondation: json['annee_fondation'],
      pays: json['pays'],
      recteur: json['recteur'],
      province: json['Province'], // Attention à la majuscule dans ton modèle Django
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'logo': logo,
      'faculter': facultes.map((x) => x.toJson()).toList(),
      'site_web': siteWeb,
      'adresse': adresse,
      'annee_fondation': anneeFondation,
      'pays': pays,
      'recteur': recteur,
      'Province': province,
    };
  }
}