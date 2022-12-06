----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/06/2022 09:57:24 AM
-- Design Name: 
-- Module Name: mem_fwd_tb - Behavioral
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

entity mem_fwd_tb is

end mem_fwd_tb;

architecture Behavioral of mem_fwd_tb is
    component MEM_fwd_unit is
        Port (
            MEM_WB_RegWrite: in std_logic;
            WB_BUF_RegWrite: in std_logic;
            EX_MEM_MemWrite: in std_logic;
            EX_MEM_Rt: in std_logic_vector(2 downto 0);
            WB_BUF_RegDst: in std_logic_vector(2 downto 0);
            MEM_WB_RegDst: in std_logic_vector(2 downto 0);
            ForwardC: out std_logic_vector(1 downto 0)
        );
    end component;
    
    -- inputs
    signal MEM_WB_RegWrite: std_logic;
    signal WB_BUF_RegWrite: std_logic;
    signal EX_MEM_MemWrite: std_logic;
    signal EX_MEM_Rt: std_logic_vector(2 downto 0);
    signal WB_BUF_RegDst: std_logic_vector(2 downto 0);
    signal MEM_WB_RegDst: std_logic_vector(2 downto 0);
    signal ForwardC: std_logic_vector(1 downto 0);
begin
   
    -- scenario:
    --   -> no forwarding 
    --   -> no forwarding as the instruction is not a store
    --   -> forward from MEM
    --   -> forward from WB

    MEM_WB_RegWrite <= '0', '1' after 10 ns;
    WB_BUF_RegWrite <= '0', '1' after 10 ns;
    EX_MEM_MemWrite <= '1', '0' after 10 ns, '1' after 20 ns;
    EX_MEM_Rt <= "001";
    WB_BUF_RegDst <= "000", "001" after 10 ns;
    MEM_WB_RegDst <= "000", "001" after 10 ns, "100" after 30 ns;
   
    -- expected output: 00 00 01 10
   
    uut: MEM_fwd_unit port map (
        MEM_WB_RegWrite => MEM_WB_RegWrite,
        WB_BUF_RegWrite => WB_BUF_RegWrite,
        EX_MEM_MemWrite => EX_MEM_MemWrite,
        EX_MEM_Rt => EX_MEM_Rt,
        WB_BUF_RegDst => WB_BUF_RegDst,
        MEM_WB_RegDst => MEM_WB_RegDst,
        ForwardC => ForwardC
    );

end Behavioral;
