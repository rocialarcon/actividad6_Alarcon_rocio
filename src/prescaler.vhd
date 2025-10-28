library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--genera un pulso cada preload +1 ciclo de reloj 
entity prescaler is
    port(
        nreset : in std_logic; --activo en 0
        clk : in std_logic;
        preload : in std_logic_vector (23 downto 0);
        tc : out std_logic
    );
end prescaler;

architecture arch of prescaler is
    signal cuenta_sig : unsigned(23 downto 0); --signal son nodos internos
    signal cuenta : unsigned(23 downto 0);
    signal cero : std_logic;
    signal carga : std_logic;
--registro 
begin
    registro : process (clk) --lista de sensibilidad, entradas que responde el registro
    begin 
        if rising_edge(clk) then --resing_edge es un flanco ascendente 
            cuenta <= cuenta_sig;
        end if;
    end process;
    
    tc <= cero;
    cero <= cuenta ?= 0; -- = devuelve un booleano ?= devuelve un std_logic
    carga <= not nreset or cero;
    cuenta_sig <= unsigned(preload) when carga else --preload es stdlogic entonces lo definimos como unsigned
                 cuenta - 1; 

end arch;