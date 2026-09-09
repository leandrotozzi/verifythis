initial begin
   fernet_hielo1_h =
       new(.hielos(2), .con_coca(1), .graduacion(2), .mesa("mesa 4"), .medidas(2));
   $display("\n--- Fernet 1 ---\n", fernet_hielo1_h.convert2string());
   fernet_hielo2_h = new();
   $display("\n--- Fernet 2 before the copy ---\n", fernet_hielo2_h.convert2string());
   // do_copy is a method that copies member by member
   // it suffers from the same problem already seen with convert2string()
   // Each class can copy the variables defined in that class
   // super.do_copy() has to be used to copy the inherited ones
   fernet_hielo2_h.do_copy(fernet_hielo1_h);
   $display("\n--- Fernet 2 after the copy ---\n", fernet_hielo2_h.convert2string());
end
