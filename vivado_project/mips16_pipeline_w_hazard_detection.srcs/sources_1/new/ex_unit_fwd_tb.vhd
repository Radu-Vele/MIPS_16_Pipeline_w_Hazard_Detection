----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/04/2022 11:06:02 PM
-- Design Name: 
-- Module Name: ex_unit_fwd_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity ex_unit_fwd_tb is

end ex_unit_fwd_tb;

architecture Behavioral of ex_unit_fwd_tb is

    component EX_unit is
        Port ( 
            next_pc: in std_logic_vector(15 downto 0);
            rd1: in std_logic_vector(15 downto 0); 
            rd2: in std_logic_vector(15 downto 0);
            ALUSrc: in std_logic;
            ext_imm: in std_logic_vector(15 downto 0);
            sa: in std_logic;
            func: in std_logic_vector(2 downto 0);
            ALUOp: in std_logic_vector(1 downto 0);
            branch_address: out std_logic_vector(15 downto 0);
            zero: out std_logic;
            ALURes: out std_logic_vector (15 downto 0);
            EX_MEM_ALUOut: in std_logic_vector(15 downto 0);
            MEM_WB_ALUOut: in std_logic_vector(15 downto 0);
            EX_MEM_RegWrite: in std_logic;
            MEM_WB_RegWrite: in std_logic;
            EX_MEM_RegDst: in std_logic_vector(2 downto 0);
            MEM_WB_RegDst: in std_logic_vector(2 downto 0);
            ID_EX_Rs: in std_logic_vector(2 downto 0);
            ID_EX_Rt: in std_logic_vector(2 downto 0)
        ); 
    end component;
    
    signal EX_MEM_ALUOut: std_logic_vector(15 downto 0);
    signal MEM_WB_ALUOut: std_logic_vector(15 downto 0);
    signal EX_MEM_RegWrite: std_logic;
    signal MEM_WB_RegWrite: std_logic;
    signal EX_MEM_RegDst: std_logic_vector(2 downto 0);
    signal MEM_WB_RegDst: std_logic_vector(2 downto 0);
    signal ID_EX_Rs: std_logic_vector(2 downto 0);
    signal ID_EX_Rt: std_logic_vector(2 downto 0);
    
    -- outputs
    signal zero: std_logic;
    signal ALURes: std_logic_vector(15 downto 0);
    signal branch_address: std_logic_vector(15 downto 0);

begin
    
    -- scenario: -> no hazard 
    --           -> forward from previous to input B 
    --           -> forward from previous to input A
    --           -> forward from the one before the previous
    
    EX_MEM_RegWrite <= '0', '1' after 10 ns, '1' after 20 ns, '0' after 30 ns;
    MEM_WB_RegWrite <= '1', '0' after 10 ns, '1' after 20 ns, '1' after 30 ns;
    EX_MEM_RegDst <= "010", "001" after 10 ns, "000" after 20 ns, "000" after 30 ns;
    MEM_WB_RegDst <= "010", "000" after 10 ns, "000" after 20 ns, "000" after 30 ns;
    ID_EX_Rs <= "000";
    ID_EX_Rt <= "001";
    EX_MEM_ALUOut <= x"0003";
    MEM_WB_ALUOut <= x"0004";
    
    uut: EX_unit port map (
            next_pc => x"0000",
            rd1 => x"0001",
            rd2 => x"0002",
            ALUSrc => '0',
            ext_imm => x"0000",
            sa => '0',
            func => "001",
            ALUOp => "10",
            branch_address => branch_address,
            zero => zero,
            ALURes => ALURes,
            EX_MEM_ALUOut => EX_MEM_ALUOut,
            MEM_WB_ALUOut => MEM_WB_ALUOut,
            EX_MEM_RegWrite => EX_MEM_RegWrite,
            MEM_WB_RegWrite => MEM_WB_RegWrite,
            EX_MEM_RegDst => EX_MEM_RegDst,
            MEM_WB_RegDst => MEM_WB_RegDst,
            ID_EX_Rs => ID_EX_Rs,
            ID_EX_Rt => ID_EX_Rt
    );

end Behavioral;
