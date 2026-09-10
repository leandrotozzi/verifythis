class pepe;
   static    int    cant;
   int    val = -1;

   function new(int a);
      // Static Variable
      cant++;
      val = a;
   endfunction : new

endclass : pepe

//----------------------------------------
module top_pepes;
   initial begin
      pepe pepe1_h, pepe2_h;

      pepe1_h = new(10);
      pepe2_h = new(254654);

      $display("PEPE1 VAL = %0d", pepe1_h.val);
      $display("PEPE2 VAL = %0d", pepe2_h.val);

      // There is only one copy of a static variable in memory,
      // no matter how many instances of the class exist
      $display("NUMBER OF PEPES = %0d", pepe::cant);

   end
endmodule : top_pepes
