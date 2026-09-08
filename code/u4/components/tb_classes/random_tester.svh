class random_tester extends uvm_component;
   `uvm_component_utils(random_tester)

   virtual vtalu_bfm bfm;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   virtual function operation_t get_op();
      bit [2:0] op_choice;
      op_choice = $random;
      case (op_choice)
         3'b000: return no_op;
         3'b001: return add_op;
         3'b010: return sub_op;
         3'b011: return and_op;
         3'b100: return xor_op;
         3'b101: return mul_op;
         3'b110: return rst_op;
         3'b111: return rst_op;
      endcase  // case (op_choice)
   endfunction : get_op

   virtual function byte get_data();
      bit [1:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 2'b00) return 8'h00;
      else if (zero_ones == 2'b11) return 8'hFF;
      else return $random;
   endfunction : get_data

   function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual vtalu_bfm)::get(this, "", "bfm", bfm))
         `uvm_fatal("RANDOM TESTER", "Failed to get BFM")
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      byte unsigned iA;
      byte unsigned iB;
      operation_t   op_set;

      phase.raise_objection(this);
      bfm.reset_alu();
      repeat (1000) begin : random_loop
         op_set = get_op();
         iA = get_data();
         iB = get_data();
         bfm.send_op(iA, iB, op_set);
      end : random_loop
      #500;
      phase.drop_objection(this);
   endtask : run_phase

endclass : random_tester
