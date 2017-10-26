virtual class base_tester extends uvm_component;
   `uvm_component_utils(base_tester)
   virtual tinyalu_bfm bfm;

   function void build_phase(uvm_phase phase);
      if(!uvm_config_db #(virtual tinyalu_bfm)::get(null, "*","bfm", bfm))
        $fatal("Failed to get BFM");
   endfunction : build_phase

   pure virtual function operation_t get_op();

   pure virtual function byte get_data();

   task run_phase(uvm_phase phase);
      byte         unsigned        iA;
      byte         unsigned        iB;
      operation_t                  op_set;
      shortint     result;
      
      phase.raise_objection(this);
      bfm.reset_alu();
      repeat (1000) begin : random_loop
         op_set = get_op();
         iA = get_data();
         iB = get_data();
         bfm.send_op(iA, iB, op_set, result);
      end : random_loop
      #500;
      phase.drop_objection(this);
   endtask : run_phase
   

   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass : base_tester
