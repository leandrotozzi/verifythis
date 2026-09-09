/* The VTALU reference model, in C. This is the whole point of the example:
 * the scoreboard does NOT predict in SystemVerilog -- it asks this file.
 *
 * Why it matters: for a DUT with real arithmetic -- a DSP, a codec, a crypto
 * engine -- the reference model already exists in C, written by the algorithm
 * team, and it is the thing the specification was signed off against.
 * Rewriting it in SystemVerilog means maintaining two models and debugging the
 * difference between them, which is not verification.
 *
 * Verilator compiles to C++, so this file is linked straight into the
 * simulation: no IPC, no socket, no FLI. One `import "DPI-C"` on the
 * SystemVerilog side (vtalu_pkg.sv) and one function call on this side.
 *
 * The `extern "C"` guard is not decoration: Verilator hands user sources to
 * the C++ compiler, and without it the symbol gets mangled and the link fails
 * with an undefined reference that names a function that is obviously there.
 */
#include <svdpi.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Same opcodes as operation_t in vtalu_pkg.sv. Keeping the two in sync by hand
 * is the tax of DPI, and it is the first thing to check when every comparison
 * fails at once. */
enum { NO_OP = 0, ADD_OP = 1, SUB_OP = 2, AND_OP = 3, XOR_OP = 4, MUL_OP = 5, RST_OP = 7 };

/* A deliberate mutation, switched on with +GOLDEN_BUG. A scoreboard that never
 * saw an error is not tested: this is what proves the DPI path is actually
 * wired, and it is the same idea as the +BUG=1 of the day 7 capstone. */
static int mutar = 0;

void vtalu_golden_bug(int on) { mutar = on; }

/* op, a and b arrive as SystemVerilog `int` (32-bit signed). The result goes
 * back as the return value and the borrow through a pointer, which is how an
 * `output int` argument crosses the boundary. */
// cb: the-golden
int vtalu_golden(int op, int a, int b, int *ovf) {
   int r;

   a &= 0xff;
   b &= 0xff;
   *ovf = 0;

   switch (op) {
      case ADD_OP: r = a + b; break;
      /* 8-bit operands into a 16-bit result: a - b wraps, and the borrow is
       * the second half of the answer the scoreboard has to check. */
      case SUB_OP: r = a - b; *ovf = (a < b); break;
      case AND_OP: r = a & b; break;
      case XOR_OP: r = a ^ b; break;
      case MUL_OP: r = mutar ? (a * b) & 0xff : a * b; break;
      default:     r = 0; break;   /* no_op and rst_op do not answer */
   }

   return r & 0xffff;
}
// cb: end

#ifdef __cplusplus
}
#endif
