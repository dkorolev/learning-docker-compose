#include "current/bricks/dflags/dflags.h"
#include "current/bricks/sync/waitable_atomic.h"
#include "current/blocks/http/api.h"

#include <csignal>

DEFINE_uint16(port, 80, "The local port to listen on.");
DEFINE_int32(by, 1, "By which delta to increment.");
DEFINE_string(host, "http://add_service", "The host to call `/add/:a/${BY:-1}` to increment.");

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

  scope += http.Register("/inc", URLPathArgs::CountMask::One, [](Request r) {
    try {
      using current::ToString;
      std::cout << "Querying " << FLAGS_host + "/add/" + ToString(r.url_path_args[0]) + '/' << FLAGS_by << std::endl;
      r(HTTP(GET(FLAGS_host + "/add/" + ToString(r.url_path_args[0]) + '/' + ToString(FLAGS_by))).body);
      std::cout << "Success." << std::endl;
    } catch (current::Exception const&) {
      r("ERROR\n", HTTPResponseCode.InternalServerError);
      std::cout << "Failed." << std::endl;
    }
  });

  http.Join();
}
