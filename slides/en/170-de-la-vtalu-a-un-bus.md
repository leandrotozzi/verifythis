<!-- es-sha: e4df2b95cff7 -->
<!-- .slide: id="apendice-bus" data-machete="res/diagrams/en/sequences_tb_completo.svg,res/diagrams/en/agents_agent.svg" -->

## Appendix · From the VTALU to a real bus

#### *What does not change*

- The DUT of the course has a three-signal handshake. On Monday you are going to
  run into **AXI, APB or AHB**, and the honest question is how much of this is any use
- The tree, all of it: `test` → `env` → `agent` → sequencer, driver and monitors, with
  the analysis hanging off the analysis ports. **It is the same diagram**
- The agent is still **one per interface**. A DUT with a configuration APB
  and a data AXI is two agents, not one bigger agent
- The configuration still comes down through **one object per level**, and the scope of the
  `config_db` is still a path
- The sequence is still an object that gets created, runs and is thrown away

Note:
This appendix exists because everybody asks the question when they finish, and the
short answer is good news: the **architecture** does not change at all. What
changes is a single class, the driver, and one more single class, the monitor.
It is worth saying it with numbers so it does not sound like consolation: of the nine classes of
`code/u7/sequences`, in an APB agent two get rewritten —driver and monitor—, the
transaction gains fields, and the rest —test, env, agent, config, scoreboard,
coverage, sequences— gets copied and adapted.
And the underlying reason is the one the course has been repeating since the `env`: what
knows about the protocol is shut away in one place. Changing protocol touches that
place and nothing else. If the student had to rewrite the env, it would be a sign that the
agent was badly built.

---

## Appendix · From the VTALU to a real bus

#### *What does change*

- **The driver stops being a linear task.** An operation of the VTALU is raising
  `start` and waiting for `done`. A bus has phases —address, data, response— and in
  AXI the five channels run **independently**: the driver goes from a `send_op()`
  to several threads with `fork`
- **The monitor has to reconstruct.** Watching one edge is no longer enough: the
  address of one channel has to be paired with the data of another, by ID. It is the hardest class
  of the agent, and the one most underestimated
- **The transaction grows**: address, burst type, length, strobes, response. And
  the constraints stop being decorative — in AXI a burst cannot cross a
  4 KB boundary, and that is a `constraint`, not a comment
- **Virtual sequences stop being a luxury**: configure over APB, then
  send traffic over AXI with what the configuration gave back. The shape is the one from
  sequences —`virtual_sequencer`, `p_sequencer`, one `fork` per interface—; the
  only thing that changes is that the two sequencers are of different types
- **RAL shows up.** If the DUT has registers —and it does—, `uvm_reg` gives you the
  model and the register tests already done

Note:
The first bullet is the one to underline, because it is where the
intuition the course built breaks. In the VTALU, "an operation" and "an exchange
on the bus" are the same thing. In AXI they are not: a write transaction is three
channels that can go in any order, and `item_done()` gets called when the
response arrived, not when the address was put out.
A practical consequence worth getting ahead of: the moment the driver has
several transactions in flight, the `get_next_item` / `item_done` pair stops
being enough and a `uvm_tlm_fifo` shows up inside the driver, or the *pipelined* mode. It is not
a new topic: they are the same pieces as threads and as put and get.
And about the second bullet, to bring the anxiety down: the monitor of a known
protocol almost never gets written. It gets bought or downloaded.

---

## Appendix · From the VTALU to a real bus

#### *Vertical reuse: the block env inside the system env*

```systemverilog
class soc_env extends uvm_env;
   apb_env apb_env_h;     // the block env, without touching a line of it
   axi_env axi_env_h;
   soc_scoreboard sb_h;   // the system one watches both ends, not the transfers

   function void build_phase(uvm_phase phase);
      // What changes is not the env's code: it is its CONFIGURATION
      apb_cfg.is_active = UVM_PASSIVE;   // here the APB is driven by the SoC's CPU
      uvm_config_db #(apb_env_config)::set(this, "apb_env_h*", "cfg", apb_cfg);
      apb_env_h = apb_env::type_id::create("apb_env_h", this);
   endfunction
endclass
```

- The reuse of the agents section is **horizontal**: two instances of the same
  agent in the same env. This one is **vertical**, and it is the one that pays off in a SoC
- The block env does not get edited. What changes is its config: the agent becomes
  **passive** because at system level the bus is driven by the DUT, not the testbench
- That is why `is_active` and the config object are not ceremony: they are the hinge that
  makes the same code work at both levels
- What does **not** move up is the block scoreboard: the system one compares the SoC's
  input against its output, and the block one goes on measuring its bus

Note:
This is the answer to *"and what are all those classes for, if my DUT has a bus?"*, and the
answer is that the block testbench is not written for the block: it is written
so that in six months it goes whole inside the chip's testbench.
The concrete rule that decides whether an env is reusable, worth handing over as a
three-point checklist: **it does not create its own interface** —it receives it through
`config_db`—, **it does not read from the `config_db` with absolute paths** —no
`uvm_test_top.env_h.*`, because at system level that path does not exist—, and **it does not
raise objections of its own** unless it is the one in charge. An env that breaks
any of the three compiles just the same and cannot be instantiated twice.
The change from active to passive is the typical case and is worth explaining slowly: at
block level the testbench drives the APB because there is nobody else. At
SoC level that bus is driven by the real processor, so the same agent has to
watch without driving — and that is already solved, it is the `is_active` of the agents
section. Not one new line.
And the fact that closes the capstone: the env they wrote in `d7-final` **already** is
reusable, because its config comes from outside and so does its interface. It was not
a coincidence; it was the `apb_env_config`.


---

## Appendix · From the VTALU to a real bus

#### *Where to start*

- **Look for a VIP before writing an agent.** Almost nobody writes an AXI agent
  from scratch: the vendors sell them and there are free ones. Writing your own is a project
  of months and it is not the one you were asked for
- **The protocol before the methodology.** 90 % of the bugs of a new agent
  are about a badly read protocol, not about UVM. The spec of the bus first
- **The first thing that gets written is the monitor**, not the driver. If you cannot *see* the
  bus you cannot verify anything — not even somebody else's stimulus
- And there the **passive agent** is your first real deliverable:
  watch before driving
- **SVA in parallel.** A bus has rules that get checked where they happen, not in the
  scoreboard, and on a bus with overlapping transactions that is the difference between
  half an hour and two days. You already have the tool: **the assertions**, with the advantage
  that the properties travel inside the interface of the VIP

Note:
The order of this slide is field advice and it is worth defending: whoever
starts with the driver writes stimulus nobody is watching, and discovers a
week later that their monitor does not reconstruct. Whoever starts with the monitor can
plug it in passively on somebody else's stimulus —or on a test from the designer— and is
already contributing on the first day.
If somebody asks where the learning path goes on from here, the
order that pays off: RAL, then regression with seeds, then the `clocking block`
and the prefabricated bus properties. SVA is no longer on that list —it is a whole unit of this course— and it is worth saying so, because it is the first question of every interview.
And a last one, which is not technical: in a real project the testbench almost always
already exists. What gets asked for on the first day is not building one, it is **adding a test
to it** — which is exactly what they practised in the exercises of days 3 and 6.
