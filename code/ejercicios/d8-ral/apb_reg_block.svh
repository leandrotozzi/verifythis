// Ejercicio del dia 7 (unidad 9, RAL) -- modelar el mapa de registros.
//
// La tabla esta en la spec del capstone: ../d7-final/spec.md, seccion "El mapa
// de registros". Este archivo es esa tabla escrita como modelo de UVM, y no hay
// nada mas que escribir: el adapter, el predictor y los tests salen de
// code/u9/ral/ y no se tocan.
//
// Cuatro registros, seis campos, cuatro direcciones. El corrector va por etapas:
//
//   ETAPA 1  el mapa: nombres, direcciones, anchos y accesos
//   ETAPA 2  los accesos: las dos sequences de la libreria en verde
//   ETAPA 3  lo que el modelo NO puede predecir
//
// La firma que vas a usar seis veces:
//
//   configure(parent, size, lsb_pos, access, volatile, reset, has_reset,
//             is_rand, individually_accessible)
//
// Y la lista de accesos de UVM esta en el LRM 1800.2, tabla del uvm_reg_field.
// Los cuatro que hacen falta aca estan entre: RW, RO, WO, WOC, W1C, RC.

class ctrl_reg extends uvm_reg;
   `uvm_object_utils(ctrl_reg)

   rand uvm_reg_field EN;
   rand uvm_reg_field CLR;

   function new(string name = "ctrl_reg");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction : new

   virtual function void build();
      // <<< ACA >>>  EN es el bit 0 y es un bit comun: se escribe, se lee, queda.
      //              CLR es el bit 1 y NO es comun: escribir un 1 borra ACC y
      //              OVF, y el bit se lee SIEMPRE en 0. Hay un acceso de UVM que
      //              dice exactamente eso; si le ponés el obvio, la etapa 2 te
      //              lo va a decir.
   endfunction : build

endclass : ctrl_reg

class scratch_reg extends uvm_reg;
   `uvm_object_utils(scratch_reg)

   rand uvm_reg_field VALUE;

   function new(string name = "scratch_reg");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction : new

   virtual function void build();
      // <<< ACA >>>  32 bits libres. Que ademas sumen a ACC no es asunto del
      //              modelo: eso pasa en OTRA direccion.
   endfunction : build

endclass : scratch_reg

class acc_reg extends uvm_reg;
   `uvm_object_utils(acc_reg)

   uvm_reg_field VALUE;

   function new(string name = "acc_reg");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction : new

   virtual function void build();
      // <<< ACA >>>  Solo lectura. Y mirá el argumento `volatile`: el DUT lo
      //              cambia por atras, sin que pase una transferencia a 0x08.
   endfunction : build

endclass : acc_reg

class status_reg extends uvm_reg;
   `uvm_object_utils(status_reg)

   uvm_reg_field EN;
   uvm_reg_field OVF;

   function new(string name = "status_reg");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction : new

   virtual function void build();
      // <<< ACA >>>  Dos bits de solo lectura, y los dos volatiles por la misma
      //              razon que ACC.
   endfunction : build

endclass : status_reg

class apb_reg_block extends uvm_reg_block;
   `uvm_object_utils(apb_reg_block)

   rand ctrl_reg    CTRL;
   rand scratch_reg SCRATCH;
   acc_reg          ACC;
   status_reg       STATUS;

   function new(string name = "apb_reg_block");
      super.new(name, UVM_NO_COVERAGE);
   endfunction : new

   // Ojo: esto NO es un build_phase. Un uvm_reg_block es un uvm_object, no un
   // component: nadie te llama. Quien llama a este build() es el test, una linea
   // despues del create().
   virtual function void build();
      // El mapa: direcciones de byte, 4 bytes por acceso, little endian.
      default_map = create_map("default_map", 'h0, 4, UVM_LITTLE_ENDIAN, 1);

      CTRL = ctrl_reg::type_id::create("CTRL");
      CTRL.configure(this, null, "");
      CTRL.build();
      default_map.add_reg(CTRL, CTRL_ADDR, "RW");

      // <<< ACA >>>  Los otros tres, igual que CTRL. Las direcciones ya estan
      //              como localparam en apb_pkg: SCRATCH_ADDR, ACC_ADDR y
      //              STATUS_ADDR.

      // <<< ACA >>>  Y la ultima, que es la que separa un modelo que sirve de uno
      //              que miente. ACC y STATUS tienen direccion pero NO son
      //              registros: su valor lo produce una escritura a otra
      //              direccion. Un modelo predice "lo que escribi es lo que voy a
      //              leer", y para estos dos eso es falso.
      //
      //              La etapa 3 corre un mirror(UVM_CHECK) sobre STATUS despues
      //              de prender CTRL.EN. Tal cual esta, ese chequeo falla -- y la
      //              falla es del modelo, no del DUT. Apagalo con
      //              set_compare(UVM_NO_CHECK) sobre los campos que no se pueden
      //              predecir. El acumulador se sigue chequeando donde ya estaba:
      //              en el scoreboard del capstone.

      lock_model();
   endfunction : build

endclass : apb_reg_block
