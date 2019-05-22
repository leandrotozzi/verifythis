// En el ejemplo anterior, llamamos a new() cada vez que queremos crear un objeto
// Si queremos crear un conjunto nuevo de animales, debemos cambiar el codigo fuente
lion_cage = new();
lion_h = new(15, "Mustafa");
lion_cage.cage_animal(lion_h);
lion_h = new(15, "Simba");
lion_cage.cage_animal(lion_h);

chicken_cage = new();
chicken_h = new(1, "Little Red Hen");
chicken_cage.cage_animal(chicken_h);

chicken_h = new(1, "Lady Clucksalot");
chicken_cage.cage_animal(chicken_h);

// Consideremos el caso en el que queremos leer un conjunto de animales aleatorios 
// desde un archivo de forma dinamica. 
//    --> Es imposible hacer esto con codigo NO hardcodeado
//        Tenemos que hacer un script que genere el source, recompilarlo....