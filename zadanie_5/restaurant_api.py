"""
Flask API, serwuje dane z config.json - chatbot odpytuje endpointy zamiast czytać plik bezpośrednio
endpointy:
  GET /info - nazwa i opis restauracji
  GET /hours - godziny otwarcia
  GET /menu - całe menu (ceny + składniki + alergeny)
  GET /menu/<category> - jedna kategoria (zupy, dania główne, desery, napoje)
  GET /menu/dish/<name> - jedno konkretne danie (wyszukiwanie po nazwie)
"""
from flask import Flask, jsonify, abort
from pathlib import Path
import json



CONFIG_FILE = "config.json"

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



# obsługa błędów
@app.errorhandler(404)
def not_found(e):
    return jsonify({"error": str(e)}), 404


@app.errorhandler(500)
def server_error(e):
    return jsonify({"error": str(e)}), 500



if __name__ == "__main__":
    app.run(port=5000, debug=True)