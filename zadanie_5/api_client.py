# zawiera definicje narzędzi, które chatbot może wykorzystać do uzyskania informacji
import json
import requests



RESTAURANT_API_URL = "http://localhost:5000"
NO_PARAMS = {"type": "object", "properties": {}, "required": []}

 
TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "get_restaurant_info",
            "description": "Returns the restaurant's name and description.",
            "parameters": NO_PARAMS,
        },
    },
    {
        "type": "function",
        "function": {
            "name": "get_hours",
            "description": "Returns the restaurant's opening hours.",
            "parameters": NO_PARAMS,
        },
    },
    {
        "type": "function",
        "function": {
            "name": "get_menu",
            "description": (
                "Returns the full menu with prices, ingredients and allergens. "
                "Use when the customer asks for the whole menu or you need to compare items."
            ),
            "parameters": NO_PARAMS,
        },
    },
    {
        "type": "function",
        "function": {
            "name": "get_menu_category",
            "description": (
                "Returns one menu category with prices, ingredients and allergens. "
                "Categories: 'soups', 'main courses', 'desserts', 'drinks'. "
                "Use when the customer asks about a specific category."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "category": {
                        "type": "string",
                        "description": "category name, e.g. 'soups', 'desserts', 'drinks'",
                    }
                },
                "required": ["category"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "get_dish_details",
            "description": (
                "Returns details of a single dish: price, ingredients and allergens. "
                "Use when the customer asks about allergens, ingredients or modifications "
                "of a specific dish."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "name": {
                        "type": "string",
                        "description": "dish name, e.g. 'burger', 'tomato soup', 'apple pie'",
                    }
                },
                "required": ["name"],
            },
        },
    },
]



# helper HTTP GET do Flask API
def _fetch(path: str) -> dict | list:
    try:
        r = requests.get(f"{RESTAURANT_API_URL}{path}", timeout=5)
    except requests.exceptions.ConnectionError:
        return {"ERR": "can't connect to restaurant server (is Flask running?)"}
    except Exception as e:
        return {"ERR": str(e)}
    
    if r.status_code == 404:
        try:
            return r.json()
        except ValueError:
            return {"ERR": f"not found: {path}"}
    
    try:
        r.raise_for_status()
    except requests.exceptions.HTTPError as e:
        return {"ERR": f"API returned error: {e.response.status_code}"}
    
    return r.json()

def execute_tool(name: str, args: dict) -> str:
    if name == "get_restaurant_info":
        result = _fetch("/info")
    elif name == "get_hours":
        result = _fetch("/hours")
    elif name == "get_menu":
        result = _fetch("/menu")
    elif name == "get_menu_category":
        kategoria = args.get("kategoria", "")
        result = _fetch(f"/menu/{requests.utils.quote(kategoria)}")
    elif name == "get_dish_details":
        nazwa = args.get("nazwa", "")
        result = _fetch(f"/menu/danie/{requests.utils.quote(nazwa)}")
    else:
        result = {"ERR": f"unknown tool: {name}"}
 
    return json.dumps(result, ensure_ascii=False, indent=2)