// Minimal repro: what Verilator 5.052 does with the covergroup options.
//
//   $ verilator --binary --timing --coverage-user -Wno-fatal -o sim \
//         repro-cg-options.sv && ./obj_dir/sim
//
// -Wno-fatal because option.weight raises COVERIGN on purpose: that warning is
// half of what this file documents.
//
// Measured on 5.052 (2026-09-08):
//
//   option.at_least      RESPECTED in a coverpoint, IGNORED in the covergroup,
//                        and ignored WITHOUT a warning. Same source, same
//                        number, two different meanings depending on where the
//                        line sits. The worst of the four, because it is silent.
//   option.auto_bin_max  respected in both places. The default is 64.
//   option.weight        %Warning-COVERIGN, ignored and it says so.
//   type_option.merge_instances
//                        no observable effect: type-wide coverage
//                        (cg::get_coverage()) returns 0 either way, which is
//                        the known 5.052 gap. Use get_inst_coverage().
//
// The six expected numbers are asserted below, so a future Verilator that
// changes any of them ends this file in $fatal instead of printing OK. Like the
// other repros here, it is run by hand: `make matrix` only runs code/u*/run*.sh.
module top;
  bit [2:0] op;
  bit [7:0] v;

  // at_least = 3 written in the coverpoint: only the bin with 3 hits counts.
  covergroup cg_at_least_cp;
    cp: coverpoint op { option.at_least = 3; bins b[] = {[0:3]}; }
  endgroup

  // The same 3 written in the covergroup: it should mean the same thing.
  covergroup cg_at_least_cg;
    option.at_least = 3;
    cp: coverpoint op { bins b[] = {[0:3]}; }
  endgroup

  covergroup cg_auto_bin;  option.auto_bin_max = 4; cp: coverpoint v; endgroup
  covergroup cg_default;                            cp: coverpoint v; endgroup

  covergroup cg_weight;
    cp1: coverpoint op { option.weight = 0; bins b[] = {[0:3]}; }
    cp2: coverpoint v  { bins hi = {[128:255]}; }
  endgroup

  covergroup cg_merge;
    type_option.merge_instances = 1;
    cp: coverpoint op { bins b[] = {[0:3]}; }
  endgroup

  cg_at_least_cp a_cp = new();
  cg_at_least_cg a_cg = new();
  cg_auto_bin    abm  = new();
  cg_default     dfl  = new();
  cg_weight      w    = new();
  cg_merge       m1 = new(), m2 = new();

  // 0.05 of slack: the numbers are ratios of small integers (2/64 = 3.125),
  // not values to compare bit for bit.
  function automatic void check(string what, real got, real want);
    $display("  %-28s %6.2f %%   (esperado %0.2f)", what, got, want);
    if (got < want - 0.05 || got > want + 0.05)
      $fatal(1, "%s: %0.2f, esperaba %0.2f", what, got, want);
  endfunction

  initial begin
    // op = 0 once, op = 1 three times. op = 2 and 3 never.
    op = 0; a_cp.sample(); a_cg.sample();
    op = 1; repeat (3) begin a_cp.sample(); a_cg.sample(); end

    // Two of the 256 values of an 8-bit coverpoint.
    v = 8'h00; abm.sample(); dfl.sample();
    v = 8'h64; abm.sample(); dfl.sample();

    op = 0; w.sample(); v = 8'hC8; w.sample();

    // Each instance covers a different half.
    op = 0; m1.sample(); op = 1; m1.sample();
    op = 2; m2.sample(); op = 3; m2.sample();

    $display("Verilator 5.052, opciones de covergroup:");
    // 1 of 4 bins: only op = 1 reached the three hits.
    check("at_least en coverpoint",  a_cp.get_inst_coverage(), 25.0);
    // 2 of 4: the option did nothing, op = 0 counts with a single hit.
    check("at_least en covergroup",  a_cg.get_inst_coverage(), 50.0);
    // 2 of 4 automatic bins.
    check("auto_bin_max = 4",        abm.get_inst_coverage(),  50.0);
    // 2 of the 64 automatic bins Verilator makes by default.
    check("sin auto_bin_max",        dfl.get_inst_coverage(),   3.13);
    // 2 of 5 bins: weight = 0 did not drop cp1 out of the average.
    check("weight = 0 en cp1",       w.get_inst_coverage(),    40.0);
    // Type-wide coverage is 0 whatever merge_instances says.
    check("merge_instances (type)",  cg_merge::get_coverage(),  0.0);
    $display("OK");
    $finish;
  end
endmodule
