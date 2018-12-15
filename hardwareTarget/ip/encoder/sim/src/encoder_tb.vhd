-------------------------------------------------------------------------------
-- Dr. Kaputa
-- file io advanced tb demo
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use std.textio.all;

entity encoder_tb is
end encoder_tb;

architecture beh of encoder_tb is
  component encoder_top
  port(
    clk 		: in std_logic; 
	reset_n 	: in std_logic; 
	clr			: in std_logic;
    encoder_in	: in std_logic;
	count_out	: out std_logic_vector(31 downto 0)
    );
  end component;
  
  constant period           	: time := 10ns;                                              
  signal clk                	: std_logic := '0';
  signal reset_n            	: std_logic := '0';
  signal clr_std_logic      	: std_logic;
  signal encoder_in_std_logic   : std_logic;

  signal encoder_in    		: std_logic := '0';
  signal clr   				: std_logic := '0'; 
  signal count_out   		: std_logic_vector(31 downto 0);
  
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
    reset_n <= '1';
    wait;
end process; 

read_file: process is
  variable input_line       : line;
  variable next_time        : time;
  variable encoder_in       : bit;
  variable clr              : bit;
  file input_file           : text;
begin
  file_open(input_file,"input_encoder.txt",READ_MODE);
  readline(input_file,input_line);    -- strip off the header
  while not endfile(input_file) loop
    readline(input_file,input_line);
    -- read three fields from input file
    read(input_line,next_time);
    read(input_line,encoder_in);
    read(input_line,clr);

    encoder_in_std_logic <= to_stdulogic(encoder_in);
    clr_std_logic <= to_stdulogic(clr);

    wait for next_time - now;
  end loop;
  file_close(input_file);
  wait;
end process read_file;

uut: encoder_top 
  port map(
    clk 		 => clk,
    reset_n 	 => reset_n,
    clr			 => clr_std_logic,
    encoder_in	 => encoder_in_std_logic,
    count_out	 => count_out
  );
    
end architecture beh;