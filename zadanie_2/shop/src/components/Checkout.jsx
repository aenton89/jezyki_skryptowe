import { useState } from "react";



function Checkout({ cart, totalPrice, onBackToStore, onOrderComplete }) {
    const [name, setName] = useState("");
    const [address, setAddress] = useState("");
    const [paid, setPaid] = useState(false);

    function handlePay() {
        if (!name || !address) {
            alert("Uzupełnij dane!");
            return;
        }

        setPaid(true);
    }

    if (paid) {
        return (
            <div className="container">
                <h1>Order placed!</h1>

                <p>Thank you for your purchase!</p>

                <button onClick={() => onOrderComplete()}>
                    Return to store
                </button>
            </div>
        );
    }

    return (
        <div className="container">
            <div className="topbar">
                <h1>Checkout</h1>

                <button onClick={() => onBackToStore()}>
                    Return to store
                </button>
            </div>

            <div className="section">
                <h2>Summary</h2>

                {cart.map((p, i) => (
                    <p key={i}>
                        {p.name} — {p.price} PLN
                    </p>
                ))}

                <h3>Total: {totalPrice()} PLN</h3>
            </div>

            <div className="section">
                <h2>Payment Information</h2>

                <input
                    placeholder="Name and Surname"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                />

                <br /><br />

                <input
                    placeholder="Address"
                    value={address}
                    onChange={(e) => setAddress(e.target.value)}
                />

                <br /><br />

                <button onClick={handlePay}>
                    Pay
                </button>
            </div>
        </div>
    );
}

export default Checkout;