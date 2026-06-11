# wymaga Ollama z zainstalowanym modelem; instalacja zależności pip install -r requirements.txt
import ollama
from pathlib import Path
import sys
import json
from api_client import TOOLS, execute_tool



MODEL_NAME = "llama3.1"
SYSTEM_PROMPT_FILE = "system_prompt.txt"



def load_system_prompt(path: str) -> str:
    prompt_file = Path(path)
    if not prompt_file.exists():
        raise FileNotFoundError(path)

    return prompt_file.read_text(encoding="utf-8").strip()

# gdy model zwróci tool_call wykonuje to narzędzi, dokłada wynik do historii i ponownie pyta model, aż ten odpowie normalną wiadomością
def chat(messages: list[dict], system_prompt: str) -> str:
    while True:
        try:
            response = ollama.chat(
                model=MODEL_NAME, 
                messages=[{"role": "system", "content": system_prompt}] + messages, 
                tools=TOOLS
            )
        except ollama.ResponseError as e:
            return f"ERR: model returned error: {e.error}"
        except Exception as e:
            return f"ERR: failed to communicate with Ollama, make sure the server is running, details: {e}"

        msg = response["message"]
        # print(f"[debug] response keys: {response.keys()}")
        # print(f"[debug] whole answer: {response}")
        # print(f"[debug] tool calls: {msg.get('tool_calls')}")
        # print(f"[debug] content: {repr(msg.get('content'))}")

        if msg.get("tool_calls"):
            messages.append({
                "role": "assistant", 
                "content": msg.get("content", ""),
                "tool_calls": msg["tool_calls"],
            })

            for tool_call in msg["tool_calls"]:
                name = tool_call["function"]["name"]
                args = tool_call["function"].get("arguments", {})

                # print(f"[debug] tool call: {name}({args})")
                result = execute_tool(name, args)

                messages.append({"role": "tool", "content": result})
            
            continue
        
        return msg.get("content", "")

def main():
    print("Twin R Diner - restaurant assistant")
    print("Type 'exit' to quit")

    try:
        system_prompt = load_system_prompt(SYSTEM_PROMPT_FILE)
    except FileNotFoundError:
        print(f"ERR: can't find prompt file: {SYSTEM_PROMPT_FILE}")
        sys.exit(1)

    history: list[dict] = []

    while True:
        try:
            user_input = input("\nYou: ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nGoodbye!")
            break

        if not user_input:
            continue

        if user_input.lower() == "exit":
            print("\nGoodbye! Come back soon to Twin R Diner!")
            break

        history.append({"role": "user", "content": user_input})

        reply = chat(history, system_prompt)
        print(f"\nAssistant: {reply}")

        history.append({"role": "assistant", "content": reply})



if __name__ == "__main__":
    main()