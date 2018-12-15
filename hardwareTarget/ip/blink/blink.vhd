-------------------------------------------------------------------------------
-- Dr. Kaputa
-- blink led demo
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;      

entity blink is
  generic (
    max_count       : integer := 250000
  );
  port (
    clk             : in  std_logic; 
    reset_n         : in  std_logic;
    blink_out       : out std_logic
  );  
end blink;  

architecture beh of blink  is

signal count_sig    : integer range 0 to max_count := 0;
signal output_sig   : std_logic;

begin
process(clk,reset_n)
  begin
    if (reset_n = '1') then 
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
  
  blink_out <= output_sig;
end beh;