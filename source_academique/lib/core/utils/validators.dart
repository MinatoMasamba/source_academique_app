class Validators {
  // Validation email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "L'email est obligatoire";
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return "Format d'email invalide (ex: nom@universite.cd)";
    }
    return null;
  }

  // Validation mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Le mot de passe est obligatoire";
    }
    if (value.length < 8) {
      return "Minimum 8 caractères";
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Au moins une majuscule";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Au moins un chiffre";
    }
    return null;
  }

  // Validation confirmation mot de passe
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return "Confirmez votre mot de passe";
    }
    if (value != password) {
      return "Les mots de passe ne correspondent pas";
    }
    return null;
  }

  // Validation champ requis générique
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return "$fieldName est requis";
    }
    return null;
  }

  // Validation matricule étudiant (format UNIKIN, UPC, etc.)
  static String? validateStudentId(String? value) {
    if (value == null || value.isEmpty) {
      return "Le matricule est obligatoire";
    }
    // Format: lettres + chiffres, minimum 6 caractères
    if (!RegExp(r'^[A-Z0-9]{6,15}$').hasMatch(value.toUpperCase())) {
      return "Format invalide (ex: UNIKIN2024)";
    }
    return null;
  }

  // Validation téléphone (format RDC)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }
    // Format: 09XXXXXXXX ou +243XXXXXXXX
    if (!RegExp(r'^(09|\+243)[0-9]{9}$').hasMatch(value)) {
      return "Format invalide (ex: 0991234567 ou +243991234567)";
    }
    return null;
  }

  // Validation URL (pour les liens de ressources)
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final urlRegExp = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );
    if (!urlRegExp.hasMatch(value)) {
      return "URL invalide";
    }
    return null;
  }
}