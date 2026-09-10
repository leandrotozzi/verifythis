// The WRONG way to write convert2string!
//class trago;
   virtual function string convert2string();
      return $sformatf("Hielos: %0d", hielos);
   endfunction : convert2string
//class fernet extends trago;
   function string convert2string();
      string coca_s;
      coca_s = (con_coca) ? "si" : "no";
      return $sformatf("Hielos: %0d  Coca: %s", hielos, coca_s);
   endfunction : convert2string

//class fernet_doble extends fernet;
   function string convert2string();
      return {$sformatf("hielos: %0d  coca: %0b  mesa: %s",
      	       hielos, con_coca, mesa) };
   endfunction : convert2string