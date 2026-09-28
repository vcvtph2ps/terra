#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main() {
  int pid = fork();

  if (pid == 0) {
    printf("Hello, child!\n");
    exit(1);
  } else {
    printf("Hello, parent\nchild_pid=%d\n", pid);
  }

  while (1)
    ;

  return 0;
}
