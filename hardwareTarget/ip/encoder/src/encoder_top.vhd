-------------------------------------------------------------------------------
-- John Niemynski
-- encoder_top.vhd
-- Encoder module [behavioral]
	-- Consists of a synchronizer with a rising edge detector
	-- Counts rising edges and outputs them to a axi_lite register
	-- internal count value resets on axi_lite register == 0 
-- 4/1/2018
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;      
use IEEE.numeric_std.all;

entity encoder_top is 
  port (
	clk 		: in std_logic; 
	reset_n 	: in std_logic; 
	clr			: in std_logic;
    encoder_in	: in std_logic;
	count_out	: out std_logic_vector(31 downto 0)
  );
end encoder_top;

architecture beh of encoder_top is
-- signal declarations
signal encoder_in_q     : std_logic;
signal encoder_in_qq    : std_logic;
signal encoder_in_qqq   : std_logic;
signal count			: std_logic_vector(31 downto 0) := (others => '0');
signal edge 			: std_logic;

begin 
synchronizer: process(reset_n,clk,encoder_in)
  begin
    if reset_n = '0' then
      encoder_in_q     <= '1';
      encoder_in_qq    <= '1';
    elsif rising_edge(clk) then
      encoder_in_q   <= encoder_in;
      encoder_in_qq  <= encoder_in_q;
    end if;
end process;  

rising_edge_detector: process(reset_n,clk,encoder_in_qq)
  begin
    if reset_n = '0' then
      edge       	   <= '0';
      encoder_in_qqq   <= '1';
    elsif rising_edge(clk) then
      encoder_in_qqq   <= encoder_in_qq;
      edge <= (encoder_in_qq xor encoder_in_qqq) and encoder_in_qq;
    end if;
end process; 	

counter: process(reset_n, clk, edge)
begin 
	if (reset_n = '0' or clr = '1') then
		count <= (others => '0');
		count_out <= (others => '0');
	elsif rising_edge(clk) then 
		if(edge = '1') then
			count <= std_logic_vector(unsigned(count) + 1);
		end if;
		count_out <= count;
	end if;
end process; 
end beh; 