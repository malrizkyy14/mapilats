import { Request, Response } from "express";
import { RowDataPacket, ResultSetHeader } from "mysql2";
import { pool } from "../config/database";
import { Post } from "../types";

const POST_SELECT = `
  SELECT posts.*, categories.name AS category_name
  FROM posts
  JOIN categories ON categories.id = posts.category_id
`;

// GET /api/posts
// Mendukung filter opsional: ?category_id=1
export async function getAllPosts(req: Request, res: Response) {
  const { category_id } = req.query;

  let query = POST_SELECT;
  const params: (string | number)[] = [];

  if (category_id) {
    query += " WHERE posts.category_id = ?";
    params.push(Number(category_id));
  }

  query += " ORDER BY posts.created_at DESC";

  const [rows] = await pool.query<RowDataPacket[]>(query, params);

  return res.status(200).json({
    success: true,
    message: "Berhasil mengambil daftar artikel",
    data: rows,
  });
}

// GET /api/posts/:id
export async function getPostById(req: Request, res: Response) {
  const { id } = req.params;

  const [rows] = await pool.query<RowDataPacket[]>(
    `${POST_SELECT} WHERE posts.id = ?`,
    [id]
  );

  if (rows.length === 0) {
    return res.status(404).json({
      success: false,
      message: `Artikel dengan id ${id} tidak ditemukan`,
    });
  }

  return res.status(200).json({
    success: true,
    message: "Berhasil mengambil detail artikel",
    data: rows[0],
  });
}

// POST /api/posts
export async function createPost(req: Request, res: Response) {
  const { category_id, title, content } = req.body;

  // Validasi
  const errors: string[] = [];
  
  if (!category_id) errors.push("category_id wajib diisi");
  if (!title || typeof title !== "string" || title.trim() === "")
    errors.push("title wajib diisi");
  if (!content || typeof content !== "string" || content.trim() === "")
    errors.push("content wajib diisi");

  if (errors.length > 0) {
    return res.status(400).json({ success: false, message: errors.join(", ") });
  }

  const [category] = await pool.query<RowDataPacket[]>(
    "SELECT id FROM categories WHERE id = ?",
    [category_id]
  );

  if (category.length === 0) {
    return res.status(400).json({
      success: false,
      message: `category_id ${category_id} tidak ditemukan`,
    });
  }

  const [result] = await pool.query<ResultSetHeader>(
    "INSERT INTO posts (category_id, title, content) VALUES (?, ?, ?)",
    [category_id, title.trim(), content.trim()]
  );

  return res.status(201).json({
    success: true,
    message: "Artikel berhasil ditambahkan",
    data: { id: result.insertId, title: title.trim() },
  });
}

// PUT /api/posts/:id
export async function updatePost(req: Request, res: Response) {
  const { id } = req.params;
  const { category_id, title, content } = req.body;

  const [existing] = await pool.query<RowDataPacket[]>(
    "SELECT * FROM posts WHERE id = ?",
    [id]
  );

  if (existing.length === 0) {
    return res.status(404).json({
      success: false,
      message: `Artikel dengan id ${id} tidak ditemukan`,
    });
  }

  const current = existing[0] as Post;

  if (category_id) {
    const [category] = await pool.query<RowDataPacket[]>(
      "SELECT id FROM categories WHERE id = ?",
      [category_id]
    );
    if (category.length === 0) {
      return res.status(400).json({
        success: false,
        message: `category_id ${category_id} tidak ditemukan`,
      });
    }
  }

  await pool.query(
    "UPDATE posts SET category_id = ?, title = ?, content = ? WHERE id = ?",
    [
      category_id || current.category_id,
      title?.trim() || current.title,
      content?.trim() || current.content,
      id,
    ]
  );

  return res.status(200).json({
    success: true,
    message: "Artikel berhasil diperbarui",
  });
}

// DELETE /api/posts/:id
export async function deletePost(req: Request, res: Response) {
  const { id } = req.params;

  const [existing] = await pool.query<RowDataPacket[]>(
    "SELECT id FROM posts WHERE id = ?",
    [id]
  );

  if (existing.length === 0) {
    return res.status(404).json({
      success: false,
      message: `Artikel dengan id ${id} tidak ditemukan`,
    });
  }

  await pool.query("DELETE FROM posts WHERE id = ?", [id]);

  return res.status(200).json({
    success: true,
    message: "Artikel berhasil dihapus",
  });
}
