import { useEffect, useState } from "react";
import axios from "axios";
import "./App.css";
import Header from "./components/Header";
import Category from "./components/Category";
import Cart from "./components/Cart";
import Checkout from "./components/Checkout";



function App() {
    const [products, setProducts] = useState([]);
    const [categories, setCategories] = useState([]);

    const [openCategory, setOpenCategory] = useState(null);

    const [cart, setCart] = useState([]);

    const [showCart, setShowCart] = useState(false);
    const [showCheckout, setShowCheckout] = useState(false);

    useEffect(() => {
        axios.get("/api/products").then((res) => setProducts(res.data));
        axios.get("/api/categories").then((res) => setCategories(res.data));
    }, []);

    function addToCart(product) {
        setCart([...cart, product]);
    }

    function removeFromCart(index) {
        const updatedCart = [...cart];
        updatedCart.splice(index, 1);
        setCart(updatedCart);
    }

    function totalPrice() {
        return cart.reduce((sum, product) => sum + product.price, 0);
    }

    function handleBackToStore() {
        setShowCart(false);
        setShowCheckout(false);
    }

    function handleOrderComplete() {
        setCart([]);
        setShowCheckout(false);
        setShowCart(false);
    }

    if (showCheckout) {
        return (
            <Checkout
                cart={cart}
                totalPrice={totalPrice}
                onBackToStore={handleBackToStore}
                onOrderComplete={handleOrderComplete}
            />
        );
    }

    if (showCart) {
        return (
            <div>
                <Cart
                    cart={cart}
                    removeFromCart={removeFromCart}
                    totalPrice={totalPrice}
                    setShowCart={setShowCart}
                />

                {cart.length > 0 && (<div style={{ textAlign: "center", marginTop: "20px" }}>
                        <button onClick={() => setShowCheckout(true)}>
                            Go to payment
                        </button>
                    </div>
                )}
            </div>
        );
    }

    return (
        <div className="container">
            <Header
                cart={cart}
                setShowCart={setShowCart}
            />

            {categories.map((category) => (
                <Category
                    key={category.id}
                    category={category}
                    products={products}
                    openCategory={openCategory}
                    setOpenCategory={setOpenCategory}
                    addToCart={addToCart}
                />
            ))}
        </div>
    );
}

export default App;