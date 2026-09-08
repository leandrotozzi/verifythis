// TODO(ejercicio 4): escribi aca la clase op_counter.
//
// Tiene que:
//   1. extender uvm_subscriber #(command_s)
//   2. contar en write() los comandos que le llegan, y aparte las mul_op
//   3. en report_phase, imprimir con verbosidad UVM_NONE:
//
//        `uvm_info("OP_COUNTER", $sformatf("comandos=%0d multiplicaciones=%0d",
//                                          total, muls), UVM_NONE)
//
// El runner compara ese "comandos=" con la cantidad de lineas que imprime el
// command_monitor: si no conectaste el puerto, van a dar distinto.
//
// Mira coverage.svh en code/u5/analysis-ports/tb_classes/: tambien es un uvm_subscriber y
// tiene la misma forma. Despues conectalo en env.svh.
