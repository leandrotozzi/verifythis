class coverage extends uvm_subscriber #(command_s);
   `uvm_component_utils(coverage)

   byte         unsigned        A;
   byte         unsigned        B;
   operation_t  op_set;

   covergroup op_cov;

      coverpoint op_set {
         bins single_cycle[] = {[add_op : xor_op], rst_op,no_op};
         bins multi_cycle = {mul_op};

         // Bins de transicion. Verilator 5.052 todavia NO los implementa: cualquier
         // forma con "=>" o "[* n]" aborta con un Internal Error. Repro minimo en
         // code/verilator/repro-cg-transition.sv. Quedan aca porque son parte del tema;
         // cuando Verilator los soporte, se borra el ifndef y nada mas.
`ifndef VERILATOR
         bins opn_rst[] = ([add_op:mul_op] => rst_op);
         bins rst_opn[] = (rst_op => [add_op:mul_op]);

         bins sngl_mul[] = ([add_op:xor_op],no_op => mul_op);
         bins mul_sngl[] = (mul_op => [add_op:xor_op], no_op);

         bins twoops[] = ([add_op:mul_op] [* 2]);
         bins manymult = (mul_op [* 3:5]);

         bins rstmulrst   = (rst_op => mul_op [=  2] => rst_op);
         bins rstmulrstim = (rst_op => mul_op [-> 2] => rst_op);
`endif

      }

   endgroup

   covergroup zeros_or_ones_on_ops;

      all_ops : coverpoint op_set {
         ignore_bins null_ops = {rst_op, no_op};}

      a_leg: coverpoint A {
         bins zeros = {'h00};
         bins others= {['h01:'hFE]};
         bins ones  = {'hFF};
      }

      b_leg: coverpoint B {
         bins zeros = {'h00};
         bins others= {['h01:'hFE]};
         bins ones  = {'hFF};
      }
      // rev2 del VTALU: el borrow de la resta, que es la fila del plan que el
      // scoreboard solo puede cerrar mirando DOS salidas. Sin este bin, una
      // resta que nunca dio negativa es indistinguible de una que si.
      borrow: coverpoint ((op_set == sub_op) && (A < B)) {
         bins hubo_borrow = {1};
         ignore_bins resto = {0};
      }


      op_00_FF:  cross a_leg, b_leg, all_ops {
         bins add_00 = binsof (all_ops) intersect {add_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins add_FF = binsof (all_ops) intersect {add_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins sub_00 = binsof (all_ops) intersect {sub_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins sub_FF = binsof (all_ops) intersect {sub_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins and_00 = binsof (all_ops) intersect {and_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins and_FF = binsof (all_ops) intersect {and_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins xor_00 = binsof (all_ops) intersect {xor_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins xor_FF = binsof (all_ops) intersect {xor_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins mul_00 = binsof (all_ops) intersect {mul_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins mul_FF = binsof (all_ops) intersect {mul_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins mul_max = binsof (all_ops) intersect {mul_op} &&
                        (binsof (a_leg.ones) && binsof (b_leg.ones));

         ignore_bins others_only =
                                  binsof(a_leg.others) && binsof(b_leg.others);

      }

endgroup


   function new (string name, uvm_component parent);
      super.new(name, parent);
      op_cov = new();
      zeros_or_ones_on_ops = new();
   endfunction : new

   function void write(command_s t);
         A = t.A;
         B = t.B;
         op_set = t.op;
         op_cov.sample();
         zeros_or_ones_on_ops.sample();
   endfunction : write

endclass : coverage

