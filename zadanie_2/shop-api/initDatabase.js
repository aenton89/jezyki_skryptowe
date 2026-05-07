const sqlite3 = require("sqlite3").verbose();
const db = new sqlite3.Database("./database.db");



db.serialize(() => {
    db.run(`
        CREATE TABLE IF NOT EXISTS categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
        )
    `);

    db.run(`
        CREATE TABLE IF NOT EXISTS products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price INTEGER,
            categoryId INTEGER
        )
    `);

    db.run(`
        INSERT INTO categories (name)
        VALUES
        ('Laptops'),
        ('Phones'),
        ('Accessories')
    `);

    db.run(`
        INSERT INTO products (name, price, categoryId)
        VALUES
        ('Lenovo Laptop', 3500, 1),
        ('Dell Laptop', 4000, 1),
        ('iPhone', 300, 2),
        ('Samsung Galaxy', 2500, 2),
        ('Logitech Mouse', 150, 3),
        ('Logitech Keyboard', 200, 3),
        ('Dell Keyboard', 200, 3)
    `);
});



db.close();

console.log("DATABASE INITIALIZED");