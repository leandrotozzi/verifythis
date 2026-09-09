// Tipycal TB:
// -----------
//  * Functional Coverage
//  * Self Checking
//  * Constrained Random Stimulus

// Why is this bad?
//  * No modularity (everything in a single file)
//  * Almost nothing here can be reused
module top;

   typedef enum bit[2:0] {no_op  = 3'b000,
                          add_op = 3'b001,
                          sub_op = 3'b010,
                          and_op = 3'b011,
                          xor_op = 3'b100,
                          mul_op = 3'b101,
                          // TODO(exercise 1): shr_op = 3'b110 is missing
                          rst_op = 3'b111} operation_t;
   byte         unsigned        A;
   byte         unsigned        B;
   bit          clk;
   bit          reset_n;
   wire [2:0]   op;
   bit          start;
   wire         done;
   wire [15:0]  result;
   wire         ovf;
   operation_t  op_set;

   assign op = op_set;

   vtalu DUT (.A, .B, .clk, .op, .reset_n, .start, .done, .ovf, .result);

   //op_cov: make sure every operation, and every interaction between them, is covered
   covergroup op_cov;
      coverpoint op_set {
         bins single_cycle[] = {[add_op : xor_op], rst_op,no_op};
         // TODO(exercise 1): shr_op is one-cycle too, and the range
         // [add_op:xor_op] only reaches 3'b100: it does not cover it
         bins multi_cycle = {mul_op};

         // => are transitional coverage. From => To
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

   // Check the corners where the inputs are all 0s or all 1s
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

   initial begin
      clk = 0;
      forever begin
         #10;
         clk = ~clk;
      end
   end

   op_cov oc;
   zeros_or_ones_on_ops c_00_FF;

   initial begin : coverage
      oc = new();
      c_00_FF = new();

      forever begin @(negedge clk);
         oc.sample();
         c_00_FF.sample();
      end
   end : coverage

   function operation_t get_op();
      bit [2:0] op_choice;
      op_choice = $random;
      case (op_choice)
        3'b000 : return no_op;
        3'b001 : return add_op;
        3'b010 : return sub_op;
        3'b011 : return and_op;
        3'b100 : return xor_op;
        3'b101 : return mul_op;
        3'b110 : return rst_op;   // TODO(ejercicio 1): que devuelva shr_op
        3'b111 : return rst_op;
      endcase // case (op_choice)
   endfunction : get_op

   function byte get_data();
      // This is how the random gets biased
      bit [1:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 2'b00)
        return 8'h00;
      else if (zero_ones == 2'b11)
        return 8'hFF;
      else
        return $random;
   endfunction : get_data

   // Scoreboard loop: checks that everything came out right
   always @(posedge done) begin : scoreboard
      shortint predicted_result;
      bit      predicted_ovf;
      #1;
      case (op_set)
        add_op: predicted_result = A + B;
        sub_op: predicted_result = A - B;
        and_op: predicted_result = A & B;
        xor_op: predicted_result = A ^ B;
        mul_op: predicted_result = A * B;
        // TODO(exercise 1): the shr_op case is missing
      endcase // case (op_set)

      // ovf belongs to sub and to nobody else: with 8-bit inputs and a 16-bit
      // output, neither the addition nor the multiplication can overflow.
      predicted_ovf = (op_set == sub_op) && (A < B);

      if ((op_set != no_op) && (op_set != rst_op)) begin
        if (op == 3'b110) shifts++;
        if (predicted_result != result || predicted_ovf != ovf)
          $error ("FAILED: A: %0h  B: %0h  op: %s result: %0h ovf: %0b",
                  A, B, op_set.name(), result, ovf);
      end

   end : scoreboard

   // --- exercise checker (you do not need to touch this) ---------------------
   // A $error in Verilator aborts the simulation, so a result that does not
   // match shows up on its own: the only thing to count are the shifts.
   int shifts = 0;

   final begin
      if (shifts == 0)
        $display("EXERCISE INCOMPLETE: the TB never sent a shift (look at get_op)");
      else
        $display("EXERCISE OK: %0d shifts checked, 0 errors", shifts);
   end

   // Randomize the stimulus
   // get_op and get_data are Constrained Random Data
   // The point of CRD is to build values that are random but legal
   initial begin : tester
      reset_n = 1'b0;
      @(negedge clk);
      @(negedge clk);
      reset_n = 1'b1;
      start = 1'b0;
      repeat (1000) begin
         @(negedge clk);
         op_set = get_op();
         A = get_data();
         B = get_data();
         start = 1'b1;
         case (op_set) // handle the start signal
           no_op: begin
              @(posedge clk);
              start = 1'b0;
           end
           rst_op: begin
              reset_n = 1'b0;
              start = 1'b0;
              @(negedge clk);
              reset_n = 1'b1;
           end
           default: begin
              wait(done);
              start = 1'b0;
           end
         endcase // case (op_set)
      end
      $finish;
   end : tester
endmodule : top