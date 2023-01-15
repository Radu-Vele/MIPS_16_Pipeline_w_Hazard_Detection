----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/12/2022 08:19:38 PM
-- Design Name: 
-- Module Name: bht_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity bht_tb is

end bht_tb;

architecture Behavioral of bht_tb is

    component branch_history_table is
        Port ( 
            clk: in std_logic; 
            address: in std_logic_vector(3 downto 0); -- current pc address
            update_data: in std_logic_vector(15 downto 0); -- new target address
            write_address: in std_logic_vector(3 downto 0); -- the pc address that corresponds to the new target
            inc_predictor: in std_logic;
            branch_instruction: in std_logic;
            flush: in std_logic;
            MSB_Pred: out std_logic;
            predicted_target: out std_logic_vector(15 downto 0)
        );
    end component;
    
    signal clk: std_logic := '0';
    signal address: std_logic_vector(3 downto 0); 
    signal update_data: std_logic_vector(15 downto 0); -- new target address
    signal write_address: std_logic_vector(3 downto 0); -- the pc address that corresponds to the new target
    signal inc_predictor: std_logic;
    signal branch_instruction: std_logic;
    signal flush: std_logic;
    signal MSB_Pred: std_logic;
    signal predicted_target: std_logic_vector(15 downto 0);

begin
    
    clk <= not clk after 10ns; -- period of 20 ns
    
    -- scenario:
    -- nothing impactful in ID (clk 0)
    -- branch in ID (clk 1)
    
    address <= "0001", "0010" after 20ns, "0011" after 40ns;
    update_data <= x"0000", x"0005" after 20ns; 
    write_address <= "0000", "0001" after 20 ns;
    inc_predictor <= '0', '1' after 20 ns;
    branch_instruction <= '0', '1' after 20 ns;
    flush <= '0', '1' after 20 ns;

    uut: branch_history_table port map (
        clk => clk,
        address => address,
        update_data => update_data,
        write_address => write_address,
        inc_predictor => inc_predictor, 
        branch_instruction => branch_instruction,
        flush => flush,
        MSB_Pred => MSB_Pred,
        predicted_target => predicted_target
    );


end Behavioral;
