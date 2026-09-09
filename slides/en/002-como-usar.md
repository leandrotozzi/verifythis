<!-- es-sha: 0977fd454944 -->
<!-- .slide: id="como-usar" -->

## How to use this course

#### *Especially if you are taking it on your own*

- **What you need to know first:** Verilog or VHDL, and having simulated
  something. Object-oriented programming is **not** required — day 2 is exactly that
- It is **seven days of class**, of 4 to 5 and a half hours — **≈ 30 h 30**, and each
  agenda carries its own. Plus an **optional day 8**, after the wrap-up. On your own,
  count double: half of it goes into running the examples, and that is the half that teaches
- <kbd>s</kbd> opens the **presenter notes** in another window ·
  <kbd>n</kbd> shows them down here, without leaving the page. That is where what the
  instructor would say out loud lives: the classic trap, the reason behind the number, the
  mistake everybody makes the first time. **Do not skip them**
- Every day closes with a **review** of clickable options and with a
  **self-checking exercise**: `cd code/ejercicios/dN && bash run.sh`
- **Run the examples**: `make u4/tests` runs one, `make u4` the whole unit. A verification
  course that is only read is worth nothing. A UVM example takes **a minute and a half the
  first time and fifteen seconds the second**, if you have `ccache` installed — and if you
  do not have Linux, the short road is GitHub Codespaces, which brings it already
- <kbd>0</kbd>–<kbd>8</kbd> jump to the cover and to each day ·
  <kbd>i</kbd> opens the index · <kbd>Esc</kbd> shows the whole deck · and the
  corner ribbon unfolds the cheat sheet of the day
- **If you are on your own, read the book:** `en/libro/day1.html` is this same course
  straight through, with the notes already inside the text. Keep the deck alongside for
  the reviews
- **When something does not work, go to the end:** the appendices *The debug toolbox*
  —what to look at for each symptom— and *The nineteen silent traps* —everything that
  compiles, runs and lies—. Those are the two slides to print

Note:
If you are teaching the course, this slide is skipped with the 1 key.
It is here because most people who open this will not have an
instructor alongside, and without the presenter notes half the material gets lost
— and that half is also the hardest one to reconstruct by reading the code.
