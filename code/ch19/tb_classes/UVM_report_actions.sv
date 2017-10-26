typedef enum
{
	UVM_NO_ACTION = 6'b000000,
	UVM_DISPLAY   = 6'b000001,
	UVM_LOG       = 6'b000010,
	UVM_COUNT     = 6'b000100,
	UVM_EXIT      = 6'b001000,
	UVM_CALL_HOOK = 6'b010000,
	UVM_STOP      = 6'b100000
} uvm_action_type