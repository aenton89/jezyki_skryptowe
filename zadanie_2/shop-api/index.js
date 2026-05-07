const express = require("express");
const app = express();
const port = 3000;

app.use(express.json());



const categories = [
    { id: 1, name: "Laptops" },
    { id: 2, name: "Phones" },
    { id: 3, name: "Accessories" }
];

const products = [
    {
        id: 1,
        name: "Lenovo Laptop",
        price: 3500,
        categoryId: 1
    },
    {
        id: 2,
        name: "Dell Laptop",
        price: 4000,
        categoryId: 1
    },
    {
        id: 3,
        name: "iPhone",
        price: 3000,
        categoryId: 2
    },
    {
        id: 4,
        name: "Samsung Galaxy",
        price: 2500,
        categoryId: 2
    },
    {
        id: 5,
        name: "Logitech Mouse",
        price: 150,
        categoryId: 3
    },
    {
        id: 6,
        name: "Logitech Keyboard",
        price: 200,
        categoryId: 3
    },
    {
        id: 7,
        name: "Dell Keyboard",
        price: 200,
        categoryId: 3
    }
];



// endpointy dla kategorii i produktów
app.get("/categories", (req, res) => {
    res.json(categories);
});

app.get("/products", (req, res) => {
    res.json(products);
});

// start serwera
app.listen(port, () => {
    console.log(`SERVER RUNNING: port ${port}`);
});