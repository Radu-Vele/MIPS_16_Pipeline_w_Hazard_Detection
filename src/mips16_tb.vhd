----------------------------------------------------------------------------------
-- Company: TUCN
-- Engineer: Radu-Augustin Vele
-- 
-- Create Date: 11/26/2022 06:28:36 PM
-- Design Name: 
-- Module Name: mips16_tb - Behavioral
-- Project Name: 
-- Target Devices: -
-- Tool Versions: 
-- Description: Testbench for MIPS16 simulation
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

entity mips16_tb is
end mips16_tb;

architecture Behavioral of mips16_tb is
-- Components
    component mips16_top_sim is
        Port ( 
            clk: in std_logic;
            reset: in std_logic;
            en_pc: in std_logic;
            en_mem_wr: in std_logic; 
            en_rf_wr: in std_logic
        );
    end component;

-- Test inputs
    signal gen_clk: std_logic := '0';
    signal gen_reset: std_logic;
begin
    
    gen_reset <= '1', '0' after 15ns;
    
    gen_clk <= not gen_clk after 20ns;
    
    MIPS_connect: mips16_top_sim port map (
        clk => gen_clk,
        reset => gen_reset,
        en_pc => '1',
        en_mem_wr => '1',
        en_rf_wr => '1'
    );

end Behavioral;
