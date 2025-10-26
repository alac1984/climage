import json

DUMMY_OK = {
    "ok": True,
    "url": "https://example.test/img/mock%2F.png",
    "width": 800,
    "height": 600,
    "size": 34567,
    "format": "png",
    "backend": "mock",
    "output": "html",
}

DUMMY_ERROR = {"ok": False, "error": "explanation string", "stage": "mock"}

if __name__ == "__main__":
    print(json.dumps(DUMMY_OK))
