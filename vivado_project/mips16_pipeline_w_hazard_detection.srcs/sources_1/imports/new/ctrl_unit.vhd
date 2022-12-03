----------------------------------------------------------------------------------
-- Company: TUCN
-- Engineer: Radu-Augustin Vele
-- 
-- Create Date: 03/25/2022 02:37:56 PM
-- Design Name: 
-- Module Name: ctrl_unit - Behavioral
-- Project Name: MIPS 16
-- Target Devices: Basys 3
-- Tool Versions: 
-- Description: control unit, generates the control signal based on the opcode
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1 - Remove logic for LUI, BLZ
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ctrl_unit is
  Port ( 
    opcode: in std_logic_vector (2 downto 0);
    func: in std_logic_vector(2 downto 0);
    RegDst: out std_logic;
    ExtOp: out std_logic;
    ALUSrc: out std_logic;
    Branch: out std_logic;
    Jump: out std_logic;
    ALUOp: out std_logic_vector(1 downto 0);
    MemRead: out std_logic;
    MemWrite: out std_logic;
    MemtoReg: out std_logic;
    RegWrite: out std_logic);
end ctrl_unit;

architecture Behavioral of ctrl_unit is
    signal tmp_out: std_logic_vector (10 downto 0);
begin
    output_computation: process(opcode, func)
    begin
        case opcode is
            when "000" =>
                
                tmp_out <= "10000100001"; -- R-type instruction 
                
                if func = "000" then
                    tmp_out <= "00000000000";    
                end if;
            
            when "001" => tmp_out <= "01100000001"; -- Addi
            when "101" => tmp_out <= "01100100001"; -- Subi 
            when "010" => tmp_out <= "01100001011"; -- Lw
            when "011" => tmp_out <= "01100000100"; -- Sw
            when "100" => tmp_out <= "11010010000"; -- Beq
            when "111" => tmp_out <= "11101000000"; -- Jump
            when others => tmp_out <= "00000000000";
        end case;
    end process;
    
    --outputs assignment
    RegDst <= tmp_out(10);
    ExtOp <= tmp_out(9);
    ALUSrc <= tmp_out(8);
    Branch <= tmp_out(7);
    Jump <= tmp_out(6);
    ALUOp <= tmp_out(5 downto 4);
    MemRead <= tmp_out(3);
    MemWrite <= tmp_out(2);
    MemtoReg <= tmp_out(1);
    RegWrite <= tmp_out(0);
    
end Behavioral;
