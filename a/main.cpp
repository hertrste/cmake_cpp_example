#include <a.hpp>
#include <c.hpp>

namespace liba {

const char* function_a() { return "a"; }

const char* function_c() {
  auto c{libc::function_c()};
  return c;
}

}
