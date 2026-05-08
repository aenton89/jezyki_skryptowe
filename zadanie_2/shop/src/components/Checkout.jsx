import { useState } from "react";



function Checkout({ cart, totalPrice, onBackToStore, onOrderComplete }) {
    const [firstName, setFirstName] = useState("");
    const [lastName, setLastName] = useState("");

    const [phone, setPhone] = useState("");

    const [city, setCity] = useState("");
    const [street, setStreet] = useState("");
    const [houseNumber, setHouseNumber] = useState("");
    const [postalCode, setPostalCode] = useState("");

    const [paid, setPaid] = useState(false);

    function validateText(text) {
        return /^[A-Za-zÀ-ÿĄąĆćĘęŁłŃńÓóŚśŹźŻż\s-]+$/.test(text);
    }

    function validatePhone(phone) {
        return /^[0-9]{9}$/.test(phone);
    }

    function validatePostalCode(code) {
        return /^[0-9]{2}-[0-9]{3}$/.test(code);
    }

    function validateHouseNumber(number) {
        return /^[0-9A-Za-z/]+$/.test(number);
    }

    function handlePay() {
        if (!firstName || !lastName || !phone || !city || !street || !houseNumber || !postalCode) {
            alert("Fill in all fields!");
            return;
        }
        if (!validateText(firstName)) {
            alert("Invalid name!");
            return;
        }
        if (!validateText(lastName)) {
            alert("Invalid surname!");
            return;
        }
        if (!validateText(city)) {
            alert("Invalid city!");
            return;
        }
        if (!validateText(street)) {
            alert("Invalid street!");
            return;
        }
        if (!validatePhone(phone)) {
            alert("Phone number must have 9 digits!");
            return;
        }
        if (!validatePostalCode(postalCode)) {
            alert("Postal code must have XX-XXX format!");
            return;
        }
        if (!validateHouseNumber(houseNumber)) {
            alert("Invalid house number!");
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

                <button onClick={onBackToStore}>
                    Back
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
                <h2>Customer Data</h2>

                <input
                    type="text"
                    placeholder="First Name"
                    value={firstName}
                    onChange={(e) => setFirstName(e.target.value)}
                />

                <br /><br />

                <input
                    type="text"
                    placeholder="Last Name"
                    value={lastName}
                    onChange={(e) => setLastName(e.target.value)}
                />

                <br /><br />

                <input
                    type="text"
                    placeholder="Phone Number"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                />

                <br /><br />

                <input
                    type="text"
                    placeholder="City"
                    value={city}
                    onChange={(e) => setCity(e.target.value)}
                />

                <br /><br />

                <input
                    type="text"
                    placeholder="Street"
                    value={street}
                    onChange={(e) => setStreet(e.target.value)}
                />

                <br /><br />

                <input
                    type="text"
                    placeholder="House Number"
                    value={houseNumber}
                    onChange={(e) => setHouseNumber(e.target.value)}
                />

                <br /><br />

                <input
                    type="text"
                    placeholder="Postal Code (XX-XXX)"
                    value={postalCode}
                    onChange={(e) => setPostalCode(e.target.value)}
                />

                <br /><br />

                <button onClick={handlePay}>
                    Pay {totalPrice()} PLN
                </button>
            </div>
        </div>
    );
}

export default Checkout;