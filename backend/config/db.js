import mysql from "mysql2";
import dotenv from "dotenv";

dotenv.config();

// Create configuration using separate environment variables
const connectionConfig = {
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  // Add your additional options here
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  multipleStatements: true,
  connectTimeout: 10000,
};

// Create the connection pool with the complete config
const pool = mysql.createPool(connectionConfig);

pool.getConnection((err, connection) => {
  if (err) {
    console.error("Error connecting to MySQL:", err);
  } else {
    console.log("Connected to MySQL");
    connection.release(); // Release the connection back to the pool
  }
});

// Export the connection pool
export default pool.promise(); // Enable promise-based queries
