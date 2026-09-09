// The same DUT, with a clocking block: the edge and the delta are declared ONCE,
// inside the interface, and no task ever picks them again.
//
//   bash run.sh
module dut_reg (input bit clk, input byte unsigned d_in, output byte unsigned d_out);
   always_ff @(posedge clk) d_out <= d_in + 8'd1;
endmodule

interface reg_bfm (input bit clk);
   byte unsigned d_in, d_out;

   // The only two timing lines in the testbench:
   //   input  #1step  samples the STABLE value right before the edge, which is
   //                  what the hardware sees. Never what the nonblocking
   //                  assignment just wrote on that same edge.
   //   output #0      drives ON the edge, in the nonblocking region, so the DUT
   //                  does not see it until the next edge.
   clocking cb @(posedge clk);
      default input #1step output #0;
      output d_in;
      input  d_out;
   endclocking

   modport tb (clocking cb);
endinterface : reg_bfm

module top_con;
   bit clk = 0;
   always #5 clk = ~clk;

   reg_bfm bfm (clk);
   dut_reg u_dut (.clk(clk), .d_in(bfm.d_in), .d_out(bfm.d_out));

   byte unsigned primera, segunda, tercera;

   initial begin
      // Driving is "<=" against the clocking block. There is no edge to pick.
      bfm.cb.d_in <= 8'd10;

      // @(bfm.cb) is "wait for this clocking block's edge". There are THREE, and
      // the reason is the whole lesson:
      //   1st edge  the output #0 only now puts d_in at 10, in the nonblocking
      //             region, so the DUT has not seen it yet.
      //   2nd edge  now the DUT takes d_in=10 and computes d_out <= 11.
      //   3rd edge  the input #1step samples the STABLE value before this edge,
      //             which is already 11.
      // A testbench without a clocking block hides this behind a #1 and works by
      // accident. Here the arithmetic is visible and does not depend on the tool.
      @(bfm.cb);
      @(bfm.cb);
      @(bfm.cb);

      // And sampling is reading cb.d_out. It is read three times, at three
      // different points of the same cycle, and gives the same value all three.
      primera = bfm.cb.d_out;
      #2;
      segunda = bfm.cb.d_out;
      #3;
      tercera = bfm.cb.d_out;

      $display("d_in = %0d, and the DUT computes d_in + 1 = %0d", 8'd10, 8'd11);
      $display("  cb.d_out, right after the edge  : %0d", primera);
      $display("  cb.d_out, two units later       : %0d", segunda);
      $display("  cb.d_out, five later            : %0d", tercera);
      $display("");
      $display("The same number all three times, and not a single #1 in the testbench.");
      $display("The edge and the delta were declared once, in the clocking block.");

      if (primera != 8'd11 || segunda != 8'd11 || tercera != 8'd11)
        $fatal(1, "the clocking block should give 11 all three times");
      $finish;
   end
endmodule : top_con
