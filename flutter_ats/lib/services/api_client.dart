import 'dart:convert';

import 'package:flutter/foundation.dart' hide Category;
import 'package:http/http.dart' as http;

import '../models/article.dart';
import '../models/category.dart';

String get apiBaseUrl {
  if (kIsWeb) {
    return 'http://localhost:5002/api';
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:5002/api';
  }

  return 'http://localhost:5002/api';
}

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
}

class ApiClient {
  ApiClient({this.token});
  final String? token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<dynamic> _request(String method, String path, [Object? body]) async {
    try {
      final uri = Uri.parse('$apiBaseUrl$path');
      final response = switch (method) {
        'GET' => await http.get(uri, headers: _headers),
        'POST' => await http.post(
          uri,
          headers: _headers,
          body: jsonEncode(body),
        ),
        'PUT' => await http.put(uri, headers: _headers, body: jsonEncode(body)),
        'DELETE' => await http.delete(uri, headers: _headers),
        _ => throw const ApiException('Metode request tidak valid'),
      };
      final data = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(data['message']?.toString() ?? 'Request gagal');
      }
      return data;
    } catch (error) {
      if (error is ApiException) rethrow;
      throw const ApiException(
        'Tidak bisa terhubung ke server. Pastikan backend aktif.',
      );
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async =>
      Map<String, dynamic>.from(
        await _request('POST', '/auth/login', {
          'email': email,
          'password': password,
        }),
      );

  Future<void> register(String name, String email, String password) async {
    await _request('POST', '/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<List<Article>> getArticles() async {
    final response = await _request('GET', '/posts');
    return (response['data'] as List)
        .map((item) => Article.fromJson(item))
        .toList();
  }

  Future<List<Category>> getCategories() async {
    final response = await _request('GET', '/categories');
    return (response['data'] as List)
        .map((item) => Category.fromJson(item))
        .toList();
  }

  Future<void> saveArticle({
    int? id,
    required int categoryId,
    required String title,
    required String content,
  }) async {
    final body = {
      'category_id': categoryId,
      'title': title,
      'content': content,
    };
    await _request(
      id == null ? 'POST' : 'PUT',
      id == null ? '/posts' : '/posts/$id',
      body,
    );
  }

  Future<void> deleteArticle(int id) async => _request('DELETE', '/posts/$id');
}
