// macOS has no <malloc.h>; uvm_dpi.h includes it anyway. Everything UVM uses
// from there (malloc/free) is in <stdlib.h>, which exists on Linux too.
#include <stdlib.h>
