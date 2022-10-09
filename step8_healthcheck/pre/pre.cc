#include "current/bricks/dflags/dflags.h"
#include "current/bricks/sync/waitable_atomic.h"
#include "current/blocks/http/api.h"

#include <csignal>

DEFINE_uint16(port, 80, "The local port to listen on.");

void handle_signal(int code) {
  std::cerr << "\nReceived signal " << code << ", terminating.\n";
  std::exit(code);
}

int main(int argc, char** argv) {
  signal(SIGINT, handle_signal);
  signal(SIGTERM, handle_signal);

  ParseDFlags(&argc, &argv);

  auto& http = HTTP(current::net::BarePort(FLAGS_port));
  HTTPRoutesScope scope;

  auto const t0 = current::time::Now();
  bool reported_healthy_to_stdout = false;
  scope += http.Register("/healthz", [t0, &reported_healthy_to_stdout](Request r) {
    auto const t1 = current::time::Now();
    double const dt = 1e-6 * (t1 - t0).count();
    if (dt < 2) {
      std::cout << "Health check invoked " << std::setprecision(2) << dt << "s after start; too early." << std::endl;
      r("Wait.\n", HTTPResponseCode.InternalServerError);
    } else {
      if (!reported_healthy_to_stdout) {
        std::cout << "Health check passed." << std::endl;
        reported_healthy_to_stdout = true;
      }
      r("OK!\n");
    }
  });

  http.Join();
}
