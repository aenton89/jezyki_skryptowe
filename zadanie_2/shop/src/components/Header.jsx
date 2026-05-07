function Header({cart, setShowCart}) {
    return (
        <div className="topbar">
            <h1 className="title">Simple Shop</h1>

            <button onClick={() => setShowCart(true)}>
                Cart ({cart.length})
            </button>
        </div>
    );
}

export default Header;