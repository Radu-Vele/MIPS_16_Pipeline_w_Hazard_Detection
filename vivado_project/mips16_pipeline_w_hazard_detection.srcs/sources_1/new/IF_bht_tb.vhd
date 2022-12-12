----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/12/2022 08:59:02 PM
-- Design Name: 
-- Module Name: IF_bht_tb - Behavioral
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

entity IF_bht_tb is

end IF_bht_tb;

architecture Behavioral of IF_bht_tb is

    component IF_unit is 
        Port (
            clk100MHz: in std_logic;
            jump_addr: in std_logic_vector(15 downto 0);
            branch_addr: in std_logic_vector(15 downto 0);
            jump_ctrl: in std_logic;
            PCsrc_ctrl: in std_logic;
            reset_pc: in std_logic;
            enable_pc: in std_logic; 
            instruction: out std_logic_vector(15 downto 0);
            pc_plus_one: out std_logic_vector(15 downto 0);
            -- *** BHT Add-on
            ID_prv_pc: in std_logic_vector(3 downto 0);
            ID_Flush: in std_logic;
            ID_Branch_Taken: in std_logic;
            ID_Branch_Instruction: in std_logic
        );
    end component;

    signal clk100MHz: std_logic := '0';
    signal reset_pc: std_logic;
    signal ID_Flush: std_logic;
    signal ID_Branch_Instruction: std_logic;
    signal ID_Branch_Taken: std_logic;
    signal branch_addr: std_logic_vector(15 downto 0);
    signal instruction: std_logic_vector(15 downto 0);
    signal pc_plus_one: std_logic_vector(15 downto 0);
    signal ID_prv_pc: std_logic_vector(3 downto 0);


begin
    
    reset_pc <= '1', '0' after 5ns;
    clk100MHz <= not clk100MHz after 10ns;
    
    -- scenario: an infinite loop
    -- 0: no branch T0 - after 10ns
    -- 1: no branch T1 - after 30 ns
    -- 2: branch to 1 T2 - after 50 ns
    -- 3: instruction that we don't want to be executed T3 - after 70 ns
    
    branch_addr <= x"0000", x"0001" after 70 ns;
    ID_prv_pc <= "0000" after 10ns, "0001" after 30 ns, "0010" after 50 ns, "0011" after 70ns;
    ID_Flush <= '0', '1' after 70ns, '0' after 90ns, '1' after 150ns, '0' after 170ns;
    ID_Branch_Taken <= '0', '1' after 70ns, '0' after 90ns, '1' after 150ns, '0' after 170ns;
    ID_Branch_Instruction <= '0', '1' after 70 ns, '0' after 90ns, '1' after 150ns, '0' after 170ns;

    uut: IF_unit port map (
        clk100MHz => clk100MHz,
        jump_addr => x"0000",
        branch_addr => branch_addr,
        jump_ctrl => '0',
        PCsrc_ctrl => '0',
        reset_pc => reset_pc,
        enable_pc => '1', 
        instruction => instruction,
        pc_plus_one => pc_plus_one,
        -- *** BHT Add-on
        ID_prv_pc => ID_prv_pc,
        ID_Flush => ID_Flush, 
        ID_Branch_Taken => ID_Branch_Taken,
        ID_Branch_Instruction => ID_Branch_Instruction
    );

end Behavioral;
