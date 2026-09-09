// TODO(exercise 7): write the mult_sequence class here.
//
// It has to:
//   1. extend uvm_sequence #(command_transaction) and register itself with
//      `uvm_object_utils  --  NOT `uvm_component_utils: it is not a component
//   2. have a constructor with ONE argument only (string name), no parent
//   3. in task body()  --  task, not function: it blocks inside:
//        a. first send an item with op = rst_op. Without a reset the DUT never raises
//           done, the driver stays in its while and this sequence hangs on
//           the first finish_item(). run.sh will tell you, but you lose
//           a compile of several minutes.
//        b. send 20 multiplications with random A and B
//        c. count how many it sent, and keep the largest result it saw
//        d. at the end, print with UVM_NONE verbosity:
//
//             `uvm_info("MULT SEQ", $sformatf("items=%0d max=%0d", items, max),
//                       UVM_NONE)
//
// To get only mul_op there are two roads, both from day 5:
//     if (!command.randomize() with {op == mul_op;}) ...
//     command.op = mul_op; command.op.rand_mode(0); if (!command.randomize()) ...
//
// command.result is written by the DRIVER inside the item, before item_done().
// It is only valid AFTER finish_item() has returned.
//
// Look at reset_sequence.svh and random_sequence.svh in code/u7/sequences/tb_classes/.
