# wymaga Ollama z zainstalowanym modelem; instalacja zależności pip install -r requirements.txt
import ollama
from pathlib import Path
import sys
import json



MODEL_NAME = "llama3"
SYSTEM_PROMPT_FILE = "system_prompt.txt"
CONFIG_FILE = "config.json"



def load_system_prompt(path: str) -> str:
    prompt_file = Path(path)
    if not prompt_file.exists():
        raise FileNotFoundError(path)

    return prompt_file.read_text(encoding="utf-8").strip()

def load_config(path: str) -> dict:
    config_file = Path(path)
    if not config_file.exists():
        raise FileNotFoundError(path)
    
    return json.loads(config_file.read_text(encoding="utf-8"))

def build_complete_prompt(system_prompt: str, config: dict) -> str:
        return system_prompt+ f"\n\nDANE RESTAURACJI:\n{json.dumps(config, ensure_ascii=False, indent=2)}"

def chat(messages: list[dict], system_prompt: str) -> str:
    try:
        response = ollama.chat(model=MODEL_NAME, messages=[{"role": "system", "content": system_prompt}] + messages)
        return response["message"]["content"]
    except ollama.ResponseError as e:
        return f"ERR: model returned error: {e.error}"
    except Exception as e:
        return f"ERR: failed to communicate with Ollama, make sure the server is running, details: {e}"

def main():
    print("Asystent restauracji 'Twin R Diner'")
    print("Wpisz 'exit' aby zakończyć")

    try:
        system_prompt = load_system_prompt(SYSTEM_PROMPT_FILE)
    except FileNotFoundError:
        print(f"ERR: can't find prompt file: {SYSTEM_PROMPT_FILE}")
        sys.exit(1)

    try:
        config = load_config(CONFIG_FILE)
    except FileNotFoundError:
        print(f"ERR: can't find config file: {CONFIG_FILE}")
        sys.exit(1)

    complete_prompt = build_complete_prompt(system_prompt, config)

    history: list[dict] = []

    while True:
        try:
            user_input = input("\nTy: ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nDo widzenia!")
            break

        if not user_input:
            continue

        if user_input.lower() == "exit":
            print("\nDo widzenia! Zapraszamy ponownie do Twin R Diner!")
            break

        history.append({"role": "user", "content": user_input})

        reply = chat(history, complete_prompt)
        print(f"\nAsystent: {reply}")

        history.append({"role": "assistant", "content": reply})



if __name__ == "__main__":
    main()