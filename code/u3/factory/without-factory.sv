// En el ejemplo anterior, llamamos a new() cada vez que queremos crear un objeto
// Si queremos crear un conjunto nuevo de tragos, debemos cambiar el codigo fuente
bandeja_de_fernet = new();
fernet_h = new(15, "el de la barra");
bandeja_de_fernet.bandeja_trago(fernet_h);
fernet_h = new(15, "el de la mesa 4");
bandeja_de_fernet.bandeja_trago(fernet_h);

bandeja_de_gancia = new();
gancia_h = new(1, "el de la mesa 7");
bandeja_de_gancia.bandeja_trago(gancia_h);

gancia_h = new(1, "el de la vereda");
bandeja_de_gancia.bandeja_trago(gancia_h);

// Consideremos el caso en el que queremos leer un conjunto de tragos aleatorios
// desde un archivo de forma dinamica.
//    --> Es imposible hacer esto con codigo NO hardcodeado
//        Tenemos que hacer un script que genere el source, recompilarlo....