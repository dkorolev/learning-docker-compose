import http.server
import os
import signal
import sys
import threading
import time

total_n = None

lock = threading.Lock()
ips = []
endpoints = []
named_endpoints = []

class Routes(http.server.SimpleHTTPRequestHandler):
  def log_message(self, format, *args):
    pass

  def do_GET(self):
    global lock, ips, endpoints, named_endpoints
    if self.path == "/healthz":
      self.send_response(200)
      self.end_headers()
    elif self.path == "/quit":
      self.send_response(200)
      self.end_headers()
      print("\nShutting down because '/quit'.", flush=True)
      threading.Thread(target=self.server.shutdown).start()
    elif self.path == "/cluster":
      with lock:
        if len(named_endpoints) == total_n:
          print(f"Returning the proper cluster setup to {self.client_address[0]}", flush=True)
          res = ",".join(named_endpoints)
        else:
          print(f"Cluster not ready, requested by {self.client_address[0]}", flush=True)
          res = ""
      self.send_response(200)
      self.end_headers()
      self.wfile.write((f"{res}\n").encode("utf-8"))
    elif self.path == "/ips":
      with lock:
        if len(ips) == total_n:
          print(f"Returning the proper set of IPs to {self.client_address[0]}", flush=True)
          res = " ".join(ips)
        else:
          print(f"IPs not ready, requested by {self.client_address[0]}", flush=True)
          res = ""
      self.send_response(200)
      self.end_headers()
      self.wfile.write((f"{res}\n").encode("utf-8"))
    elif self.path == "/endpoints":
      with lock:
        if len(endpoints) == total_n:
          print(f"Returning the proper set of endpoints to {self.client_address[0]}", flush=True)
          res = ",".join(endpoints)
        else:
          print(f"Endpoints not ready, requested by {self.client_address[0]}", flush=True)
          res = ""
      self.send_response(200)
      self.end_headers()
      self.wfile.write((f"{res}\n").encode("utf-8"))
    else:
      self.send_response(200)
      self.end_headers()
      self.wfile.write(b"Hey, did you mean to GET '/cluster'\n")

  def do_POST(self):
    global lock, ips, endpoints, named_endpoints
    if self.path == "/name_me":
      ip = self.rfile.read(int(self.headers.get('Content-Length', 0))).decode('utf-8')
      with lock:
        idx = len(ips)
        ips.append(ip)
        # This is for the client, `etcdctl --endpoints=...`.
        endpoints.append(f"http://{ip}:2380")
        # This is for the very setup of `etcd`.
        # Should be something like:
        # etcd-0=http://etcd-0:2380,etcd-1=http://etcd-1:2380,etcd-2=http://etcd-2:2380 
        named_endpoints.append(f"etcd-{idx}=http://{ip}:2380")
      print(f"Registered {ip} at index {idx}", flush=True)
      if len(named_endpoints) == total_n:
        print(f"We have the full house now!", flush=True)
      self.send_response(200)
      self.end_headers()
      self.wfile.write((f"etcd-{idx}\n").encode("utf-8"))

    else:
      self.send_response(200)
      self.end_headers()
      self.wfile.write(b"Hey, did you mean to POST to '/name_me'?\n")

if __name__ == "__main__":
  def handle_shutdown(signum, frame):
    print("\nShutting down by a signal.", flush=True)
    sys.exit(0)

  signal.signal(signal.SIGINT, handle_shutdown)
  signal.signal(signal.SIGQUIT, handle_shutdown)
  signal.signal(signal.SIGTERM, handle_shutdown)

  try:
    total_n = int(os.getenv('N'))
  except:
    total_n = 5
  print(f"TOTAL_N={total_n}", flush=True)
  
  server = http.server.ThreadingHTTPServer(("0.0.0.0", 8888), Routes)
  print("Indexer up on port 8888.", flush=True)
  server.serve_forever()
