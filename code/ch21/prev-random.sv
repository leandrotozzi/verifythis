// Mediante este funcion manejamos el hecho de que 
// el bus de operacion tiene 8 posibles valores, 
// pero solamente 6 son operaciones validas
virtual function operation_t get_op();
  bit [2:0] op_choice;
  op_choice = $random;
  case (op_choice)
          3'b000 : return no_op;
          3'b001 : return add_op;
          3'b010 : return and_op;
          3'b011 : return xor_op;
          3'b100 : return mul_op;
          3'b101 : return no_op;
          3'b110 : return rst_op;
          3'b111 : return rst_op;
  endcase // case (op_choice)
endfunction : get_op

// Con esta funcion buscabamos distribuir mejor 
// la probabilidad de obtener todos zeros (prob = 1/3),
// sesgando un poco la aleatoriedad, para que la prob no sea 1/256
// ya que esto dificultaria alcanzar nuestro objetivo de cobertura
virtual    function byte get_data();
  bit [1:0]   zero_ones;
  zero_ones = $random;
  if (zero_ones == 2'b00)
    return 8'h00;
  else if (zero_ones == 2'b11)
    return 8'hFF;
  else
    return $random;
endfunction : get_data