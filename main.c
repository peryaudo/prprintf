#include <unistd.h>

int prsnprintf(char *str, int n, char *format, ...);

int main(int argc, char *argv[]) {
	char s[256];
	int n;
	n = prsnprintf(s, 256, "%x%s%d%c\n", 114514810, "foo bar baz", 810, 0x41);
	write(STDOUT_FILENO, s, n);
}
