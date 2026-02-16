#!/usr/bin/env python3
"""Minimal HTTP server to serve proxy.pac for macOS auto-proxy configuration.

macOS sandboxed apps (Safari, etc.) cannot read file:// PAC URLs.
This server makes the PAC file available via http://127.0.0.1:8053/proxy.pac.
"""
import http.server
import os
import signal
import sys

PORT = int(os.environ.get('MAPLE_PAC_PORT', '8053'))
PAC_DIR = os.path.dirname(os.path.abspath(__file__))
PAC_FILE = os.path.join(PAC_DIR, 'proxy.pac')


class PACHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path in ('/', '/proxy.pac'):
            try:
                with open(PAC_FILE, 'rb') as f:
                    content = f.read()
                self.send_response(200)
                self.send_header('Content-Type', 'application/x-ns-proxy-autoconfig')
                self.send_header('Content-Length', str(len(content)))
                self.end_headers()
                self.wfile.write(content)
            except FileNotFoundError:
                self.send_error(404, 'proxy.pac not found')
        else:
            self.send_error(404)

    def log_message(self, format, *args):
        pass  # Suppress request logs


def main():
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    server = http.server.HTTPServer(('127.0.0.1', PORT), PACHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == '__main__':
    main()
