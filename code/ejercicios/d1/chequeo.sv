// The checker of the day 1 exercise. It is NOT part of the exercise and it is
// not the testbench you are writing: it is bound into the top from outside, it
// looks at the DUT's own pins, and it predicts the shift by itself.
//
// Do not touch it. run.sh checks its hash in intocables.sha before compiling.
//
// It exists because everything this exercise asks for --the enum, get_op, the
// scoreboard and the covergroup-- lives in vtalu_tb.sv, the file you edit, and
// so did the verdict: a checker that reads a $display written in the file under
// test is passed by rewriting the $display. What it counts now comes off the
// bus, where nothing you write can lie about it.
module chequeo_d1;

   int ops    = 0;   // operations that answered, the same ones the scoreboard sees
   int shifts = 0;   // of those, the ones with op = 3'b110
   int wrong    = 0;   // of those, the ones whose result is not A >> B[2:0]

   // Same instant the testbench's scoreboard reads: one delta after done goes
   // up, with the operands still on the bus.
   always @(posedge top.done) begin
      #1;
      if (top.op != 3'b000 && top.op != 3'b111) begin
         ops++;
         if (top.op == 3'b110) begin
            shifts++;
            if (top.result !== (16'(top.A) >> top.B[2:0]) || top.ovf !== 1'b0) begin
               wrong++;
               if (wrong == 1)
                 $display("[CHEQUEO] the shift answered %04h for A=%02h B=%02h, and the hardware owes %04h with ovf=0",
                          top.result, top.A, top.B, 16'(top.A) >> top.B[2:0]);
            end
         end
      end
   end

   final $display("[CHEQUEO] ops=%0d shifts=%0d wrong=%0d", ops, shifts, wrong);

endmodule : chequeo_d1

bind top chequeo_d1 chequeo_i();
