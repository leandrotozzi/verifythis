// The structure, and nothing else. It is the capstone's active agent with three
// objects on top: the register model, the adapter, and the predictor.
virtual class ral_base_test extends uvm_test;
   `uvm_component_abstract_utils(ral_base_test)

   apb_agent        agent_h;
   apb_agent_config agent_cfg_h;

   apb_reg_block    model;
   apb_reg_adapter  adapter;

   // Parameterised by the BUS item, not by the register: the predictor's job is
   // to turn what the monitor saw into a prediction on the model.
   uvm_reg_predictor #(apb_transaction) predictor;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      virtual apb_if bfm;

      if (!uvm_config_db#(virtual apb_if)::get(this, "", "bfm", bfm))
         `uvm_fatal("RAL BASE TEST", "Failed to get bfm")

      agent_cfg_h = new(.bfm(bfm), .is_active(UVM_ACTIVE));
      uvm_config_db#(apb_agent_config)::set(this, "agent_h*", "config", agent_cfg_h);
      agent_h = apb_agent::type_id::create("agent_h", this);

      // A uvm_reg_block is a uvm_object: create() does not call build(), the way
      // the component build_phase would. Forgetting this line leaves a model
      // with zero registers and an error that says nothing.
      model = apb_reg_block::type_id::create("model");
      model.build();

      adapter   = apb_reg_adapter::type_id::create("adapter");
      predictor = uvm_reg_predictor #(apb_transaction)::type_id::create("predictor", this);
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      // The three lines that turn a model into a testbench component: which
      // sequencer carries the accesses, which adapter translates them, and where
      // the truth about the DUT comes from.
      model.default_map.set_sequencer(agent_h.sequencer_h, adapter);
      model.default_map.set_auto_predict(0);

      predictor.map     = model.default_map;
      predictor.adapter = adapter;
      agent_h.ap.connect(predictor.bus_in);
   endfunction : connect_phase

   // The reset the driver does at time 0 happens on the wire; the model has to
   // be told, or its mirror starts out as "unknown" instead of as the reset
   // values of the spec.
   task reset_model();
      model.reset();
   endtask : reset_model

   // The model printed back as the table it came from. One line per field, in
   // the order of the map, with the four things the spec says about it: where it
   // lives, how wide it is, and how it is accessed.
   //
   // It is worth doing once out loud, because a register model is the only
   // document in a project that is both the spec and the code -- and this is
   // the diff between the two.
   function void print_map();
      uvm_reg   regs[$];
      uvm_reg_field fields[$];
      model.get_registers(regs);
      foreach (regs[i]) begin
         fields.delete();   // get_fields() APPENDS: without this, register i
         regs[i].get_fields(fields);   // prints the fields of 0..i as well
         foreach (fields[j])
            `uvm_info("MAPA", $sformatf("%-8s @0x%02h  %-7s [%0d+:%0d]  %s",
                      regs[i].get_name(), regs[i].get_offset(model.default_map),
                      fields[j].get_name(), fields[j].get_lsb_pos(),
                      fields[j].get_n_bits(), fields[j].get_access()), UVM_NONE)
      end
   endfunction : print_map

   function void start_of_simulation_phase(uvm_phase phase);
      if ($test$plusargs("MAPA")) print_map();
   endfunction : start_of_simulation_phase

endclass : ral_base_test
