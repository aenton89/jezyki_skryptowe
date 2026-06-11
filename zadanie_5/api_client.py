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
    {
        "type": "function",
        "function": {
            "name": "estimate_pickup_time",
            "description": (
                "Estimates how long the order will take and when it will be ready for "
                "pickup. Call this AFTER the customer confirms what they want. Pass the "
                "base dish names (e.g. 'tomato soup', not 'tomato soup without celery')."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "dishes": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "ordered dish names, e.g. ['burger', 'tomato soup']",
                    }
                },
                "required": ["dishes"],
            },
        },
    },
]



# helper HTTP do Flask API
def _request(method: str, path: str, payload: dict | None = None) -> dict | list:
    try:
        r = requests.request(method, f"{RESTAURANT_API_URL}{path}", json=payload, timeout=5)
    except requests.exceptions.ConnectionError:
        return {"ERR": "can't connect to restaurant server (is Flask running?)"}
    except Exception as e:
        return {"ERR": str(e)}

    if r.status_code in (400, 404):
        try:
            return r.json()
        except ValueError:
            return {"not_found": path}

    try:
        r.raise_for_status()
    except requests.exceptions.HTTPError as e:
        return {"ERR": f"API returned error: {e.response.status_code}"}

    return r.json()

def execute_tool(name: str, args: dict) -> str:
    if name == "get_restaurant_info":
        result = _request("GET", "/info")
    elif name == "get_hours":
        result = _request("GET", "/hours")
    elif name == "get_menu":
        result = _request("GET", "/menu")
    elif name == "get_menu_category":
        category = args.get("category", "")
        result = _request("GET", f"/menu/{requests.utils.quote(category)}")
    elif name == "get_dish_details":
        name = args.get("name", "")
        result = _request("GET", f"/menu/dish/{requests.utils.quote(name)}")
    elif name == "estimate_pickup_time":
        dishes = args.get("dishes", [])
        result = _request("POST", "/order/estimate", {"dishes": dishes})
    else:
        result = {"ERR": f"unknown tool: {name}"}
 
    return json.dumps(result, ensure_ascii=False, indent=2)