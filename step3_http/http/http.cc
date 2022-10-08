#include "current/bricks/dflags/dflags.h"
#include "current/bricks/sync/waitable_atomic.h"
#include "current/blocks/http/api.h"

DEFINE_uint16(port, 5000, "The local port to listen on.");

int main(int argc, char** argv) {
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

  std::cout << "Hello World listening on http://localhost:" << FLAGS_port << '.' << std::endl;

  done.Wait([](bool done) { return done; });
  std::cout << "Terminated." << std::endl;
}
