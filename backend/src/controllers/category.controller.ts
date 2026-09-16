import { Request, Response } from "express";
import { RowDataPacket, ResultSetHeader } from "mysql2";
import { pool } from "../config/database";
import { Category } from "../types";

// GET /api/categories
export async function getAllCategories(req: Request, res: Response) {
  const [rows] = await pool.query<RowDataPacket[]>(
    "SELECT * FROM categories ORDER BY id DESC"
  );

  return res.status(200).json({
    success: true,
    message: "Berhasil mengambil data kategori",
    data: rows as Category[],
  });
}

// GET /api/categories/:id
export async function getCategoryById(req: Request, res: Response) {
  const { id } = req.params;

  const [rows] = await pool.query<RowDataPacket[]>(
    "SELECT * FROM categories WHERE id = ?",
    [id]
  );

  if (rows.length === 0) {
    return res.status(404).json({
      success: false,
      message: `Kategori dengan id ${id} tidak ditemukan`,
    });
  }

  return res.status(200).json({
    success: true,
    message: "Berhasil mengambil detail kategori",
    data: rows[0] as Category,
  });
}

// POST /api/categories
export async function createCategory(req: Request, res: Response) {
  const { name } = req.body;

  if (!name || typeof name !== "string" || name.trim() === "") {
    return res.status(400).json({
      success: false,
      message: "Field 'name' wajib diisi dan harus berupa teks",
    });
  }

  const [existing] = await pool.query<RowDataPacket[]>(
    "SELECT id FROM categories WHERE name = ?",
    [name.trim()]
  );

  if (existing.length > 0) {
    return res.status(409).json({
      success: false,
      message: "Kategori dengan nama tersebut sudah ada",
    });
  }

  const [result] = await pool.query<ResultSetHeader>(
    "INSERT INTO categories (name) VALUES (?)",
    [name.trim()]
  );

  return res.status(201).json({
    success: true,
    message: "Kategori berhasil ditambahkan",
    data: { id: result.insertId, name: name.trim() },
  });
}

// PUT /api/categories/:id
export async function updateCategory(req: Request, res: Response) {
  const { id } = req.params;
  const { name } = req.body;

  if (!name || typeof name !== "string" || name.trim() === "") {
    return res.status(400).json({
      success: false,
      message: "Field 'name' wajib diisi dan harus berupa teks",
    });
  }

  const [existing] = await pool.query<RowDataPacket[]>(
    "SELECT id FROM categories WHERE id = ?",
    [id]
  );

  if (existing.length === 0) {
    return res.status(404).json({
      success: false,
      message: `Kategori dengan id ${id} tidak ditemukan`,
    });
  }

  const [duplicate] = await pool.query<RowDataPacket[]>(
    "SELECT id FROM categories WHERE name = ? AND id != ?",
    [name.trim(), id]
  );

  if (duplicate.length > 0) {
    return res.status(409).json({
      success: false,
      message: "Kategori dengan nama tersebut sudah ada",
    });
  }

  await pool.query("UPDATE categories SET name = ? WHERE id = ?", [
    name.trim(),
    id,
  ]);

  return res.status(200).json({
    success: true,
    message: "Kategori berhasil diperbarui",
    data: { id: Number(id), name: name.trim() },
  });
}

// DELETE /api/categories/:id
export async function deleteCategory(req: Request, res: Response) {
  const { id } = req.params;

  const [existing] = await pool.query<RowDataPacket[]>(
    "SELECT id FROM categories WHERE id = ?",
    [id]
  );

  if (existing.length === 0) {
    return res.status(404).json({
      success: false,
      message: `Kategori dengan id ${id} tidak ditemukan`,
    });
  }

  await pool.query("DELETE FROM categories WHERE id = ?", [id]);

  return res.status(200).json({
    success: true,
    message: "Kategori berhasil dihapus",
  });
}
