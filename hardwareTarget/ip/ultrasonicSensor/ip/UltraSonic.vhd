--Serge_Louis
--UltraSonic.vhd

Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity UltraSonic is
  port (
    clk               : IN std_logic;
    reset_n           : IN std_logic;
    sensor_enable     : IN std_logic;
    echo_pin          : IN std_logic;
    trigger_pin       : OUT std_logic;
    distance_data     : OUT std_logic_vector(31 downto 0)
  );
end entity UltraSonic;

Architecture st of UltraSonic is 
constant PULSE        : integer := 58;  -- speed of signal in air
constant CLK_TIME     : integer := 20; -- time of clock ticks (nanoseconds)
constant cycle_10_uS  : integer := 500; -- 10 uS in clock ticks.

signal tick_counter_started : std_logic;
signal distance_ready : std_logic;
signal trig_done      : std_logic;
signal dff_trigger    : std_logic;
signal meta_trigger   : std_logic;
signal dff_echo       : std_logic;
signal meta_echo      : std_logic;
signal time_count     : std_logic_vector(31 downto 0);



Begin
  
  -- # Metastability Process
  Meta : process( clk, reset_n )
    Begin
      if( reset_n = '0' ) then
        dff_trigger <= '0';
        dff_echo <= '0';
        trigger_pin <= '0';
        meta_echo <= '0';
      elsif( clk'event and clk = '1' ) then
        if( sensor_enable = '1' ) then
          dff_trigger <= meta_trigger;
          trigger_pin <= dff_trigger;
          meta_echo <= dff_echo;
          dff_echo <= echo_pin;
        elsif( sensor_enable = '0' ) then
          trigger_pin <= '0';
          dff_trigger <= '0';
          dff_echo <= '0';
          meta_echo <= '0';
        end if;
      end if;
    end process;
  
  -- # Pulse Process
  Pulse_trigger : process ( clk, reset_n )
    Begin
      if( reset_n = '0' ) then
        meta_trigger <= '0';
      elsif( clk'event and clk = '1' ) then
        if ( sensor_enable = '1' ) then
          if( trig_done = '1' ) then
            meta_trigger <= '1';
          elsif( trig_done = '0' ) then
            meta_trigger <= '0'; 
          end if;
        end if;
      end if;
    end process;

  -- # Pulse count process
  Pulse_count : process( clk, reset_n )
    variable counter : integer;
    Begin
      if( reset_n = '0' ) then
        counter := 0;
        trig_done <= '1';
      elsif( clk'event and clk = '1' ) then
        if ( sensor_enable = '1' ) then 
          counter := counter + 1;
          if ( counter = cycle_10_uS ) then
            trig_done <= '0';
          end if;
        else
          counter := 0;
          trig_done <= '1';
        end if;
      end if;
    end process; 
    
  -- # Countertick process
  Tick_Count : process( clk, reset_n )
    variable tick_counter : integer;
    Begin
      if( reset_n = '0' ) then
        tick_counter := 0;
        tick_counter_started <= '1';
        distance_ready <= '1';
      elsif ( clk'event and clk = '1') then
        if ( sensor_enable = '1' ) then
          if ( trig_done = '0' and meta_echo = '1') then
            tick_counter := tick_counter + 1;
            tick_counter_started <= '0';
          elsif( trig_done = '1' ) then
            tick_counter := 0;
            tick_counter_started <= '1';
            distance_ready <= '1';
          end if;
          
          if (tick_counter_started = '0' and meta_echo = '0') then
            distance_ready <= '0';
            tick_counter_started <= '1';
          end if;
        end if;
      end if;
      time_count <= std_logic_vector(to_unsigned(tick_counter, time_count'length));
    end process;
    
  -- # Distance process
  Deter : process (clk, reset_n)
   variable int_dist     : integer;
   variable total_dist   : integer;
    Begin
      if( reset_n = '0' )then
        distance_data <= (others => '0');
      elsif( clk'event and clk = '1' ) then
        if( distance_ready = '0' ) then
          int_dist := to_integer( unsigned( time_count ) );
          --int_dist := int_dist*CLK_TIME;
          --int_dist := int_dist/1000;
          --total_dist := int_dist/PULSE;
		  total_dist := int_dist;
          distance_data <= std_logic_vector(to_unsigned(total_dist, distance_data'length));
        end if;
      end if;
    end process;  
      
end st;  