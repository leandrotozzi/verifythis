// Ejercicio del dia 6 -- cerrar un bin.
//
// El bin que falta es el del plan de cobertura de la seccion Cobertura funcional: "las dos patas
// en FF, multiplicando". Con 60 operaciones al azar no se llena, y el reporte
// que imprime run.sh te lo muestra.
//
// Se pide: mandar UNA transaction con A = 8'hFF, B = 8'hFF y op = mul_op,
// pedida con randomize() with {} -- no asignando los campos a mano. El caso
// dirigido se pide en el punto de uso; esa es la herramienta de la seccion Transactions.
//
// Dos advertencias que estan en las slides y te van a hacer falta:
//
//   1. command_transaction tiene un `dist` sobre A y sobre B. Verilator resuelve
//      el dist ELIGIENDO UN VALOR primero y despues chequea el resto: si el
//      sorteado no cumple tu with, randomize() devuelve 0 en vez de reintentar.
//      El rodeo esta en la seccion Constrained random y es una linea.
//   2. randomize() se chequea con if, nunca con assert().
class cierre_sequence extends uvm_sequence #(command_transaction);
   `uvm_object_utils(cierre_sequence)

   function new(string name = "cierre_sequence");
      super.new(name);
   endfunction : new

   task body();
      command_transaction command;
      command = command_transaction::type_id::create("command");

      start_item(command);

      // <<< ACA >>>  randomize() with { ... }, y lo que haga falta antes.

      finish_item(command);

      `uvm_info("CIERRE", $sformatf("A=%2h B=%2h op=%s result=%4h",
                command.A, command.B, command.op.name(), command.result), UVM_NONE)
   endtask : body

endclass : cierre_sequence
