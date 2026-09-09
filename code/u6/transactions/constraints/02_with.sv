// Constrained Random 2 -- inside, and randomize() with {}.
//
// The class constraint gives the bulk of the stimulus. The directed case is asked
// for at the point of use, without touching the class and without a new tester.
module top_with;

   typedef enum bit [2:0] {
      no_op  = 3'b000,
      add_op = 3'b001,
      sub_op = 3'b010,
      and_op = 3'b011,
      xor_op = 3'b100,
      mul_op = 3'b101,
      rst_op = 3'b111
   } operation_t;

   class comando;
      rand byte unsigned A;
      rand byte unsigned B;
      rand operation_t   op;

      constraint data {
         A dist {8'h00 :/ 1, [8'h01 : 8'hFE] :/ 2, 8'hFF :/ 1};
         B dist {8'h00 :/ 1, [8'h01 : 8'hFE] :/ 2, 8'hFF :/ 1};
      }

      // inside is a set of legal values. Without it the random also asks for
      // no_op and rst_op, which compute nothing.
      constraint utiles {op inside {add_op, and_op, xor_op, mul_op};}
   endclass

   localparam int N = 400;

   initial begin
      comando c;
      int maximos;

      c = new();

      // The mul_max bin of the coverage in the Functional coverage section: a multiplication with
      // both legs at 0xFF. It is the multiplier overflow.
      repeat (N) begin
         if (!c.randomize()) $fatal(1, "randomize() failed");
         if (c.op == mul_op && c.A == 8'hFF && c.B == 8'hFF) maximos = maximos + 1;
      end
      $display("random:   %0d tries, mul_max filled %0d time(s)", N, maximos);

      // The same thing, asked for: with {} adds constraints ONLY for this call.
      // The request is satisfiable, but in 5.052 the dist is solved by picking a
      // value BEFORE checking the with: if the draw does not comply, it returns
      // 0 instead of retrying. With A and B on dist, both landing on 0xFF is
      // 1/4 x 1/4. The measured rates are in
      // code/verilator/repro-dist-with.sv; the detail in docs/verilator.md.
      if (!c.randomize() with {
            op == mul_op;
            A  == 8'hFF;
            B  == 8'hFF;
          })
         $display("with with: randomize() gave 0  <- a Verilator limitation, not yours");

      // The portable workaround meanwhile: turn off the split, which for a
      // directed case makes no sense anyway.
      // cb: workaround
      c.data.constraint_mode(0);
      if (!c.randomize() with {
            op == mul_op;
            A  == 8'hFF;
            B  == 8'hFF;
          })
         $fatal(1, "randomize() with failed even with the constraint turned off");
      $display("with with: 1 try,      A=%2h %s B=%2h", c.A, c.op.name(), c.B);
      // cb: end
      $finish;
   end

endmodule : top_with
