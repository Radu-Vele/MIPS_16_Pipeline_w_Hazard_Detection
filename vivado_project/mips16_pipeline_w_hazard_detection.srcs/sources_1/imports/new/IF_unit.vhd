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
    
    signal curr_rom: rom_content := ( --even numbers counter test program
        B"000_001_001_001_0_111", -- x"0497"
        B"000_010_010_010_0_111", -- x"0927"
        B"000_100_100_100_0_111", -- x"1247"
        B"000_101_101_101_0_111", -- x"16D7"
        B"000_110_110_110_0_111", -- x"1B47"
        B"001_010_010_0000001", -- x"2901"
        B"001_100_100_1111111", -- x"327F"
        B"001_101_101_1111110", -- x"36FE"
        B"001_110_110_0000111", -- x"3B87"
        B"000_110_010_110_0_001", -- x"1961"
        B"010_010_011_0000000", -- x"4980"
        B"000_011_101_011_0_110", -- x"0EB6"
        B"100_011_100_0000001", -- x"8E01"
        B"001_001_001_0000001", -- x"2481"
        B"001_010_010_0000001", -- x"2901"
        B"100_010_110_0000001", -- x"8B01"
        B"111_0000000001010", -- x"E00A"
        B"001_001_001_0000000", -- x"2480" -- tested ok - output = 5
        others => x"0000"
    );
    
begin   
    pc: process(clk100MHz) is
    begin
        if rising_edge(clk100MHz) then
            if (reset_pc = '1') then
                curr_pc_content <= x"0000";
            elsif(enable_pc = '1') then
                curr_pc_content <= nxt_pc;
            end if;
        end if;
    end process;
    
    instruction <= curr_rom(to_integer(unsigned(curr_pc_content(7 downto 0))));
   
    -- next address computation
    adder: adder_out <= curr_pc_content + "1";
    pc_plus_one <= adder_out; -- needed for ID (branch)
    
    mux1: mux1_out <= adder_out when (PCsrc_ctrl = '0') else branch_addr;
    mux2: nxt_pc <= mux1_out when (jump_ctrl = '0') else jump_addr;  

    -- TODO: Add Jump detection and address computation here
    -- TODO: Add Dynamic Branch Prediction Mechanisms
end Behavioral;
