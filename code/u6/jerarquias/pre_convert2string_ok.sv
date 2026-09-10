// ILLUSTRATION -- not compiled. The same three methods written deep, with the
// classes drawn as comments. The version that does compile is deep.sv.
//virtual class trago;
   virtual function string convert2string();
      return $sformatf("Hielos: %0d", hielos);
   endfunction : convert2string

//class con_alcohol extends trago;

   function string convert2string();
      return {super.convert2string(),
              $sformatf("\ngraduacion: %0d",graduacion)};
   endfunction : convert2string

//class fernet extends con_alcohol;

   function string convert2string();
      string coca_s;
      coca_s = (con_coca) ? "si" : "no";
      return {super.convert2string(), "\nCoca: ",coca_s};
   endfunction : convert2string