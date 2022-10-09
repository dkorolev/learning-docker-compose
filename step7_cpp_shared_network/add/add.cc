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

  scope += http.Register("/add", URLPathArgs::CountMask::Two, [](Request r) {
    using current::FromString;
    using current::ToString;
    std::cout << "Queried /add/" << r.url_path_args[0] << '/' << r.url_path_args[1] << std::endl;
    r(ToString(FromString<int>(r.url_path_args[0]) + FromString<int>(r.url_path_args[1])) + '\n');
  });

  http.Join();
}
