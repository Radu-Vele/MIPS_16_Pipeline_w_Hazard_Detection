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
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ctrl_unit is
  Port ( 
    opcode: in std_logic_vector (2 downto 0);
    RegDst: out std_logic;
    ExtOp: out std_logic;
    ALUSrc: out std_logic;
    Branch: out std_logic;
    Jump: out std_logic;
    ALUOp: out std_logic_vector(1 downto 0);
    MemWrite: out std_logic;
    MemtoReg: out std_logic;
    RegWrite: out std_logic);
end ctrl_unit;

architecture Behavioral of ctrl_unit is
    signal tmp_out: std_logic_vector (9 downto 0); -- for clarity
begin
    output_computation: process(opcode)
    begin
        case opcode is
            when "000" => tmp_out <= "1000010001";
            when "001" => tmp_out <= "0110000001";
            when "010" => tmp_out <= "0110000011";
            when "011" => tmp_out <= "0110000100";
            when "100" => tmp_out <= "1101001000";
            when "101" => tmp_out <= "0101001000";
            when "110" => tmp_out <= "0110011001";
            when "111" => tmp_out <= "1110100000";
            when others => tmp_out <= "0000000000";
        end case;
    end process;
    
    RegDst <= tmp_out(9);
    ExtOp <= tmp_out(8);
    ALUSrc <= tmp_out(7);
    Branch <= tmp_out(6);
    Jump <= tmp_out(5);
    ALUOp <= tmp_out(4 downto 3);
    MemWrite <= tmp_out(2);
    MemtoReg <= tmp_out(1);
    RegWrite <= tmp_out(0);
    
end Behavioral;
