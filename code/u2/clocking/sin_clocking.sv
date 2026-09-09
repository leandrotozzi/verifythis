// Sampling by hand: without a clocking block you have to pick the edge AND the
// delta, in every task, over and over. This top runs the three variants people
// write in their first week: one reads the OLD value, the other two the NEW.
//
//   bash run.sh
module dut_reg (input bit clk, input byte unsigned d_in, output byte unsigned d_out);
   // The DUT counts: on every edge, the output becomes the input + 1.
   always_ff @(posedge clk) d_out <= d_in + 8'd1;
endmodule

module top_sin;
   bit           clk = 0;
   byte unsigned d_in, d_out;

   always #5 clk = ~clk;
   dut_reg u_dut (.*);

   byte unsigned en_el_flanco, un_delta_despues, en_el_flanco_opuesto;

   initial begin
      d_in = 8'd10;
// cb: three-samples

      // 1. Sample AT the edge. The DUT always_ff updates d_out with a
      //    nonblocking assignment, which lands after this initial already ran:
      //    you read the OLD value.
      @(posedge clk);
      en_el_flanco = d_out;

      // 2. The same edge, one delta later. The nonblocking assignment landed
      //    already and you read the NEW value. That "#1" is visible nowhere and
      //    changes the result.
      @(posedge clk);
      #1;
      un_delta_despues = d_out;

      // 3. The opposite edge: the trick the whole course BFM uses. It works,
      //    but it asks whoever reads it to know why.
      @(negedge clk);
      en_el_flanco_opuesto = d_out;
// cb: end

      $display("d_in = %0d, and the DUT computes d_in + 1 = %0d", 8'd10, 8'd11);
      $display("  sampled AT the posedge        : %0d", en_el_flanco);
      $display("  sampled one delta later       : %0d", un_delta_despues);
      $display("  sampled at the negedge        : %0d", en_el_flanco_opuesto);
      $display("");
      $display("Three lines that look the same and are not. And that decision");
      $display("is repeated in every task of the interface.");
      $finish;
   end
endmodule : top_sin
