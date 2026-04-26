import 'package:equatable/equatable.dart';

class Resultat extends Equatable {
  final int id;
  final DateTime date;
  final String typeEpreuve; // 'TP', 'INTERRO' ou 'EXAMEN'
  final double note;
  final double noteMaxima;

  const Resultat({
    required this.id,
    required this.date,
    required this.typeEpreuve,
    required this.note,
    required this.noteMaxima,
  });

  // Factory pour transformer le JSON venant de Django en objet Dart
  factory Resultat.fromJson(Map<String, dynamic> json) {
    return Resultat(
      id: json['id'],
      date: DateTime.parse(json['date']),
      typeEpreuve: json['type_epreuve'],
      note: (json['note'] as num).toDouble(),
      noteMaxima: (json['note_maxima'] as num).toDouble(),
    );
  }

  // Calcul du pourcentage (équivalent à ta @property Django)
  double get pourcentage {
    if (noteMaxima == 0) return 0.0;
    return (note / noteMaxima); // Retourne entre 0.0 et 1.0 pour les LinearProgressIndicator
  }

  // Helper pour l'affichage du libellé
  String get label {
    switch (typeEpreuve) {
      case 'TP': return "Travail Pratique";
      case 'INTERRO': return "Interrogation";
      case 'EXAMEN': return "Examen";
      default: return typeEpreuve;
    }
  }

  @override
  List<Object?> get props => [id, date, typeEpreuve, note, noteMaxima];
}