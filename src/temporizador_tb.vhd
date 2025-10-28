library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;
use work.all;
use ieee.numeric_std.all;

entity temporizador_tb is
end temporizador_tb;

architecture tb of temporizador_tb is 
    constant periodo: time := 10 ns;
    signal clk, nreset, listo: std_logic;
    siganl recarga: std_logic_vector(5 downto 0);
begin
    dut: entity temporizador 
    port map (
        recarga => recarga,
        clk => clk,
        nreset => nreset,
        listo => listo
    );
    clk_gen : process
    begin
        clk <= '1';
        wait for periodo/2;
        clk <= '0';
        wait for periodo/2;
    end process;
    evaluacion :process
    begin
        wait until rising_edge(clk);
        wait for periodo/4;
        nreset <= '0';
        recarga "001010";
        wait for 3*periodo;
        nreset <='1';
        finish;
    end process;
end tb;