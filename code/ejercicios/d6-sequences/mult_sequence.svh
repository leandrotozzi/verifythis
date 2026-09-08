// TODO(ejercicio 7): escribi aca la clase mult_sequence.
//
// Tiene que:
//   1. extender uvm_sequence #(command_transaction) y registrarse con
//      `uvm_object_utils  --  NO `uvm_component_utils: no es un componente
//   2. tener un constructor de UN solo argumento (string name), sin parent
//   3. en task body()  --  task, no function: adentro se bloquea:
//        a. mandar primero un item con op = rst_op. Sin reset el DUT no levanta
//           done, el driver se queda en su while y esta sequence se cuelga en
//           el primer finish_item(). El run.sh te lo va a decir, pero perdes
//           una compilacion de varios minutos.
//        b. mandar 20 multiplicaciones con A y B al azar
//        c. contar cuantas mando, y guardarse el resultado mas grande que vio
//        d. al final, imprimir con verbosidad UVM_NONE:
//
//             `uvm_info("MULT SEQ", $sformatf("items=%0d max=%0d", items, max),
//                       UVM_NONE)
//
// Para que salga solo mul_op, dos caminos, los dos del dia 5:
//     if (!command.randomize() with {op == mul_op;}) ...
//     command.op = mul_op; command.op.rand_mode(0); if (!command.randomize()) ...
//
// command.result lo escribe el DRIVER adentro del item, antes de item_done().
// Recien es valido DESPUES de que volvio finish_item().
//
// Mira reset_sequence.svh y random_sequence.svh en code/u7/sequences/tb_classes/.
