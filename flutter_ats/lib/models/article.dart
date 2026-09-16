class Article {
  const Article({
    required this.id,
    required this.title,
    required this.content,
    required this.categoryName,
    required this.categoryId,
    this.createdAt,
  });

  final int id;
  final int categoryId;
  final String title;
  final String content;
  final String categoryName;
  final String? createdAt;

  factory Article.fromJson(Map<String, dynamic> json) => Article(
    id: int.parse(json['id'].toString()),
    categoryId: int.parse(json['category_id'].toString()),
    title: json['title']?.toString() ?? '',
    content: json['content']?.toString() ?? '',
    categoryName: json['category_name']?.toString() ?? 'Tanpa kategori',
    createdAt: json['created_at']?.toString(),
  );
}

// Data artikel
