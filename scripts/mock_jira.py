#!/usr/bin/env python3
"""
Simple mock JIRA HTTP server used for integration testing.
Provides deterministic responses for a couple of endpoints used by tests:
- GET /rest/api/3/issue/OK-1 -> 200 with JSON {"key": "OK-1"}
- GET /rest/api/3/issue/AUTH-1 -> 401 with plain text
- GET /health -> 200 OK (used to wait for readiness)

Run: python3 scripts/mock_jira.py --port 8765
"""
import argparse
from http.server import BaseHTTPRequestHandler, HTTPServer

class MockJiraHandler(BaseHTTPRequestHandler):
    def _send(self, code, body, content_type='application/json'):
        self.send_response(code)
        self.send_header('Content-Type', content_type)
        self.send_header('Content-Length', str(len(body.encode('utf-8'))))
        self.end_headers()
        self.wfile.write(body.encode('utf-8'))

    def do_GET(self):
        path = self.path
        if path.startswith('/rest/api/3/issue/OK-1'):
            self._send(200, '{"key":"OK-1"}')
            return
        if path.startswith('/rest/api/3/issue/AUTH-1'):
            self._send(401, 'Authentication failed', content_type='text/plain')
            return
        if path.startswith('/health'):
            self._send(200, 'OK', content_type='text/plain')
            return
        # default
        self._send(500, '{}')

    def log_message(self, format, *args):
        # reduce noise in CI logs
        print("[mock_jira] %s" % (format % args))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--port', type=int, default=8765)
    args = parser.parse_args()

    server = HTTPServer(('127.0.0.1', args.port), MockJiraHandler)
    print(f"Mock JIRA running on http://127.0.0.1:{args.port}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()

if __name__ == '__main__':
    main()
