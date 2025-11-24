// Run: npm install && npm run migrate
import mysql from "mysql2/promise";
import 'dotenv/config'; // loads .env automatically

const MYSQL_HOST = process.env.MYSQL_HOST || "localhost";
const MYSQL_PORT = +(process.env.MYSQL_PORT || 3306);
const MYSQL_USER = process.env.MYSQL_USER || "root";
const MYSQL_PASS = process.env.MYSQL_PASS || "rootpassword";
const DB_NAME    = process.env.DB_NAME    || "buyme";

const ddl = [
  // Create schema
  `CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;`,
  `USE \`${DB_NAME}\`;`,

  // Drop existing People table
  `DROP TABLE IF EXISTS People;`,

  // Create People table (NO AUTO logic)
  `CREATE TABLE People (
     person_id CHAR(11) PRIMARY KEY,
     full_name VARCHAR(50) NOT NULL,
     username  VARCHAR(20) NOT NULL UNIQUE,
     email     VARCHAR(50) NOT NULL UNIQUE,
     phone_number VARCHAR(17),
     password  VARCHAR(20) NOT NULL,
     birthday  DATE
   ) ENGINE=InnoDB;`,

  // Seed demo rows (explicit person_id)
  `INSERT INTO People (person_id, full_name, username, email, phone_number, password, birthday)
   VALUES
   ('00000000001', 'Demo User', 'demo', 'demo@example.com', '123-456-7890', 'demo123', '2000-01-01'),
   ('00000000002', 'Alice Smith','alice', 'alice@example.com', '555-111-2222', 'alicepw', '1999-05-12');
  `
];

async function main() {
  const conn = await mysql.createConnection({
    host: MYSQL_HOST,
    port: MYSQL_PORT,
    user: MYSQL_USER,
    password: MYSQL_PASS,
    multipleStatements: true
  });

  try {
    for (const stmt of ddl) {
      await conn.query(stmt);
    }

    console.log(`✅ Migration complete. Database '${DB_NAME}' and 'People' table are ready.`);
  } catch (e) {
    console.error("❌ Migration failed:", e.message);
    process.exitCode = 1;
  } finally {
    await conn.end();
  }
}

main();
