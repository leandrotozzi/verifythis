LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY three_cycle IS
   PORT( 
      A           : IN     unsigned ( 7 DOWNTO 0 );
      B           : IN     unsigned ( 7 DOWNTO 0 );
      clk         : IN     std_logic;
      reset_n     : IN     std_logic;
      start       : IN     std_logic;
      done_mult   : OUT    std_logic;
      result_mult : OUT    unsigned (15 DOWNTO 0)
   );
END three_cycle ;

architecture mult of three_cycle is
  signal a_int,b_int : unsigned (7 downto 0);          -- start pipeline
  signal mult1,mult2 : unsigned (15 downto 0);         -- pipeline registers
  signal done3,done2,done1,done_mult_int : std_logic;  -- pipeline the done signal
begin

  -- purpose: Three stage pipelined multiplier
  -- type   : sequential
  -- inputs : clk, reset_n, a,b
  -- outputs: result_mult
  multiplier: process (clk, reset_n)
  begin                                                -- process multiplier
    if reset_n = '0' then                              -- asynchronous reset (active low)
      done_mult_int <= '0';
      done3 <= '0';
      done2 <= '0';
      done1 <= '0';
      
      a_int <= (others => '0');
      b_int <= (others => '0');
      mult1 <= (others => '0');
      mult2 <= (others => '0');
      result_mult <= (others => '0');

    elsif rising_edge(clk) then 
      a_int <= a;
      b_int <= b;
      mult1 <= a_int * b_int;
      mult2 <= mult1;
      result_mult <= mult2;
      done3 <= start and (not done_mult_int);
      done2 <= done3 and (not done_mult_int);
      done1 <= done2 and (not done_mult_int);
      done_mult_int  <= done1 and (not done_mult_int);
      
    end if;
  end process multiplier;

  done_mult <= done_mult_int;

end architecture mult;