----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/04/2022 11:06:23 PM
-- Design Name: 
-- Module Name: ex_fwd_tb - Behavioral
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


entity ex_fwd_tb is

end ex_fwd_tb;

architecture Behavioral of ex_fwd_tb is
    component EX_fwd_unit is
        Port (
            EX_MEM_RegWrite: in std_logic;
            MEM_WB_RegWrite: in std_logic;
            EX_MEM_RegDst: in std_logic_vector(2 downto 0);
            MEM_WB_RegDst: in std_logic_vector(2 downto 0);
            ID_EX_Rs: in std_logic_vector(2 downto 0);
            ID_EX_Rt: in std_logic_vector(2 downto 0);
            ForwardA: out std_logic_vector (1 downto 0);
            ForwardB: out std_logic_vector (1 downto 0)
        );
    end component;
    
    signal EX_MEM_RegWrite: std_logic;
    signal MEM_WB_RegWrite: std_logic;
    signal EX_MEM_RegDst: std_logic_vector(2 downto 0);
    signal MEM_WB_RegDst: std_logic_vector(2 downto 0);
    signal ID_EX_Rs: std_logic_vector(2 downto 0);
    signal ID_EX_Rt: std_logic_vector(2 downto 0);
    signal ForwardA: std_logic_vector (1 downto 0);
    signal ForwardB: std_logic_vector (1 downto 0);
    
begin
    
    -- scenario: no hazard -> forward from previous x 2 -> forward from the one before the previous
    EX_MEM_RegWrite <= '0', '1' after 10 ns, '1' after 20 ns, '0' after 30 ns;
    MEM_WB_RegWrite <= '1', '0' after 10 ns, '1' after 20 ns, '1' after 30 ns;
    EX_MEM_RegDst <= "010", "001" after 10 ns, "000" after 20 ns, "000" after 30 ns;
    MEM_WB_RegDst <= "010", "000" after 10 ns, "000" after 20 ns, "000" after 30 ns;
    ID_EX_Rs <= "000";
    ID_EX_Rt <= "001";
    
    uut: EX_fwd_unit port map (
        EX_MEM_RegWrite => EX_MEM_RegWrite,
        MEM_WB_RegWrite => MEM_WB_RegWrite,
        EX_MEM_RegDst => EX_MEM_RegDst,
        MEM_WB_RegDst => MEM_WB_RegDst,
        ID_EX_Rs => ID_EX_Rs,
        ID_EX_Rt => ID_EX_Rt,
        ForwardA => ForwardA,
        ForwardB => ForwardB
    ); 

end Behavioral;
