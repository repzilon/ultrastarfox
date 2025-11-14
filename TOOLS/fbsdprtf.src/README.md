DOS and Windows lack a printf program.

``printf.c`` was taken directly from the FreeBSD source repository (and ported afterwards).

DJGPP (for DOS) provides a getopt implementation, so only requires ``printf.c``.
However, Windows does not, so ``getopt.*`` is needed. The implementation was taken from https://gist.github.com/superwills/5815344 and is of FreeBSD origin.
