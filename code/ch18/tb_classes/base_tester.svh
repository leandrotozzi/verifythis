// En esta version no contiene un handler a la BFM
// Como add_tester y random_tester son clases heredadas a esta
// y no afectamos la conexion, esas clases tendran nuevas funcionabilidades
// gracias a modificar esta base class
virtual class base_tester extends uvm_component;
   
   `uvm_component_utils(base_tester)
   virtual tinyalu_bfm bfm;
   
   // el handler a la BFM lo reemplazamos con uvm_put_port
   uvm_put_port #(command_s) command_port;

   function void build_phase(uvm_phase phase);
      command_port = new("command_port", this);
   endfunction : build_phase

   pure virtual function operation_t get_op();

   pure virtual function byte get_data();

   task run_phase(uvm_phase phase);
      byte         unsigned        iA;
      byte         unsigned        iB;
      operation_t                  op_set;
      command_s    command;
      
      phase.raise_objection(this);
      command.op = rst_op;
      command_port.put(command);
      repeat (1000) begin : random_loop
         command.op = get_op();
         command.A =  get_data();
         command.B =  get_data();
         command_port.put(command);
      end : random_loop
      #500;
      phase.drop_objection(this);
   endtask : run_phase

   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass : base_tester
