class dice_test extends uvm_test;
   `uvm_component_utils(dice_test);

   dice_roller dice_roller_h;
   coverage coverage_h;
   histogram histogram_h;
   average average_h;

   // Observer Design Patter:
   //	Es como Twitter. Un objeto crea data y la comparte con el mundo,
   //	sin importar cuantos seguidores tenga (observers)
   //	Cualquier numero de observadores pueden ver el objeto creado.
   //	Todos obtienen una copia del dato y pueden hacerle lo que quieran

   // En este ejemplo, dice_roller crea el dato (observed object)
   // Y coverage_h, histogram_h y average_h	son los observadores
   // PERO, UVM llama a los observadores subscribers

   // UVM provee 2 clases que facilitan implementar este design pattern
   //	* uvm_analysis_port: Provee un camino para que un objeto mande data
   //		a un conjunto de observadores
   //	* uvm_subscriber: Es una extension de uvm_component, que habilita 
   //		subscribirse a un uvm_analysis_port

   // UVM llama a connect_phase en todos nuestros componentes UVM una vez 
   // que ha terminado de llamar a todas los build_phase
   // build_phase es TopDown
   // connect_phase es BottomUp

   // El proceso de conexion tiene 2 partes
   //	* uvm_subscribers contienen un objeto llamado analysis_export.
   //		No hace falta instanciarlo, nos aparece cuando extendemos uvm_subscriber
   //	* La clase uvm_analysis_port provee un metodo llamado connect()


   // en dice_roller tenemos el analysis_port
   // uvm_analysis_port #(int) roll_ap;

   function void connect_phase(uvm_phase phase);
      dice_roller_h.roll_ap.connect(coverage_h.analysis_export);
      dice_roller_h.roll_ap.connect(histogram_h.analysis_export);      
      dice_roller_h.roll_ap.connect(average_h.analysis_export);
   endfunction : connect_phase
   
      
   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new

   // UVM llama a los metodos build_phase de forma TOP-DOWN
   function void build_phase(uvm_phase phase);
      
      
      dice_roller_h = new("dice_roller_h", this);
      coverage_h    = new("coverage_h", this);
      histogram_h   = new("histogram_h",this);
      average_h     = new("average_h",this);

   endfunction : build_phase


endclass : dice_test