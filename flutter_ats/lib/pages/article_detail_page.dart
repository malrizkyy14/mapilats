import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/api_client.dart';

class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({
    super.key,
    required this.api,
    required this.article,
    required this.onEdit,
    required this.onDelete,
  });
  final ApiClient api;
  final Article article;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [
        IconButton(
          tooltip: 'Edit',
          onPressed: () {
            Navigator.pop(context);
            onEdit();
          },
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          tooltip: 'Hapus',
          onPressed: () {
            Navigator.pop(context);
            onDelete();
          },
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Chip(
            backgroundColor: const Color(0xffeee2d8),
            labelStyle: const TextStyle(
              color: Color(0xff6f4632),
              fontWeight: FontWeight.w700,
            ),
            label: Text(article.categoryName),
          ),
          const SizedBox(height: 18),
          Text(
            article.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xff211a17),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            article.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.7,
              color: const Color(0xff493c35),
            ),
          ),
            ],
          ),
        ),
      ),
    ),
  );
}
