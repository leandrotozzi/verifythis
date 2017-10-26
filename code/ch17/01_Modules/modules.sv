// InterThread Communication
// 	Los initials de cada modulo, son 2 threads distintos


// Manda el dato via la variable shared y avisa togleando la signal get_it
// Luego el productor se bloquea mediante la signal put_it
module producer(output byte shared, input bit put_it, output bit get_it);
   initial
     repeat(3) begin 
        $display("Sent %0d", ++shared);
        get_it = ~get_it;
        @(put_it);
     end
endmodule : producer

// El Consumidor se bloquea en la signal get_it, esperando un dato del productor
// cuando el productor toglea esta signal, la procesa y al terminar toglea put_it
// para desbloquear al productor
module consumer(input byte shared,  output bit put_it, input bit get_it);
   initial
      forever begin
         @(get_it);
         $display("Received: %0d", shared);
         put_it = ~put_it;
      end
endmodule : consumer


module top; 
   byte shared;
   producer p (shared, put_it, get_it);
   consumer c (shared, put_it, get_it);
endmodule : top