import http.server
import os
import signal
import sys
import threading
import psutil

etcd_pid = None

class Routes(http.server.SimpleHTTPRequestHandler):
  def log_message(self, format, *args):
    pass

  def do_GET(self):
    if self.path == "/healthz":
      self.send_response(200)
      self.end_headers()
    elif self.path == "/stop":
      self.send_response(200)
      self.end_headers()
      print("\nShutting down because '/quit'.", flush=True)
      try:
        process = psutil.Process(etcd_pid)
        process.terminate()
      except psutil.NoSuchProcess:
        print("\nWhoa, no such process, it could be that `etcd` is already dead.", flush=True)
      threading.Thread(target=self.server.shutdown).start()
    else:
      self.send_response(200)
      self.end_headers()
      self.wfile.write(b"Hey, did you mean to get '/stop'?\n")

if __name__ == "__main__":
  def handle_shutdown(signum, frame):
    print("\nShutting down by a signal.", flush=True)
    sys.exit(0)

  signal.signal(signal.SIGINT, handle_shutdown)
  signal.signal(signal.SIGQUIT, handle_shutdown)
  signal.signal(signal.SIGTERM, handle_shutdown)

  try:
    etcd_pid = int(os.getenv('KILL_PID'))
    print(f"Kill `etc` PID: {etcd_pid}.", flush=True)
  except:
    process.exit(1)
  
  server = http.server.ThreadingHTTPServer(("0.0.0.0", 8888), Routes)
  print("Killer up on port 8888.", flush=True)
  server.serve_forever()
