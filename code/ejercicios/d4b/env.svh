// The env of the put and get section, with ONE line changed: the FIFO comes
// unbounded.
//
//   uvm_tlm_fifo #(command_s) command_f;
//   command_f = new("command_f", this, 0);   // 0 = no ceiling
//
// With the default size of 1, put() blocks until the driver takes the previous
// command, and that back-pressure is what kept the tester in step with the bus.
// With 0 nobody blocks: the tester dumps its thousand commands at t = 0 and
// walks away.
//
// This file is NOT touched -- it is the DUT of this exercise. See intocables.sha.
class env extends uvm_env;
   `uvm_component_utils(env);

   random_tester             random_tester_h;
   driver                    driver_h;
   uvm_tlm_fifo #(command_s) command_f;

   coverage                  coverage_h;
   scoreboard                scoreboard_h;

   command_monitor           command_monitor_h;
   result_monitor            result_monitor_h;

   function void build_phase(uvm_phase phase);
      command_f = new("command_f", this, 0);
      random_tester_h = random_tester::type_id::create("random_tester_h", this);
      driver_h = driver::type_id::create("driver_h", this);

      coverage_h = coverage::type_id::create("coverage_h", this);
      scoreboard_h = scoreboard::type_id::create("scoreboard_h", this);
      command_monitor_h = command_monitor::type_id::create("command_monitor_h", this);
      result_monitor_h = result_monitor::type_id::create("result_monitor_h", this);
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      driver_h.command_port.connect(command_f.get_export);
      random_tester_h.command_port.connect(command_f.put_export);

      result_monitor_h.ap.connect(scoreboard_h.analysis_export);

      command_monitor_h.ap.connect(scoreboard_h.cmd_f.analysis_export);
      command_monitor_h.ap.connect(coverage_h.analysis_export);
   endfunction : connect_phase

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass
