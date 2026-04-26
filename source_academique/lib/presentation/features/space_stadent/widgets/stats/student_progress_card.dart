import 'package:flutter/material.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/shared/student_glass_card.dart';

class StudentProgressCard extends StatelessWidget {
  final double progress;
  final int totalResults;
  final double averageScore;

  const StudentProgressCard({
    super.key,
    required this.progress,
    required this.totalResults,
    required this.averageScore,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).clamp(0.0, 100.0).toInt();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StudentGlassCard(
      padding: const EdgeInsets.all(16), // Réduit légèrement pour gagner de la place
      child: LayoutBuilder( // Utilisation de LayoutBuilder pour s'adapter à la largeur
        builder: (context, constraints) {
          return Row(
            children: [
              // 1. Cercle de progression adaptatif
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.25, // Prend 25% de la largeur max
                  maxHeight: constraints.maxWidth * 0.25,
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6, // Un peu plus fin pour les petits écrans
                        backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      FittedBox( // Empêche le texte du % de déborder du cercle
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "$percent%",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 16),

              // 2. Statistiques textuelles
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // S'adapte à la hauteur du contenu
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Progression", // Raccourci pour éviter les overflows
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildStatRow(Icons.assignment, "Éval.", "$totalResults", isDark),
                    const SizedBox(height: 6),
                    _buildStatRow(Icons.star, "Moy.", "${averageScore.toStringAsFixed(1)}/20", isDark),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.blueAccent),
        const SizedBox(width: 4),
        // Flexible permet au label de prendre moins de place si besoin
        Flexible(
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey.shade700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}