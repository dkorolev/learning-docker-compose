#include "current/bricks/dflags/dflags.h"
#include "current/bricks/sync/waitable_atomic.h"
#include "current/blocks/http/api.h"

#include <csignal>

DEFINE_uint16(port, 5000, "The local port to listen on.");

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
  current::WaitableAtomic<bool> done(false);

  scope += http.Register("/", [](Request r) {
    r("Hello, World!\n");
  });

  scope += http.Register("/killkillkill", [&done](Request r) {
    r("OK\n");
    std::cout << "Shutting down." << std::endl;
    *done.MutableScopedAccessor() = true;
  });

  std::cout << "Hello World listening inside Docker on post " << FLAGS_port << '.' << std::endl;

  done.Wait([](bool done) { return done; });
  std::cout << "Terminated." << std::endl;
}
