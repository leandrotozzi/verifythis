// TODO(exercise 4): write the op_counter class here.
//
// It has to:
//   1. extend uvm_subscriber #(command_s)
//   2. count in write() the commands that reach it, and the mul_op separately
//   3. in report_phase, print with UVM_NONE verbosity:
//
//        `uvm_info("OP_COUNTER", $sformatf("commands=%0d multiplications=%0d",
//                                          total, muls), UVM_NONE)
//
// The runner compares that "commands=" against the number of lines the
// command_monitor prints: if you did not connect the port, they will differ.
//
// Look at coverage.svh in code/u5/analysis-ports/tb_classes/: it is a uvm_subscriber too and
// has the same shape. Then connect it in env.svh.
