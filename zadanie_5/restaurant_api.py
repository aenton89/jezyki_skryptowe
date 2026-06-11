"""
Flask API, serwuje dane z config.json - chatbot odpytuje endpointy zamiast czytać plik bezpośrednio
endpointy:
  GET /info - nazwa i opis restauracji
  GET /hours - godziny otwarcia
  GET /menu - całe menu (ceny + składniki + alergeny)
  GET /menu/<category> - jedna kategoria (zupy, dania główne, desery, napoje)
  GET /menu/dish/<name> - jedno konkretne danie (wyszukiwanie po nazwie)
"""
from flask import Flask, jsonify, abort, request
from pathlib import Path
import json
from datetime import datetime, timedelta



CONFIG_FILE = "config.json"
QUEUE_BUFFER_MIN = 5
PER_EXTRA_ITEM_MIN = 3

app = Flask(__name__)



def load_config() -> dict:
    path = Path(CONFIG_FILE)
    if not path.exists():
        raise FileNotFoundError(f"missing file: {CONFIG_FILE}")
    return json.loads(path.read_text(encoding="utf-8"))


# /info - nazwa i opis
@app.route("/info", methods=["GET"])
def get_info():
    config = load_config()
    return jsonify({
        "name": config.get("name"),
        "description": config.get("description"),
    })

# /hours - godziny otwarcia
@app.route("/hours", methods=["GET"])
def get_hours():
    config = load_config()
    return jsonify(config.get("hours", {}))

# /menu - całe menu
@app.route("/menu", methods=["GET"])
def get_menu():
    config = load_config()
    return jsonify(config.get("menu", {}))

# /menu/<category> - np. /menu/zupy, /menu/desery
@app.route("/menu/<string:category>", methods=["GET"])
def get_category(category: str):
    config = load_config()
    menu = config.get("menu", {})

    for key, value in menu.items():
        if key.lower() == category.lower():
            return jsonify(value)

    abort(404, description=f"no such category '{category}', "f"available: {list(menu.keys())}")

# helper zwraca płaski słownik {nazwa_dania: dane} dla wszystkich dań w menu, niezależnie od kategorii
def _flatten_menu(menu: dict) -> dict[str, dict]:
    flat: dict[str, dict] = {}
    for category, dishes in menu.items():
        for name, data in dishes.items():
            if isinstance(data, dict) and "price" in data:
                flat[name.lower()] = {"category": category, "name": name, **data}
            elif isinstance(data, dict):
                # handle nested drinks
                for subname, subdata in data.items():
                    if isinstance(subdata, dict) and "price" in subdata:
                        flat[subname.lower()] = {
                            "category": f"{category} / {name}",
                            "name": subname,
                            **subdata,
                        }
    return flat

# /menu/dish/<name> - np. /menu/dish/burger
@app.route("/menu/dish/<string:name>", methods=["GET"])
def get_dish(name: str):
    config = load_config()
    flat = _flatten_menu(config.get("menu", {}))

    dish = flat.get(name.lower())
    if dish:
        return jsonify(dish)

    # spróbuj częściowe dopasowanie
    matches = [v for k, v in flat.items() if name.lower() in k]
    if len(matches) == 1:
        return jsonify(matches[0])
    if len(matches) > 1:
        return jsonify({
            "matches": [m["name"] for m in matches],
            "info": "multiple dishes matched - please provide a more specific name"
        }), 300

    abort(404, description=f"dish '{name}' not found")

@app.route("/order/estimate", methods=["POST"])
def estimate_order():
    config = load_config()
    flat = _flatten_menu(config.get("menu", {}))

    prep = config.get("prep minutes", {})
    if not prep:
        abort(500, description="prep minutes is not configured in config.json")

    payload = request.get_json(silent=True) or {}
    names = payload.get("dishes", [])
    if not isinstance(names, list) or not names:
        abort(400, description="provide a non-empty 'dishes' list")

    items, not_found, times = [], [], []
    for raw in names:
        dish = flat.get(str(raw).lower())
        if not dish:
            matches = [v for k, v in flat.items() if str(raw).lower() in k]
            dish = matches[0] if len(matches) == 1 else None
        if not dish:
            not_found.append(raw)
            continue
        
        top_category = dish["category"].split(" / ")[0]
        minutes = prep.get(top_category)
        if minutes is None:
            abort(500, description=f"no prep time configured for category '{top_category}'")
        
        items.append({"name": dish["name"], "category": top_category, "prep minutes": minutes})
        times.append(minutes)

    if not times:
        return jsonify({"items": [], "not_found": not_found, "info": "none of the dishes were found"}), 404

    estimate = max(times) + PER_EXTRA_ITEM_MIN * (len(times) - 1) + QUEUE_BUFFER_MIN

    return jsonify({
        "items": items,
        "estimated_minutes": estimate,
        "message": f"Your order will be ready in about {estimate} minutes.",
        "not_found": not_found,
    })



# obsługa błędów
@app.errorhandler(404)
def not_found(e):
    return jsonify({"error": str(e)}), 404


@app.errorhandler(500)
def server_error(e):
    return jsonify({"error": str(e)}), 500

@app.errorhandler(400)
def bad_request(e):
    return jsonify({"error": str(e)}), 400



if __name__ == "__main__":
    app.run(port=5000, debug=True)