----------------------------------------------------------------------------------
-- Company: TUCN
-- Engineer: Radu-Augustin Vele
-- 
-- Create Date: 03/18/2022 02:15:21 PM
-- Design Name: 
-- Module Name: IF_unit - Behavioral
-- Project Name: MIPS 16 Single Cycle
-- Target Devices: Basys 3
-- Tool Versions: 2020.1
-- Description: Instruction fetch unit - takes the instruction pointed to by the program counter and
--              computes the next address.
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IF_unit is
    Port (
        clk100MHz: in std_logic;
        jump_addr: in std_logic_vector(15 downto 0);
        branch_addr: in std_logic_vector(15 downto 0);
        jump_ctrl: in std_logic;
        PCsrc_ctrl: in std_logic;
        reset_pc: in std_logic;
        enable_pc: in std_logic; 
        instruction: out std_logic_vector(15 downto 0);
        pc_plus_one: out std_logic_vector(15 downto 0));
end IF_unit;

architecture Behavioral of IF_unit is
    signal nxt_pc: std_logic_vector(15 downto 0);
    signal curr_pc_content: std_logic_vector(15 downto 0);
    signal adder_out: std_logic_vector(15 downto 0);
    signal mux1_out: std_logic_vector(15 downto 0);
    type rom_content is array(0 to 255) of std_logic_vector(15 downto 0);
    
    -- Instructions Format: --------------------
    
    -- R Type
    --  ---------------------------------------
    -- | opcode | rs | rt | rd | sa | function |
    --  ---------------------------------------
    -- 15      12    9    6    3    2         0
        
    -- I Type
    --  ---------------------------------------
    -- | opcode | rs | rt | immediate/address  |
    --  ---------------------------------------
    
    -- J Type
    --  ---------------------------------------
    -- | opcode |     target address           |
    --  ---------------------------------------
    --------------------------------------------
    
    signal curr_rom: rom_content := ( 
-- Data Hazard RAW in EX stage
      B"000_001_011_011_0_001", -- add $3 = $1 + $3 -- no dependency
      B"000_001_010_011_0_001", -- add $3 = $1 + $2 -- no dependency
      B"011_011_011_0000001", -- store MEM($3 + '1') = $3 -- depends on the previous two (but latest is taken into account)
      B"011_011_011_0000010", -- store MEM($3 + '2') = $3 -- depends on the i. before the previous one
      B"011_011_011_0000011", -- store MEM($3 + '3') = $3 -- no dependency
      others => x"0000"
    );
    
begin   
    pc: process(clk100MHz, reset_pc) is
    begin
        if(reset_pc = '1') then
            curr_pc_content <= x"0000";
        elsif rising_edge(clk100MHz) then
            if(enable_pc = '1') then
                curr_pc_content <= nxt_pc;
            end if;
        end if;
    end process;
    
    instruction <= curr_rom(to_integer(unsigned(curr_pc_content(7 downto 0))));
   
    -- next address computation
    adder: adder_out <= curr_pc_content + "1";
    pc_plus_one <= adder_out; -- needed for ID (branch)
    
    mux1: mux1_out <= branch_addr when (PCsrc_ctrl = '1') else adder_out;
    mux2: nxt_pc <= jump_addr when (jump_ctrl = '1') else mux1_out;  

    -- TODO: Add Jump detection and address computation here
    -- TODO: Add Dynamic Branch Prediction Mechanisms
end Behavioral;
