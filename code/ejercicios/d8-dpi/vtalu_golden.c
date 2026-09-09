/* TODO(exercise d8-dpi): the VTALU reference model, in C.
 *
 * The testbench is the whole one from the DPI section, and the scoreboard does
 * NOT predict in SystemVerilog: it calls this file. Three operations come
 * done -- they are the pattern -- and two are missing.
 *
 * The checker runs three times:
 *
 *   1. healthy DUT against your model  -> it has to close at 0 UVM_ERROR
 *   2. MUTATED DUT (VTALU_BUG=1)       -> the scoreboard has to scream, which is
 *                                         what proves your model is really the
 *                                         one being asked
 *   3. your model with +GOLDEN_BUG     -> it has to scream too: a scoreboard
 *                                         that never saw an error is not tested
 *
 * The `extern "C"` guard is not decoration: Verilator hands user sources to the
 * C++ compiler, and without it the symbol gets mangled and the link fails with
 * an undefined reference to a function that is obviously there.
 */
#include <svdpi.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Same opcodes as operation_t in vtalu_pkg.sv. Keeping the two in sync by hand
 * is the tax of DPI, and it is the first thing to check when every comparison
 * fails at once. */
enum { NO_OP = 0, ADD_OP = 1, SUB_OP = 2, AND_OP = 3, XOR_OP = 4, MUL_OP = 5, RST_OP = 7 };

static int mutar = 0;

void vtalu_golden_bug(int on) { mutar = on; }

/* op, a and b arrive as SystemVerilog `int` (32-bit signed). The result goes
 * back as the return value and the borrow through a pointer, which is how an
 * `output int` argument crosses the boundary. */
int vtalu_golden(int op, int a, int b, int *ovf) {
   int r;

   a &= 0xff;
   b &= 0xff;
   *ovf = 0;

   switch (op) {
      case ADD_OP: r = a + b; break;

      /* TODO 1: the subtraction. Two halves, and the second one is the one that
       * gets forgotten: 8-bit operands into a 16-bit result, so a - b wraps, and
       * the BORROW --a < b-- is the other half of the answer the scoreboard
       * compares. It goes out through *ovf. */
      case SUB_OP: r = 0; break;

      case AND_OP: r = a & b; break;
      case XOR_OP: r = a ^ b; break;

      /* TODO 2: the multiplication, and the mutation that proves the path is
       * alive. With mutar at 0 it is the full product; with mutar at 1 it has to
       * LIE -- truncating it to 8 bits is enough. Without that, +GOLDEN_BUG
       * changes nothing and the checker cannot tell your model from a
       * scoreboard comparing against itself. */
      case MUL_OP: r = 0; break;

      default:     r = 0; break;   /* no_op and rst_op do not answer */
   }

   return r & 0xffff;
}

#ifdef __cplusplus
}
#endif
