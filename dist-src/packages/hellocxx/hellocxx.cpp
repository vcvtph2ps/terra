#include <print>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main() {
  std::print("Hello, libcxx! :3\n");
  while (1)
    ;
  return 0;
}
