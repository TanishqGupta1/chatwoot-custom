#!/usr/bin/env python3
"""Tiny API to serve and save voice agent config."""
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import os

CONFIG_FILE = "/opt/chatwoot/voice-config/agents.json"

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith("/agents.json"):
            try:
                with open(CONFIG_FILE, "r") as f:
                    data = f.read()
            except FileNotFoundError:
                data = "{}"
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header("Cache-Control", "no-cache")
            self.end_headers()
            self.wfile.write(data.encode())
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        if self.path == "/save":
            content_length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(content_length)
            try:
                config = json.loads(body)
                # Validate: all keys and values should be strings
                if not isinstance(config, dict):
                    raise ValueError("Expected JSON object")
                for k, v in config.items():
                    if not isinstance(k, str) or not isinstance(v, str):
                        raise ValueError("Keys and values must be strings")

                with open(CONFIG_FILE, "w") as f:
                    json.dump(config, f, indent=2)

                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.send_header("Access-Control-Allow-Origin", "*")
                self.end_headers()
                self.wfile.write(json.dumps({"status": "ok"}).encode())
            except Exception as e:
                self.send_response(400)
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e)}).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, X-API-Token")
        self.end_headers()

    def log_message(self, format, *args):
        pass  # Silence logs

if __name__ == "__main__":
    server = HTTPServer(("127.0.0.1", 8086), Handler)
    print("Voice config API running on :8086")
    server.serve_forever()
