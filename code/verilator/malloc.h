// macOS no tiene <malloc.h>; uvm_dpi.h lo incluye igual. Todo lo que UVM usa de
// ahi (malloc/free) esta en <stdlib.h>, que tambien existe en Linux.
#include <stdlib.h>
