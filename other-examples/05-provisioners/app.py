#!/usr/bin/env python3
import http.server
import socketserver

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(b'<h1>Deployed with Provisioners!</h1>')

with socketserver.TCPServer(("", 8000), Handler) as httpd:
    print("Server running on port 8000")
    httpd.serve_forever()
