import requests

HTTP_REQUEST = "http://localhost:11434/api/generate"
MODEL = "llama3.2"


def http_post(url, data):
    response = requests.post(url, json=data)
    response.raise_for_status()

    return response.json()


def instruction_failed():
    data = {
        "model": MODEL,
        "prompt": "Diga 9 animais que começam com A e pare na primeira palavra",
        "stream": False,
    }

    print(http_post(HTTP_REQUEST, data))


if __name__ == "__main__":
    instruction_failed()
