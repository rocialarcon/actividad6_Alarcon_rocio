library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity controlador_sem is 

port(
    -- entradas de control
    clk_1hz: in std_logic;
    nreset: in std_logic;
    --entradas de sensores y pulsadores
    peaton_1, peaton_2 : in std_logic;  --"1" -> direccion norte sur
    emergencia_1, emergencia_2 : in std_logic;--"2" -> direccion este oeste
    --control del temporizador 
    listo : in std_logic;
    tmr_reset : out std_logic;
    inicio : out std_logic; --hab para el timer
    recarga : out std_logic_vector(5 downto 0); --recarga de tiempo al timer
    --salida de luces 
    luces_1 : out std_logic_vector(1 downto 0);
    luces_2 : out std_logic_vector(1 downto 0)
);
end controlador_sem;
architecture arch of controlador_sem is
    --memoria
    signal est_act, est_sig : std_logic_vector(3 downto 0);
    signal st_peaton_1 : std_logic := '0'; 
    signal st_peaton_2 : std_logic := '0';
    signal clr_peaton_1, clr_peaton_2 : std_logic;
    -- salida de luces
    constant verde : std_logic_vector(1 downto 0) := "01";
    constant amarillo : std_logic_vector(1 downto 0) := "11";
    constant rojo : std_logic_vector(1 downto 0) := "10";
    --tiempos
    constant t_10s : std_logic_vector(5 downto 0) :="001001";
    constant t_50s : std_logic_vector(5 downto 0) := "110001";
    --estados
    constant verde_1    : std_logic_vector(3 downto 0) := "0000";
    constant amarillo_1 : std_logic_vector(3 downto 0) := "0001";
    constant verde_a1   : std_logic_vector(3 downto 0) := "0010";
    constant emer_1     : std_logic_vector(3 downto 0) := "0011";
    constant cancela_1  : std_logic_vector(3 downto 0) := "0100";
    constant verde_2    : std_logic_vector(3 downto 0) := "0101";
    constant amarillo_2 : std_logic_vector(3 downto 0) := "0110";
    constant verde_a2   : std_logic_vector(3 downto 0) := "0111";
    constant emer_2     : std_logic_vector(3 downto 0) := "1000";
    constant cancela_2  : std_logic_vector(3 downto 0) := "1001";

    signal flag_emer_1_act, flag_emer_1_sig: std_logic := '0';
    signal flag_emer_2_act, flag_emer_2_sig : std_logic := '0';
    
begin
-- registro
    memoria_est : process(clk_1hz, nreset)
    begin
        if nreset = '0' then
            est_act <= verde_1;
         elsif rising_edge(clk_1hz) then
            est_act <= est_sig;
        end if;
    end process;
--logica del estado siguiente 
les : process(all)
begin
    est_sig <= est_act;
    inicio <= '0';
    recarga <= "000000";
    tmr_reset <= '0';
    clr_peaton_1 <= '0';
    clr_peaton_2 <= '0';
    flag_emer_1_sig <= flag_emer_1_act;
    flag_emer_2_sig <= flag_emer_2_act;
 case est_act is
    when verde_1 =>
     recarga <= t_50s;
     inicio <= '1';
     if emergencia_1 then     
        est_sig <= emer_1;
        elsif listo and st_peaton_1 then
            est_sig <= verde_a1;
        elsif emergencia_2 and not emergencia_1 and not st_peaton_1 then
            est_sig <= cancela_1;
        elsif listo and not st_peaton_1 and not emergencia_1 then
            est_sig <= amarillo_1;
     end if;
    when verde_a1 =>
     recarga <= t_50s;
     inicio <= '1';
     clr_peaton_1 <= '1';
     if listo then
        est_sig <= amarillo_1;
     end if;
    when amarillo_1 =>
    if flag_emer_1_act then
        tmr_reset <= '1';
        flag_emer_1_sig <= '0';
    end if ;
     recarga <= t_10s;
     inicio <= '1';
     if listo then 
        est_sig <= verde_2;
        elsif emergencia_1 then
            est_sig <= emer_1;
     end if;
    when emer_1 =>
     inicio <= '0';--no esta habilitado el contador 
     flag_emer_1_sig  <= '1';
     if not emergencia_1 then
        est_sig <= amarillo_1; -- en otro caso se mantiene en estado por defecto
     end if;
    when cancela_1 =>
     tmr_reset <= '1'; --reset del contador
     recarga <= t_10s;
     inicio <= '1';
     if listo then
        est_sig <= emer_2;
     end if ;
    when verde_2 =>
     recarga <= t_50s;
     inicio <= '1';
     if emergencia_2 then
            est_sig <= emer_2;
        elsif listo and st_peaton_2 then
            est_sig <= verde_a2;
        elsif emergencia_1 and not emergencia_2 and not st_peaton_2 then
            est_sig <= cancela_2;
        elsif listo and not st_peaton_2 and not emergencia_2 then 
            est_sig <= amarillo_2;
     end if;
    when verde_a2 =>
     recarga <= t_50s;
     inicio <= '1';
     clr_peaton_2 <= '1';
     if listo then
        est_sig <= amarillo_2;
     end if ;
    when amarillo_2 =>
    if flag_emer_2_act then
        tmr_reset <= '1';
        flag_emer_2_sig <= '0';
    end if ;
     recarga <= t_10s;
     inicio <= '1';
     if listo then
        est_sig <= verde_1;
        elsif emergencia_2 then
            est_sig <= emer_2;
    end if;
    when emer_2 =>
     inicio <= '0';
     flag_emer_2_sig <= '1';
     if not emergencia_2 then
        est_sig <= amarillo_2;
     end if;
    when cancela_2 =>
    tmr_reset <= '1'; --reset del contador
    recarga <= t_10s;
    inicio <= '1';
    if listo then
        est_sig <= emer_1;
    end if ;
    when others =>
    est_sig <= verde_1;
    end case;
end process les;
ls : process(all)
 begin 
 case est_act is
    when verde_1 =>
    luces_1 <= verde;
    luces_2 <= rojo;
    when amarillo_1 =>
    luces_1 <= amarillo;
    luces_2 <= rojo;
    when verde_a1 =>
    luces_1 <= verde;
    luces_2 <= rojo;
    when emer_1 =>
    luces_1 <= verde;
    luces_2 <=rojo;
    when cancela_1 =>
    luces_1 <= amarillo;
    luces_2 <= rojo;
    when verde_2 =>
    luces_1 <= rojo;
    luces_2 <= verde;
    when amarillo_2 =>
    luces_1 <= rojo;
    luces_2 <= amarillo;
    when verde_a2 =>
    luces_1 <= rojo;
    luces_2 <= verde;
    when emer_2 =>
    luces_1 <= rojo;
    luces_2 <= verde;
    when cancela_2 =>
    luces_1 <= rojo;
    luces_2 <= amarillo;
    when others =>
    luces_1 <= rojo;
    luces_2 <= rojo;
 end case ;
end process ls;
memoria_peaton_1 : process(clk_1hz, nreset)
begin
    if nreset = '0' then
        st_peaton_1 <= '0';
        elsif rising_edge(clk_1hz)  then
            if clr_peaton_1 = '1' then
                st_peaton_1 <= '0';
                elsif peaton_1 then
                    st_peaton_1 <= '1';
            end if ;
    end if ;
end process;
memoria_peaton_2 : process(clk_1hz, nreset)
begin
    if nreset = '0' then
        st_peaton_2 <= '0';
        elsif rising_edge(clk_1hz)  then
            if clr_peaton_2 = '1' then
                st_peaton_2 <= '0';
                elsif peaton_2 then
                    st_peaton_2 <= '1';
            end if ;
    end if ;
 end process;
flags : process(clk_1hz, nreset)
begin
    if nreset then
        flag_emer_1_act <= '0';
        flag_emer_2_act <= '0';
        elsif rising_edge(clk_1hz) then
            flag_emer_1_act <= flag_emer_1_sig;
            flag_emer_2_act <= flag_emer_2_sig;
    end if;
end process;
end arch; 