// Minimal repro: what a `fork ... join_none` copies from the loop index, and when.
//
//   $ verilator --binary --timing --top-module top -o sim repro-fork-automatic.sv
//   ./obj_dir/sim
//
// Why this file exists. The trap slide of the threads section --
// slides/es/110-threads.md and its English twin -- shows the `for` index inside
// a `fork` in three variants and closes by claiming, with the seal of a
// measurement on Verilator 5.052, that the three lines above print 3 3 3,
// 0 1 2 and 0 1 2. The third one, the
// `automatic int k = i;` written as the FIRST LINE of a `fork begin ... end
// join_none`, prints 3 3 3 here: the copy is not made when the fork is
// scheduled. So the slide taught a workaround that does not work around
// anything in the only simulator of the course, and it taught it with the seal
// of a measurement -- which is worse than not measuring at all, because nobody
// re-checks a number that says it was measured.
//
// The form the LRM blesses (IEEE 1800-2017, 9.3.2) is the declaration inside
// the `fork` ITSELF, with no `begin`/`end` around it, and that one does print
// 0 1 2. That is the difference this file pins, so that the slide has a source
// instead of a claim: the block on the slide is code pasted into markdown, not
// a {{code:}}, so until this file existed nobody ever compiled it.
//
// Measured on 5.052 (2026-09-10), deterministic, three runs:
//
//   A  int i outside the for, fork with no copy       3 3 3
//   B  int j declared in the for                      0 1 2
//   C  fork begin automatic int k = i; ... end        3 3 3   <- the slide says 0 1 2
//   D  fork automatic int k = i; ... join_none (LRM)  0 1 2
//
// The four expected strings are asserted below, so a future Verilator that
// changes any of them ends this file in $fatal instead of printing OK -- and
// the day C starts printing 0 1 2 is the day the slide can go back to what it
// used to say. Like the other repros here, `make repros` runs it. Seconds.
module top;
  int    i;
  string got;

  // Each variant leaves its three digits glued together in `got`. The whole
  // string is compared, not digit by digit, because the ORDER is part of what
  // is at stake: "012" and "210" would both be "0 1 2" if we only counted.
  function automatic void check(string what, string want);
    $display("  %-48s %-4s (expected %s)", what, got, want);
    if (got != want) $fatal(1, "%s: printed '%s', expected '%s'", what, got, want);
    got = "";
  endfunction

  initial begin
    $display("Verilator 5.052, the for index inside the fork:");

    // cb: las-cuatro-variantes
    // A -- a single variable, shared by the three threads. A join_none runs
    // nothing: it schedules. By the time the three run, the for is over.
    for (i = 0; i < 3; i++)
      fork got = {got, $sformatf("%0d", i)}; join_none
    wait fork;
    check("int i outside the for, no copy", "333");

    // B -- declared inside the for: one per pass, and nothing to copy.
    for (int j = 0; j < 3; j++)
      fork got = {got, $sformatf("%0d", j)}; join_none
    wait fork;
    check("int j declared in the for", "012");

    // C -- the slide's one: the automatic as the first line of a begin/end.
    // Here the copy is NOT made when the fork is scheduled, so k reads the same
    // i that A does and gives the same answer as A. This is the finding.
    for (i = 0; i < 3; i++)
      fork begin
        automatic int k = i;
        got = {got, $sformatf("%0d", k)};
      end join_none
    wait fork;
    check("fork begin automatic k = i; end  (the slide's)", "333");

    // D -- the LRM 9.3.2 one: the automatic declared in the fork, no begin/end.
    // Same workaround, written where the LRM puts it, and this one does copy.
    for (i = 0; i < 3; i++)
      fork
        automatic int k = i;
        got = {got, $sformatf("%0d", k)};
      join_none
    wait fork;
    check("fork automatic k = i;  no begin/end (LRM 9.3.2)", "012");
    // cb: end

    $display("OK");
    $finish;
  end
endmodule
