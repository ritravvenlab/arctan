-------------------------------------------------------------------------------
-- Dr. Kaputa
-- blink test bench
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity blink_tb is
end blink_tb;

architecture arch of blink_tb is

component blink is
  generic (
    max_count       : integer := 25000000
  );
  port (
    clk             : in  std_logic; 
    reset           : in  std_logic;
    output          : out std_logic
  );  
end component;  

signal output       : std_logic;
constant period     : time := 20ns;                                              
signal clk          : std_logic := '0';
signal reset        : std_logic := '1';

begin

-- clock process
clock: process
  begin
    clk <= not clk;
    wait for period/2;
end process; 
 
-- reset process
async_reset: process
  begin
    wait for 2 * period;
    reset <= '0';
    wait;
end process; 

uut: blink  
  generic map (
    max_count => 4
  )
  port map(
    clk       => clk,
    reset     => reset,
    output    => output
  );
end arch;