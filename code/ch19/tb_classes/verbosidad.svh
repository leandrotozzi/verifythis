typedef enum 
{
	UVM_NONE	= 0,
	UVM_LOW		= 100,
	UVM_MEDIUM	= 200, // Por Default Es Medium (si no ponemos nada usa Medium)
	UVM_HIGH	= 300,
	UVM_FULL	= 400,
	UVM_DEBUG	= 500
} uvm_verbosity

// Todos los mensajes que esten por encima de la verbosidad seteada, no se imprimen