

* https://gist.github.com/mlafeldt/3885346


/* This is the original elf.h file from the GNU C Library; I only removed
   the inclusion of feature.h and added definitions of __BEGIN_DECLS and
   __END_DECLS as documented in
   https://cmd.inp.nsk.su/old/cmd2/manuals/gnudocs/gnudocs/libtool/libtool_36.html
   On macOS, simply copy the file to /usr/local/include/. 
   Mathias Lafeldt <mathias.lafeldt@gmail.com> */