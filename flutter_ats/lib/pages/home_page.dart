import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/api_client.dart';
import '../widgets/article_card.dart';
import '../widgets/status_views.dart';
import 'article_detail_page.dart';
import 'article_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.api, required this.userName, required this.onLogout});
  final ApiClient api;
  final String userName;
  final VoidCallback onLogout;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Article>> articles;
  @override
  void initState() { super.initState(); _load(); }
  void _load() {
    setState(() {
      articles = widget.api.getArticles();
    });
  }

  Future<void> _openEditor([Article? article]) async {
    final changed = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => ArticleFormPage(api: widget.api, article: article)));
    if (changed == true) _load();
  }

  Future<void> _delete(Article article) async {
    final confirmed = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Hapus artikel?'), content: Text('Artikel "${article.title}" akan dihapus permanen.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus'))]));
    if (confirmed != true) return;
    try {
      await widget.api.deleteArticle(article.id);
      if (mounted) { _load(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artikel berhasil dihapus.'))); }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error is ApiException ? error.message : 'Gagal menghapus artikel.')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      centerTitle: true,
      title: const Text(
        'Blog App Malrizky14',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      actions: [
        IconButton(
          tooltip: 'Keluar',
          onPressed: widget.onLogout,
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _openEditor(),
      icon: const Icon(Icons.edit_rounded),
      label: const Text('Tulis artikel'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
    ),
    body: RefreshIndicator(
      onRefresh: () async => _load(),
      child: FutureBuilder<List<Article>>(
        future: articles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Gagal memuat artikel.',
              onRetry: _load,
            );
          }

          final items = snapshot.data ?? [];

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                children: [
                  Text(
                    'Halo, ${widget.userName}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xff6f594d),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome To Blog App Malrizky14',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xff211a17),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (items.isEmpty)
                    const EmptyView()
                  else
                    ...items.map(
                      (article) => ArticleCard(
                        article: article,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ArticleDetailPage(
                                api: widget.api,
                                article: article,
                                onEdit: () => _openEditor(article),
                                onDelete: () => _delete(article),
                              ),
                            ),
                          );
                          if (mounted) _load();
                        },
                        onEdit: () => _openEditor(article),
                        onDelete: () => _delete(article),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
