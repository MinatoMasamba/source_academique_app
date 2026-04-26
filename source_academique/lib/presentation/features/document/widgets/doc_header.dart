import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DocHeader extends StatelessWidget {
  final String id;
  final String imageUrl;
  final VoidCallback onShare;

  const DocHeader({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 380,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(onPressed: onShare, icon: const Icon(Icons.ios_share)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Hero(
          tag: 'doc_image_$id',
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: Theme.of(context).dividerColor),
            errorWidget: (_, __, ___) => Container(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: const Icon(Icons.picture_as_pdf, size: 80),
            ),
          ),
        ),
      ),
    );
  }
}