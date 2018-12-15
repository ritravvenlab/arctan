-------------------------------------------------------------------------------
-- Dr. Kaputa
-- blink led demo
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;      

entity blink is
  generic (
    max_count       : integer := 25000000
  );
  port (
    clk             : in  std_logic; 
    reset           : in  std_logic;
    output          : out std_logic
  );  
end blink;  

architecture beh of blink  is

signal count_sig    : integer range 0 to max_count := 0;
signal output_sig   : std_logic;

begin
process(clk,reset)
  begin
    if (reset = '1') then 
      count_sig <= 0;
      output_sig <= '0';
    elsif (clk'event and clk = '1') then
      if (count_sig = max_count) then
        count_sig <= 0;
        output_sig <= not output_sig;
      else
        count_sig <= count_sig + 1;
      end if; 
    end if;
  end process;
  
  output <= output_sig;
end beh;