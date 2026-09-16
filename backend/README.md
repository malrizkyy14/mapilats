# Blog App - Backend REST API

Backend untuk Aplikasi Blog (ATS RPL) menggunakan Express.js + TypeScript + MySQL.

## Struktur folder

```
backend/
├── src/
│   ├── config/
│   │   └── database.ts        # koneksi pool MySQL
│   ├── controllers/
│   │   ├── auth.controller.ts
│   │   ├── category.controller.ts
│   │   └── post.controller.ts
│   ├── routes/
│   │   ├── category.routes.ts
│   │   ├── post.routes.ts
│   │   └── index.ts
│   ├── middlewares/
│   │   └── errorHandler.ts    # 404 & global error handler
│   ├── utils/
│   │   └── asyncHandler.ts
│   ├── types/
│   │   └── index.ts           # interface Category, Post
│   ├── app.ts                 # setup express & routes
│   └── server.ts              # entry point
├── .env.example
├── .gitignore
├── package.json
└── tsconfig.json
```

## Skema database (db_blog_app_ATS)

```sql
CREATE TABLE categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  category_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
```

## Cara menjalankan

1. Pastikan database `db_blog_app_ATS` sudah dibuat (jalankan skema di atas).
2. Install dependency:
   ```bash
   npm install
   ```
3. Copy `.env.example` menjadi `.env`, lalu sesuaikan kredensial database:
   ```bash
   cp .env.example .env
   ```
4. Jalankan mode development (auto-restart):
   ```bash
   npm run dev
   ```
5. Server berjalan di `http://localhost:3000`

## Endpoint API

### Categories — `/api/categories`

| Method | Endpoint              | Keterangan               |
| ------ | ---------------------- | ------------------------- |
| GET    | /api/categories         | Daftar semua kategori     |
| GET    | /api/categories/:id     | Detail satu kategori      |
| POST   | /api/categories         | Tambah kategori baru      |
| PUT    | /api/categories/:id     | Edit kategori              |
| DELETE | /api/categories/:id     | Hapus kategori              |

Body `POST` / `PUT`:
```json
{ "name": "Teknologi" }
```

### Posts — `/api/posts`

| Method | Endpoint          | Keterangan                                    |
| ------ | ------------------ | ---------------------------------------------- |
| GET    | /api/posts          | Daftar semua artikel (bisa filter `?category_id=`) |
| GET    | /api/posts/:id       | Detail satu artikel                            |
| POST   | /api/posts           | Tambah artikel baru                            |
| PUT    | /api/posts/:id       | Edit artikel                                    |
| DELETE | /api/posts/:id       | Hapus artikel                                    |

Body `POST` / `PUT`:
```json
{
  "category_id": 1,
  "title": "Judul Artikel",
  "content": "Isi artikel..."
}
```

### Auth — `/api/auth`

| Method | Endpoint             | Keterangan                |
| ------ | -------------------- | ------------------------- |
| POST   | /api/auth/register   | Membuat akun baru         |
| POST   | /api/auth/login      | Login dan mendapatkan JWT |

Body register:
```json
{
  "name": "Rahul",
  "email": "Rahul@gmail.com",
  "password": "123456"
}
```

Body login:
```json
{
  "email": "Rahul@gmail.com",
  "password": "123456"
}
```

Login mengembalikan `data.token`. Gunakan token tersebut di Postman pada tab **Authorization**, pilih **Bearer Token**, lalu isi dengan token. Base URL yang digunakan adalah `http://localhost:3000`.

Collection Postman siap import tersedia di `postman/Blog-App-API.postman_collection.json`.

### Format response

Semua response mengikuti format:
```json
{
  "success": true,
  "message": "...",
  "data": { }
}
```

Status code yang dipakai: `200` (sukses), `201` (berhasil dibuat), `400` (validasi gagal), `404` (data tidak ditemukan), `409` (duplikat), `500` (error server).
