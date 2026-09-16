class Category {
  const Category({required this.id, required this.name});

  final int id;
  final String name;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: int.parse(json['id'].toString()),
    name: json['name'].toString(),
  );
}

// data category