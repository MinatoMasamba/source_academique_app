class UserProfile {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final String universityName;
  final String faculty;
  final String department;
  final String promotion;
  final String promotionDisplay;
  final String? description;
  final String? skills;
  final String whatsapp;
  final String? pourcentage;
  final bool? encadrement;
  final String? aiContext;
  final int documentsCount;
  final double averageRating;

  UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    required this.universityName,
    required this.faculty,
    required this.department,
    required this.promotion,
    required this.promotionDisplay,
    this.description,
    this.skills,
    required this.whatsapp,
    this.pourcentage,
    this.encadrement,
    this.aiContext,
    this.documentsCount = 0,
    this.averageRating = 0.0,
  });

  /// Transforme le JSON du Backend Django en objet Flutter UserProfile
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      photoUrl: json['photo'], // Déjà l'URL complète grâce au Serializer
      universityName: json['university_name'] ?? '',
      faculty: json['faculty_name'] ?? '',
      department: json['department_name'] ?? '',
      promotion: json['promotion'] ?? '',
      promotionDisplay: json['promotion_display'] ?? '',
      description: json['description'],
      skills: json['skills'],
      whatsapp: json['numero_whatsapp'] ?? '',
      pourcentage: json['pourcentage'],
      encadrement: json['encadrement'],
      aiContext: json['ai_context'],
      documentsCount: json['documents_count'] ?? 0,
      averageRating: (json['average_rating'] != null) ? double.parse(json['average_rating'].toString()) : 0.0,
    );
  }

  /// Transforme l'objet Flutter en Map pour les mises à jour (POST/PATCH)
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'description': description,
      'skills': skills,
      'promotion': promotion,
      'numero_whatsapp': whatsapp,
      // On n'envoie généralement pas les '_name' car ce sont des ReadOnly en backend
    };
  }

  /// Permet de créer une copie modifiée de l'objet (Utile pour les Blocs/Providers)
  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? description,
    String? skills,
    String? whatsapp,
    String? photoUrl,
  }) {
    return UserProfile(
      id: id,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      universityName: universityName,
      faculty: faculty,
      department: department,
      promotion: promotion,
      promotionDisplay: promotionDisplay,
      description: description ?? this.description,
      skills: skills ?? this.skills,
      whatsapp: whatsapp ?? this.whatsapp,
      photoUrl: photoUrl ?? this.photoUrl,
      pourcentage: pourcentage,
      encadrement: encadrement,
      aiContext: aiContext,
    );
  }
}