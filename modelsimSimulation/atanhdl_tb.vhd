-------------------------------------------------------------------------------
-- atanhdl_tb.vhd
-- John Niemynski
-- Testbench for cordic atan approximation 
-- from HDL generated from simulink model
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use std.textio.all;
use ieee.std_logic_textio.ALL;

entity atanhdl_tb is
end atanhdl_tb;

architecture beh of atanhdl_tb is
  component gcordicAtan
  port(
    clk 		      : in  std_logic; 
	reset   	    : in  std_logic; 
	clk_enable		: in  std_logic;
    In1           : in  std_logic_vector(15 downto 0);
	In2      	    : in  std_logic_vector(15 downto 0);
    ce_out        : out std_logic;
    Out1          : out std_logic_vector(15 downto 0)
    );
  end component;
  
  constant period           	: time := 10 ns;                                              
  signal clk                	: std_logic := '0';
  signal reset              	: std_logic := '1';
  signal clk_enable           : std_logic; 
  signal In1                  : std_logic_vector(15 downto 0):=(OTHERS=>'0');
  signal In2                  : std_logic_vector(15 downto 0):=(OTHERS=>'0');
  signal ce_out               : std_logic;
  signal Out1                 : std_logic_vector(15 downto 0);

  
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
    clk_enable <= '1';
    reset <= '1';
    wait for 2 * period;
    reset <= '0';
    wait;
end process; 

readWrite_file: process is
  variable input_lineA      : line;
  variable input_lineB      : line;
  variable output_line      : line;
  variable ina              : std_logic_vector(15 downto 0);
  variable inb              : std_logic_vector(15 downto 0);
  file ina_file             : text;
  file inb_file             : text;
  file out_file             : text;
begin
  file_open(ina_file,"atanInaData.txt", READ_MODE);
  file_open(inb_file,"atanInbData.txt", READ_MODE);
  file_open(out_file,"atanVHDLoutData.txt", WRITE_MODE);
  wait for 2*period;
  while not endfile(inb_file) loop
    readline(ina_file, input_lineA);
    readline(inb_file, input_lineB);
    -- read three fields from input file
    read(input_lineA,ina);
    read(input_lineB,inb);

    In1 <= ina;
    In2 <= inb;

    write(output_line,Out1);
    writeline(out_file, output_line);
	wait for period; -- wait for long enough for output to settle
  end loop;
  file_close(ina_file);
  file_close(inb_file);
  file_close(out_file);
  wait;
end process readWrite_file;

uut: gcordicAtan 
  port map(
    clk 		 => clk,
    reset 	 	 => reset,
    clk_enable	 => clk_enable,
    In1	         => In1,
    In2	         => In2,
    ce_out       => ce_out,
    Out1         => Out1
  );
    
end architecture beh;