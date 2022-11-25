----------------------------------------------------------------------------------
-- Company: TUCN
-- Engineer: Radu-Augustin Vele
-- 
-- Create Date: 04/01/2022 11:34:52 AM
-- Design Name: 
-- Module Name: EX_unit - Behavioral
-- Project Name: MIPS 16
-- Target Devices: Basys 3
-- Tool Versions: 2020.1
-- Description: Execution unit for the mips - takes the data resulting from the Instruction decode, makes the necessary
-- computations and gives back some results
-- 
-- Dependencies: no dependencies
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity EX_unit is
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
        ALURes: out std_logic_vector (15 downto 0)
    );
end EX_unit;

architecture Behavioral of EX_unit is
    signal second_alu_input: std_logic_vector (15 downto 0);
    signal ALUCtrl: std_logic_vector (2 downto 0);
    signal tmp_res: std_logic_vector (15 downto 0);
begin

    branch_adder: branch_address <= next_pc + ext_imm; --no shifting required

    input1_MUX: second_alu_input <= rd2 when ALUSrc = '0' else ext_imm;

    ALU_component: process(ALUCtrl, rd1, second_alu_input, sa, ext_imm)
    begin
        case(ALUCtrl) is 
            when "001" => tmp_res <= rd1 + second_alu_input; --addition
            when "010" => tmp_res <= rd1 - second_alu_input; --subtraction
            when "011" => -- sll
                if(sa = '1') then
                    tmp_res <= rd1(14 downto 0) & '0';
                else
                    tmp_res <= rd1;
                end if;
            when "100" => --srl
                if(sa = '1') then
                    tmp_res <= '0' & rd1(15 downto 1);
                else
                    tmp_res <= rd1;
                end if;
            when "101" => tmp_res <= rd1 and second_alu_input;
            when "110" => tmp_res <= rd1 or second_alu_input;
            when "111" => tmp_res <= rd1 xor second_alu_input;
            when "000" => --sra
                if(sa = '1') then 
                    tmp_res <= rd1(15) & rd1(15 downto 1);
                else
                    tmp_res <= rd1;
                end if;
            when others => tmp_res <= x"0000";
        end case;
    end process;

    ALU_control: process(func, ALUOp)
    begin
        if ALUOp = "10" then -- we deal with R-type
            case (func) is
                when "001" => ALUCtrl <= "001"; --addition 
                when "010" => ALUCtrl <= "010"; --subtraction
                when "011" => ALUCtrl <= "011"; --sll 
                when "100" => ALUCtrl <= "100"; --srl 
                when "101" => ALUCtrl <= "101"; --and 
                when "110" => ALUCtrl <= "110"; --or
                when "111" => ALUCtrl <= "111"; --xor
                when "000" => ALUCtrl <= "000"; --sra
                when others => ALUCtrl <= "000"; --default
            end case;         
        else
            case(ALUOp) is 
                when "00" => ALUCtrl <= "001"; -- addition
                when "01" => ALUCtrl <= "010"; -- subtraction for branch
                when others => ALUCtrl <= "000";
            end case;
        end if;
    end process;
    
    --outputs assignment
    ALURes <= tmp_res;
    zero <= '1' when (tmp_res = x"0000") else '0';    
    
end Behavioral;
