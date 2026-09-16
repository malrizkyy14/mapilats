import 'package:flutter/material.dart';

import '../models/article.dart';

// komponen kartu artikel di daftar home.
// - tampilkan title, isi singkat, kategori
// - tombol menu edit/hapus
// - klik kartu untuk buka detail

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Article article;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xffeee2d8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    article.categoryName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff6f4632),
                    ),
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz_rounded, size: 20),
                  onSelected: (value) =>
                      value == 'edit' ? onEdit() : onDelete(),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit artikel')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Hapus artikel'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              article.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xff211a17),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              article.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                height: 1.55,
                color: Color(0xff62534a),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xff6f4632)),
                const SizedBox(width: 6),
                Text(
                  'Baca artikel',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff6f4632),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
