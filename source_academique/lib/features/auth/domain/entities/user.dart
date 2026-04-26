class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? profilePhoto;
  final bool isencadreur;
  final bool isChefPromotion;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profilePhoto,
    this.isencadreur = false,
    this.isChefPromotion = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Fonction interne pour convertir n'importe quel format (String ou Bool) en vrai Bool
    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      return false;
    }

    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      profilePhoto: json['photo'], // Correspond au champ 'photo' de ton modèle Profile
      // On récupère les champs du profil "aplatis" par le serializer
      isencadreur: json['isencadreur'] == true || json['isencadreur'] == 'true', 
      isChefPromotion: parseBool(json['statut']),
    );
  }
}