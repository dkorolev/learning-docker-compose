import http.server
import os
import signal
import sys
import threading
import time

max_n = None
counter = 0
lock = threading.Lock()

class Routes(http.server.SimpleHTTPRequestHandler):
  def log_message(self, format, *args):
    pass

  def do_GET(self):
    if self.path == "/healthz":
      self.send_response(200)
      self.end_headers()
    elif self.path == "/quit":
      self.send_response(200)
      self.end_headers()
      print("\nShutting down because '/quit'.", flush=True)
      threading.Thread(target=self.server.shutdown).start()
    elif self.path == "/index":
      global counter
      with lock:
        counter += 1
        save_counter = counter
      self.send_response(200)
      self.end_headers()
      self.wfile.write((str(save_counter) + "\n").encode("utf-8"))
      if save_counter == max_n:
        print(f"\nShutting down because received N={max_n} requests to '/index'.", flush=True)
        threading.Thread(target=self.server.shutdown).start()
    else:
      self.send_response(200)
      self.end_headers()
      self.wfile.write(b"Hey, did you mean run get to '/index'?\n")

if __name__ == "__main__":
  def handle_shutdown(signum, frame):
    print("\nShutting down by a signal.", flush=True)
    sys.exit(0)

  signal.signal(signal.SIGINT, handle_shutdown)
  signal.signal(signal.SIGQUIT, handle_shutdown)
  signal.signal(signal.SIGTERM, handle_shutdown)

  for i in range(5, 0, -1):
    print(f"Sleeping before starting: {i}", flush=True)
    time.sleep(1)

  try:
    max_n = int(os.getenv('N'))
  except:
    max_n = 5
  print(f"MAX_N={max_n}", flush=True)
  
  server = http.server.ThreadingHTTPServer(("0.0.0.0", 8888), Routes)
  print("Indexer up on port 8888.", flush=True)
  server.serve_forever()
