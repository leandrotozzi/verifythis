class dice_roller extends uvm_component;
   `uvm_component_utils(dice_roller);

   // uvm_analysis_port nos permite enviar data a los subscribers 
   // (no importa cuantos sean) Para utilizarlo hay que hacer lo siguiente
   //    1) Declarar una variable que sea el analysis_port y definir el tipo de 
   //       de datos que va a enviar
   //    2) Hay que instanciar el uvm_analysis_port en build_phase
   //    3) Escribir el dato en el analysis port usando el metodo write()
   //    4) Una vez q escribiste el dato, va a todos los subscribers

   // El uvm_analysis_port tiene otro metodo: connect() que sirve para
   // conectar los subscribers al puerto
   // Tiene un unico argumento: un objeto analysis_port


   uvm_analysis_port #(int) roll_ap;

   // Instanciamos el analysis_port roll_ap en build_phase
   // No usamos la factory para instanciar ports
   function void build_phase (uvm_phase phase);
      
      roll_ap = new("roll_ap",this);
      
   endfunction : build_phase
   
   rand byte die1;
   rand byte die2;
   
   constraint d6 { die1 >= 1; die1 <= 6; 
                   die2 >= 1; die2 <= 6; }


   task run_phase(uvm_phase phase);
      int the_roll;
      phase.raise_objection(this);
      void'(randomize());
      repeat (40) begin
         void'(randomize());
         the_roll = die1 + die2;
         // El metodo write() en el analysis_port manda el dato
         // el analysis_port llama los metodos write() de todos los subscribers
         // y pasa el dato.
         roll_ap.write(the_roll);
      end
      phase.drop_objection(this);
   endtask : run_phase
   


   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new
   
endclass : dice_roller


      

   