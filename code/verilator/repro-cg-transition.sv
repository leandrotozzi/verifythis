// Repro minimo: Verilator 5.052 no implementa los bins de transicion.
//
//   $ verilator --binary --timing --coverage -DT1 repro-cg-transition.sv
//
// T1  (add_op => rst_op)          %Error: Internal Error: ... type 'ENUMITEMREF'
// T2  ([add_op:mul_op] => rst_op) %Error: Internal Error: ... type 'ENUMITEMREF'
// T3  ([3'b001:3'b100] => 3'b111) %Error: Internal Error: Null item passed to setOp1p
// T4  ([add_op:mul_op] [* 2])     %Error: Transition set without items
//
// Sin ningun -D compila y corre: los bins de valor se miden y verilator_coverage
// reporta la linea "covergroup".
//
// Lo que 5.052 todavia no hace:
//   - bins de transicion (arriba)
//   - binsof / intersect / bins explicitos en un cross: %Warning-COVERIGN, los
//     ignora y sigue
//   - get_coverage() type-wide: devuelve siempre 0, hay que usar
//     get_inst_coverage()
//   - $stop se come el coverage.dat: hay que terminar con $finish
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
    // type-wide da 0.00, la de instancia da el numero real
    $display("type=%0.2f inst=%0.2f", cg::get_coverage(), c.get_inst_coverage());
    $finish;
  end
endmodule
