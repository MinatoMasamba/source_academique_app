// lib/presentation/features/space_stadent/widgets/stats/result_history_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:source_academique/features/auth/domain/entities/resultat.dart';
import 'package:source_academique/presentation/features/space_stadent/widgets/shared/student_glass_card.dart';

class ResultHistoryList extends StatelessWidget {
  final List<Resultat> results;

  const ResultHistoryList({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return StudentGlassCard(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.history_edu, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                "Aucun résultat enregistré",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    // Trier du plus récent au plus ancien
    final sortedResults = List<Resultat>.from(results)
      ..sort((a, b) => b.date.compareTo(a.date));

    return StudentGlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Historique des résultats",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedResults.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final result = sortedResults[index];
              return _buildResultTile(result);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile(Resultat result) {
    final percent = result.pourcentage * 100; // entre 0 et 100
    Color performanceColor;
    if (percent >= 70) {
      performanceColor = Colors.green;
    } else if (percent >= 50) {
      performanceColor = Colors.orange;
    } else {
      performanceColor = Colors.red;
    }

    // Déterminer l'icône selon le type d'épreuve
    IconData typeIcon;
    switch (result.typeEpreuve) {
      case 'TP':
        typeIcon = Icons.assignment;
        break;
      case 'INTERRO':
        typeIcon = Icons.quiz;
        break;
      case 'EXAMEN':
        typeIcon = Icons.school;
        break;
      default:
        typeIcon = Icons.edit_note;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: performanceColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(typeIcon, color: performanceColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.label, // Utilise le getter label
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat("dd MMM yyyy").format(result.date),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${result.note.toStringAsFixed(1)} / ${result.noteMaxima.toStringAsFixed(1)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: performanceColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${percent.toStringAsFixed(0)}%",
                  style: TextStyle(fontSize: 12, color: performanceColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}