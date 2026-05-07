import ProductItem from "./ProductItem";



function Category({category, products, openCategory, setOpenCategory, addToCart}) {
    return (
        <div className="section">
            <div 
                className="category-header" 
                onClick={() =>
                    setOpenCategory(openCategory === category.id ? null : category.id)
                }
            >
                <h2>{category.name}</h2>

                <span>
                    {openCategory === category.id ? "▲" : "▼"}
                </span>
            </div>

            {openCategory === category.id && (
                <ul className="list">
                    {products
                        .filter((product) => 
                            product.categoryId === category.id
                        )
                        .map((product) => (
                            <ProductItem key={product.id} product={product} addToCart={addToCart}/>
                        ))}
                </ul>
            )}
        </div>
    );
}

export default Category;