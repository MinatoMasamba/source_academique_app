import 'package:flutter/material.dart';

class DocMetaSection extends StatelessWidget {
  final String title;
  final String type;
  final String size;
  final String format;
  final int pages;
  final String? promotion; // <- Ajout

  const DocMetaSection({
    super.key,
    required this.title,
    required this.type,
    required this.size,
    required this.format,
    required this.pages,
    this.promotion, // <- Nouveau paramètre
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBadge(context, type),
            Text("GRATUIT", style: TextStyle(
              color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 18
            )),
          ],
        ),
        const SizedBox(height: 16),
        Text(title, style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold, height: 1.2
        )),
        const SizedBox(height: 8),
        // Affichage de la promotion si elle existe
        if (promotion != null && promotion!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Icon(Icons.school, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  "Promotion : $promotion",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildInfoChip(context, Icons.picture_as_pdf, format),
            _buildInfoChip(context, Icons.storage, size),
            _buildInfoChip(context, Icons.menu_book, "$pages pages"),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label.toUpperCase(), style: TextStyle(
        color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12
      )),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}