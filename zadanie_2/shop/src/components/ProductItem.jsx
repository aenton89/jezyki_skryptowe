function ProductItem({product, addToCart}) {
    return (
        <li className="product-row">
            <span>
                {product.name} — {product.price} zł
            </span>

            <button onClick={() => addToCart(product)}>
                Add
            </button>
        </li>
    );
}

export default ProductItem;