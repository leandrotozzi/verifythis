<!-- es-sha: 029325cd0abc -->
## Exercise · Day 2

#### *A tester that only multiplies*

`cd code/ejercicios/d2 && bash run.sh`
<!-- .element: class="comando" -->

- Extend `tester`, redefine `get_op()`, and have the testbench instantiate it
- It is going to carry on sending random operations. **That is where the exercise starts**
- Hint: polymorphism

Note:
The exercise is set up so that they fail: `get_op()` in the object-based testbench is not
virtual, so `execute()` always calls the base class's one even if the
object is a `mult_tester`. Until they add `virtual`, inheritance does not
show — and that is understood much better when you suffer it than when you read it.
It is on purpose the same problem as the day 3 exercise: there they are going to solve it
with the factory, and only then do you see what the factory is for.
