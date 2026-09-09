// Minimal repro: Verilator 5.052 does not implement transition bins.
//
//   $ verilator --binary --timing --coverage -DT1 repro-cg-transition.sv
//
// T1  (add_op => rst_op)          %Error: Internal Error: ... type 'ENUMITEMREF'
// T2  ([add_op:mul_op] => rst_op) %Error: Internal Error: ... type 'ENUMITEMREF'
// T3  ([3'b001:3'b100] => 3'b111) %Error: Internal Error: Null item passed to setOp1p
// T4  ([add_op:mul_op] [* 2])     %Error: Transition set without items
//
// With no -D at all it compiles and runs: the value bins get measured and
// verilator_coverage reports the "covergroup" line.
//
// What 5.052 still does not do:
//   - transition bins (above)
//   - binsof / intersect / explicit bins in a cross: %Warning-COVERIGN, it
//     ignores them and carries on
//   - type-wide get_coverage(): always returns 0, get_inst_coverage() has to
//     be used instead
//   - $stop eats coverage.dat: the run has to end with $finish
module top;
  typedef enum bit [2:0] {
    no_op = 3'b000, add_op = 3'b001, sub_op = 3'b010, and_op = 3'b011,
    xor_op = 3'b100, mul_op = 3'b101, rst_op = 3'b111
  } operation_t;

  operation_t op;

  covergroup cg;
    coverpoint op {
      bins single[] = {[add_op:xor_op], rst_op, no_op};
`ifdef T1
      bins t_enum[]  = (add_op => rst_op);
`endif
`ifdef T2
      bins t_range[] = ([add_op:mul_op] => rst_op);
`endif
`ifdef T3
      bins t_num[]   = ([3'b001:3'b100] => 3'b111);
`endif
`ifdef T4
      bins t_rep[]   = ([add_op:mul_op] [* 2]);
`endif
    }
  endgroup

  cg c = new();

  initial begin
    for (int i = 0; i < 8; i++) begin
      op = operation_t'(i[2:0]);
      c.sample();
      #1;
    end
    // type-wide gives 0.00, the instance one gives the real number
    $display("type=%0.2f inst=%0.2f", cg::get_coverage(), c.get_inst_coverage());
    $finish;
  end
endmodule
