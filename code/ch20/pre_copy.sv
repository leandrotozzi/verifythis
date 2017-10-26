initial begin
      circus_lion1_h = new(.age(2), .is_female(1), 
                           .babies_in_litter(2), .name("Agnes"),
                           .numb_tricks(2));
      $display("\n--- Lion 1 ---\n",circus_lion1_h.convert2string());
      circus_lion2_h = new();
      $display("\n--- Lion 2 before copy ---\n",
               circus_lion2_h.convert2string());
      // do_copy es un metodo que se encarga de copiar miembro a miembro
      // sufre del mismo problema que ya vimos con convert2string()
      // Cada clase puede copiar las variables definidas en esa clase
      // Debemos usar super.do_copy() para copiar variables heredadas
      circus_lion2_h.do_copy(circus_lion1_h);
      $display("\n--- Lion 2 after copy ---\n",
               circus_lion2_h.convert2string());
   end