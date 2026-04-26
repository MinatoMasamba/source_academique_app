import 'package:flutter/material.dart';
import 'package:source_academique/features/auth/domain/entities/academic_document.dart';

class DiscoveryCard extends StatelessWidget {
  final AcademicDocument document;
  final VoidCallback onTap;

  const DiscoveryCard({
    super.key,
    required this.document,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Zone Image avec le Badge
            Stack(
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(document.coverImageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Le petit badge (ex: 19% off ou NOUVEAU)
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      document.badge,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Icône Favoris (Le coeur)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border, size: 16, color: Colors.black54),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Infos textuelles
            Text(
              document.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            // Étoiles et Note
            Row(
              children: [
                const Icon(Icons.star, size: 12, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  document.rating.toString(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Text(
                  " (${document.reviewsCount})",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Prix ou Mention (Simulé par la faculté)
            Text(
              document.faculty,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}