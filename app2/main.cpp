#include <a.hpp>
#include <b.hpp>

#include <cstdio>

int main() {
  printf("Hello from MyApp2\n");

  printf(liba::function_a());
  printf(libb::function_b());
  printf(liba::function_c());
  printf(libd::function_d());
}
