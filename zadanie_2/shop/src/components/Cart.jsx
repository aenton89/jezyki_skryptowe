function Cart({cart, removeFromCart, totalPrice, setShowCart}) {
    return (
        <div className="container">
            <div className="topbar">
                <h1>Cart</h1>

                <button onClick={() => setShowCart(false)}>
                    Back
                </button>
            </div>

            <div className="section">
                {cart.length === 0 ? (<p>Cart is empty</p>) : (
                    <>
                        <ul className="list">
                            {cart.map((product, index) => (
                                <li key={index} className="product-row">
                                    <span>
                                        {product.name} — {product.price} PLN
                                    </span>

                                    <button onClick={() => removeFromCart(index)}>
                                        Remove
                                    </button>
                                </li>
                            ))}
                        </ul>

                        <h3>
                            Sum: {totalPrice()} PLN
                        </h3>
                    </>
                )}
            </div>
        </div>
    );
}

export default Cart;