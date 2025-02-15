#include <csignal>
#include <iostream>

#include "pls.h"

PLS_INCLUDE_HEADER_ONLY_CURRENT();

#include "bricks/dflags/dflags.h"
#include "bricks/sync/waitable_atomic.h"
#include "blocks/http/api.h"

DEFINE_uint16(port, 5000, "The port to use.");

void handle_signal(int signal) {
  std::cout << "Caught signal " << signal << std::endl;
  std::exit(signal);
}

int main(int argc, char** argv) {
  ParseDFlags(&argc, &argv);

  signal(SIGINT, handle_signal);
  signal(SIGTERM, handle_signal);
  signal(SIGQUIT, handle_signal);

  auto& http = HTTP(current::net::BarePort(FLAGS_port));

  current::WaitableAtomic<bool> die(false);

  auto scope = http.Register("/q", [&die](Request r) {
    r("dying\n");
    die.SetValue(true);
  });

  scope += http.Register("/", [&die](Request r) {
    r("sup?\n");
  });

  std::cout << "listening with 'sup?' on port " << FLAGS_port << std::endl;

  die.Wait();
}
