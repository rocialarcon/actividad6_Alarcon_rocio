library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity top is 
port (
    clk : in std_logic;
    nreset : in std_logic;

    peaton_1     : in std_logic;
    peaton_2     : in std_logic;
    emergencia_1 : in std_logic;
    emergencia_2 : in std_logic;

    verde_1      : out std_logic;
    amarillo_1   : out std_logic;
    rojo_1       : out std_logic;
    verde_2      : out std_logic;
    amarillo_2   : out std_logic;
    rojo_2       : out std_logic;

    confirmacion_peaton_1 : out std_logic;
    confirmacion_peaton_2 : out std_logic;
    confirmacion_emergencia_1 : out std_logic;
    confirmacion_emergencia_2 : out std_logic;
    cruce_peaton_1 : out std_logic;
    cruce_peaton_2 : out std_logic
);
end top;

architecture arch of top is
    --controlador
    signal clk_1hz : std_logic;
    signal listo   : std_logic;
    signal luces_1 : std_logic_vector(1 downto 0);
    signal luces_2 : std_logic_vector(1 downto 0);
    --temporizador
    signal recarga : std_logic_vector(5 downto 0);
    signal tmr_reset : std_logic;
    signal inicio : std_logic;
    --prescaler
    signal preload : std_logic_vector (23 downto 0);
    constant divisor : integer := 12000000/6;

begin
 U1: entity prescaler 
 port map (
    nreset => nreset,
    clk => clk,
    preload => preload,
    tc => clk_1hz);
 preload <= std_logic_vector(to_unsigned(divisor-1,24));
 U2: entity temporizador 
 port map (
    clk_1hz => clk_1hz,
    nreset => nreset,
    tmr_reset => tmr_reset,
    recarga => recarga,
    listo => listo,
    hab => inicio);

 U3: entity controlador_sem 
 port map (
    clk_1hz => clk_1hz,
    nreset => nreset,
    peaton_1 => peaton_1,
    peaton_2 => peaton_2,
    emergencia_1 => emergencia_1,
    emergencia_2 => emergencia_2,
    listo => listo,
    tmr_reset => tmr_reset,
    inicio => inicio,
    recarga => recarga,
    luces_1 => luces_1,
    luces_2 => luces_2,
    cruce_peaton_1 => cruce_peaton_1,
    cruce_peaton_2 => cruce_peaton_2
    );
-- CALLE 1
verde_1    <= '1' when luces_1 = "01" else '0';
amarillo_1 <= '1' when luces_1 = "11" else '0';
rojo_1     <= '1' when luces_1 = "10" else '0';

-- CALLE 2
verde_2    <= '1' when luces_2 = "01" else '0';
amarillo_2 <= '1' when luces_2 = "11" else '0';
rojo_2     <= '1' when luces_2 = "10" else '0';

--emergencia
confirmacion_emergencia_1 <= emergencia_1;
confirmacion_emergencia_2 <= emergencia_2;
--peatones
confirmacion_peaton_1 <= peaton_1;
confirmacion_peaton_2 <= peaton_2;
end arch;
