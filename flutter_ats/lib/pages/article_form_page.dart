import 'package:flutter/material.dart';

import '../models/article.dart';
import '../models/category.dart';
import '../services/api_client.dart';
import '../widgets/status_views.dart';

// halaman form tambah/edit artikel.
// - input judul
// - pilih kategori
// - isi konten
// - tombol publish/simpan

class ArticleFormPage extends StatefulWidget {
  const ArticleFormPage({super.key, required this.api, this.article});
  final ApiClient api;
  final Article? article;
  @override
  State<ArticleFormPage> createState() => _ArticleFormPageState();
}

class _ArticleFormPageState extends State<ArticleFormPage> {
  late final titleController = TextEditingController(text: widget.article?.title);
  late final contentController = TextEditingController(text: widget.article?.content);
  late Future<List<Category>> categories;
  int? categoryId;
  bool saving = false;

  @override
  void initState() { super.initState(); categoryId = widget.article?.categoryId; categories = widget.api.getCategories(); }

  Future<void> save() async {
    if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty || categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul, kategori, dan isi wajib diisi.'))); return;
    }
    setState(() => saving = true);
    try {
      await widget.api.saveArticle(id: widget.article?.id, categoryId: categoryId!, title: titleController.text.trim(), content: contentController.text.trim());
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error is ApiException ? error.message : 'Gagal menyimpan artikel.')));
    } finally { if (mounted) setState(() => saving = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.article == null ? 'Tulis artikel' : 'Edit artikel'),
    ),
    body: FutureBuilder<List<Category>>(
      future: categories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ErrorView(
            message: 'Kategori gagal dimuat.',
            onRetry: () {
              setState(() {
                categories = widget.api.getCategories();
              });
            },
          );
        }

        final list = snapshot.data ?? [];

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Judul artikel',
                          ),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<int>(
                          initialValue: categoryId,
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                          ),
                          items: list
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category.id,
                                  child: Text(category.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => categoryId = value),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: contentController,
                          minLines: 10,
                          maxLines: 16,
                          decoration: const InputDecoration(
                            labelText: 'Isi artikel',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: saving ? null : save,
                            icon: saving
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.check_rounded),
                            label: Text(
                              widget.article == null ? 'Publikasikan' : 'Simpan perubahan',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
