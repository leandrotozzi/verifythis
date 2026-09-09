class coverage;

   virtual vtalu_bfm bfm;

   byte         unsigned        A;
   byte         unsigned        B;
   operation_t  op_set;

   covergroup op_cov;

      coverpoint op_set {
         bins single_cycle[] = {[add_op : xor_op], rst_op,no_op};
         bins multi_cycle = {mul_op};

         // Transition bins. Verilator 5.052 does NOT implement them yet: any form
         // with "=>" or "[* n]" aborts with an Internal Error. Minimal repro in
         // code/verilator/repro-cg-transition.sv. They stay because they are part
         // of the topic; when Verilator supports them, drop the ifndef, nothing else.
`ifndef VERILATOR
         bins opn_rst[] = ([add_op:mul_op] => rst_op);
         bins rst_opn[] = (rst_op => [add_op:mul_op]);

         bins sngl_mul[] = ([add_op:xor_op],no_op => mul_op);
         bins mul_sngl[] = (mul_op => [add_op:xor_op], no_op);

         bins twoops[] = ([add_op:mul_op] [* 2]);
         bins manymult = (mul_op [* 3:5]);
`endif

      }

   endgroup

   covergroup zeros_or_ones_on_ops;

      all_ops : coverpoint op_set {
         ignore_bins null_ops = {rst_op, no_op};}

      a_leg: coverpoint A {
         bins zeros = {8'h00};
         bins others= {[8'h01:8'hFE]};
         bins ones  = {8'hFF};
      }

      b_leg: coverpoint B {
         bins zeros = {8'h00};
         bins others= {[8'h01:8'hFE]};
         bins ones  = {8'hFF};
      }
      // VTALU rev2: the borrow of the subtraction, the row of the plan that the
      // scoreboard can only close by looking at TWO outputs. Without this bin, a
      // subtraction that never went negative looks exactly like one that did.
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

  // cb: sampling
  // In a class, we don't need to declare variables to hold the covergroups, but we do need
  // to call a constructor to create them.
   function new (virtual vtalu_bfm b);
     op_cov = new();
     zeros_or_ones_on_ops = new();
     bfm = b;
   endfunction : new

   task execute();
      forever begin  : sampling_block
         @(negedge bfm.clk);
         A = bfm.A;
         B = bfm.B;
         op_set = bfm.op_set;
         op_cov.sample();
         zeros_or_ones_on_ops.sample();
      end : sampling_block
   endtask : execute
  // cb: end

endclass : coverage