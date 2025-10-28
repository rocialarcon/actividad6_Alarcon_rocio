library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity temporizador is
    -- generic (TWIDTH : integer := 6);
    port(
        recarga : in std_logic_vector(5 downto 0);
        clk_1hz, nreset, tmr_reset : in std_logic;
        listo : out std_logic;
        hab: in std_logic
    );
end temporizador;

architecture arch of temporizador is
    signal est_act, est_sig, est_sig1: unsigned(5 downto 0);
begin
    registro : process(clk_1hz, nreset)
    begin
        if nreset = '0' then 
        est_act <= (others => '0');
        elsif rising_edge(clk_1hz) then
            est_act <= est_sig;
        end if;
    end process;
 --datapath
 listo <= '1' when est_act = 1  else --salida
               '0';
  est_sig <= unsigned(recarga) when tmr_reset else
             est_act when not hab else
             unsigned(recarga) when est_act = 0 else
                est_act - 1 ;
end arch;
