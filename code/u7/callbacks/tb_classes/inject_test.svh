// The same test as ../agents, with two callbacks hung on the driver.
//
// Note what this class does NOT touch: not the env, not the agent, not the
// driver, not the sequence. That is the whole promise of the third hook -- and
// it is the same promise as the factory override, one level lower: the override
// swaps a class, the callback changes what one class does at one point.
class inject_test extends dual_test;
   `uvm_component_utils(inject_test)

   flip_bit_cb flip_h;
   jitter_cb   jitter_h;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   // end_of_elaboration and not build: the driver is a grandchild of the env,
   // and build_phase runs top-down -- when this test's build_phase returns, the
   // driver does not exist yet.
   // cb: hooking-the-cb
   function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);

      flip_h   = flip_bit_cb::type_id::create("flip_h");
      jitter_h = jitter_cb::type_id::create("jitter_h");

      // Both on the same driver, and both run: the queue is per component
      // instance, in insertion order. The passive agent has no driver, so there
      // is nothing to hook there.
      uvm_callbacks #(driver, driver_callback)::add(env_h.clase_agent_h.driver_h, jitter_h);
      uvm_callbacks #(driver, driver_callback)::add(env_h.clase_agent_h.driver_h, flip_h);

   // cb: end
      if ($test$plusargs("CALLBACK_TRACE"))
         uvm_callbacks #(driver, driver_callback)::display(env_h.clase_agent_h.driver_h);
   endfunction : end_of_elaboration_phase

endclass : inject_test
