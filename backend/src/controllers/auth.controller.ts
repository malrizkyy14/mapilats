import { Request, Response } from "express";
import { RowDataPacket, ResultSetHeader } from "mysql2";
import { pool } from "../config/database";

// POST /api/auth/register
export async function register(req: Request, res: Response) {
  const { username, email, password } = req.body;

  const errors: string[] = [];
  if (!username) errors.push("username wajib diisi");
  if (!email) errors.push("email wajib diisi");
  if (!password) errors.push("password wajib diisi");

  if (errors.length > 0) {
    return res.status(400).json({ success: false, message: errors.join(", ") });
  }

  const [existing] = await pool.query<RowDataPacket[]>(
    "SELECT id FROM users WHERE email = ?",
    [email]
  );

  if (existing.length > 0) {
    return res.status(409).json({
      success: false,
      message: "Email sudah terdaftar",
    });
  }

  const [result] = await pool.query<ResultSetHeader>(
    "INSERT INTO users (username, email, password) VALUES (?, ?, ?)",
    [username, email, password]
  );

  return res.status(201).json({
    success: true,
    message: "Registrasi berhasil",
    data: { id: result.insertId, username, email },
  });
}

// POST /api/auth/login
export async function login(req: Request, res: Response) {
  const { email, password } = req.body;

  const [rows] = await pool.query<RowDataPacket[]>(
    "SELECT id, username, email FROM users WHERE email = ? AND password = ?",
    [email, password]
  );

  if (rows.length === 0) {
    return res.status(401).json({
      success: false,
      message: "Email atau password salah",
    });
  }

  return res.status(200).json({
    success: true,
    message: "Login berhasil",
    data: rows[0],
  });
}