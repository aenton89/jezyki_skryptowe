# wymaga Ollama z zainstalowanym modelem; instalacja zależności pip install -r requirements.txt
import ollama
from pathlib import Path
import sys



MODEL_NAME = "llama3"
SYSTEM_PROMPT_FILE = "system_prompt.txt"



def load_system_prompt(path: str) -> str:
    prompt_file = Path(path)
    if not prompt_file.exists():
        raise FileNotFoundError(path)

    return prompt_file.read_text(encoding="utf-8").strip()

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

        reply = chat(history, system_prompt)
        print(f"\nAsystent: {reply}")

        history.append({"role": "assistant", "content": reply})



if __name__ == "__main__":
    main()