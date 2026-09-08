initial begin
   fernet_hielo1_h =
       new(.hielos(2), .con_coca(1), .graduacion(2), .mesa("mesa 4"), .medidas(2));
   $display("\n--- Fernet 1 ---\n", fernet_hielo1_h.convert2string());
   fernet_hielo2_h = new();
   $display("\n--- Fernet 2 antes de la copia ---\n", fernet_hielo2_h.convert2string());
   // do_copy es un metodo que se encarga de copiar miembro a miembro
   // sufre del mismo problema que ya vimos con convert2string()
   // Cada clase puede copiar las variables definidas en esa clase
   // Debemos usar super.do_copy() para copiar variables heredadas
   fernet_hielo2_h.do_copy(fernet_hielo1_h);
   $display("\n--- Fernet 2 despues de la copia ---\n", fernet_hielo2_h.convert2string());
end
