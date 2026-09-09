// InterThread Communication
// 	The initials of each module are 2 different threads

// Sends the data through the shared variable and signals it by toggling get_it
// Then the producer blocks on the put_it signal
module producer (
    output byte shared,
    input  bit  put_it,
    output bit  get_it
);
   initial
      repeat (3) begin
         $display("Sent %0d", ++shared);
         get_it = ~get_it;
         @(put_it);
      end
endmodule : producer

// The consumer blocks on the get_it signal, waiting for data from the producer
// when the producer toggles that signal, it processes the data and toggles put_it
// when done, to unblock the producer
module consumer (
    input  byte shared,
    output bit  put_it,
    input  bit  get_it
);
   initial
      forever begin
         @(get_it);
         $display("Received: %0d", shared);
         put_it = ~put_it;
      end
endmodule : consumer

module top;
   byte shared;
   producer p (
       shared,
       put_it,
       get_it
   );
   consumer c (
       shared,
       put_it,
       get_it
   );
endmodule : top
