// ILLUSTRATION -- not compiled. In the previous example, new() gets called every
// time an object is needed: building a new set of drinks means editing the source.
bandeja_de_fernet = new();
fernet_h = new(15, "the one at the bar");
bandeja_de_fernet.bandeja_trago(fernet_h);
fernet_h = new(15, "the one at table 4");
bandeja_de_fernet.bandeja_trago(fernet_h);

bandeja_de_mojito = new();
mojito_h = new(1, "the one at table 7");
bandeja_de_mojito.bandeja_trago(mojito_h);

mojito_h = new(1, "the one on the sidewalk");
bandeja_de_mojito.bandeja_trago(mojito_h);

// Consider the case where a set of random drinks has to be read from a file
// dynamically.
//    --> Doing that with NON hardcoded code is impossible
//        You would need a script that generates the source, recompile it...