#include <stdio.h>

int main() {
  printf("Hello, world!\n");
  printf("> ");
  fflush(stdout);

  char input[100];

  fgets(input, sizeof(input), stdin);

  printf("\ninput: %s", input);

  return 0;
}
