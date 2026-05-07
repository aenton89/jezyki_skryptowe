const express = require("express");
const sqlite3 = require("sqlite3").verbose();
const app = express();
const port = 3000;

app.use(express.json());

const db = new sqlite3.Database("./database.db");



// endpointy dla kategorii i produktów
app.get("/categories", (req, res) => {
    db.all(
        "SELECT * FROM categories",
        [],
        (err, rows) => {
            if (err) {
                res.status(500).json(err);

                return;
            }

            res.json(rows);
        }
    );
});

app.get("/products", (req, res) => {
    db.all(
        "SELECT * FROM products",
        [],
        (err, rows) => {
            if (err) {
                res.status(500).json(err);

                return;
            }

            res.json(rows);
        }
    );
});



// start serwera
app.listen(port, () => {
    console.log(`SERVER RUNNING: port ${port}`);
});