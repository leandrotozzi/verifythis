// Solucion del ejercicio del dia 6 -- cerrar un bin.
//
// Las dos lineas que importan:
//
//   command.data.constraint_mode(0)
//       apaga la constraint del `dist` SOLO para este objeto. Para un caso
//       dirigido no tiene sentido igual -- no queremos un reparto, queremos un
//       valor-- y ademas es el rodeo del agujero de Verilator: con el dist
//       activo, `with {A == 8'hFF}` resuelve una de cada cuatro veces, y el
//       resto devuelve 0. Un caso dirigido intermitente.
//
//   if (!command.randomize() with {...}) `uvm_fatal
//       con if, no con assert(): assert es una directiva de simulacion y un
//       simulador con las asserts apagadas no ejecuta el argumento.
class cierre_sequence extends uvm_sequence #(command_transaction);
   `uvm_object_utils(cierre_sequence)

   function new(string name = "cierre_sequence");
      super.new(name);
   endfunction : new

   task body();
      command_transaction command;
      command = command_transaction::type_id::create("command");

      start_item(command);

      command.data.constraint_mode(0);
      if (!command.randomize() with {A == 8'hFF; B == 8'hFF; op == mul_op;})
         `uvm_fatal("CIERRE", "randomize() with fallo")

      finish_item(command);

      `uvm_info("CIERRE", $sformatf("A=%2h B=%2h op=%s result=%4h",
                command.A, command.B, command.op.name(), command.result), UVM_NONE)
   endtask : body

endclass : cierre_sequence
