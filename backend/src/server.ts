import dotenv from "dotenv";
dotenv.config();

import app from "./app";
import { testConnection } from "./config/database";

const PORT =  5002;

async function startServer() {
  await testConnection();

  app.listen(PORT, () => {
    console.log(`Server berjalan di http://localhost:${PORT}`);
  });
}

startServer();
