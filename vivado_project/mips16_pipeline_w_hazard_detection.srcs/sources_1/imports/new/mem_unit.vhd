----------------------------------------------------------------------------------
-- Company: TUCN
-- Engineer: Radu-Augustin Vele
-- 
-- Create Date: 04/07/2022 03:57:48 PM
-- Design Name: Memory Unit
-- Module Name: mem_unit - Behavioral
-- Project Name: MIPS 16 Single Cycle
-- Target Devices: Basys 3
-- Tool Versions: 2020.1
-- Description: A RAM memory with synchronous write and asynchronous read
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

entity mem_unit is
    Port ( 
        clk100MHz: in std_logic;
        MemWrite: in std_logic;
        ALURes: in std_logic_vector (15 downto 0);
        RD2: in std_logic_vector (15 downto 0);
        ALURes_out: out std_logic_vector (15 downto 0);
        MemData: out std_logic_vector (15 downto 0)
    );
end mem_unit;

architecture Behavioral of mem_unit is
    type ram_content is array (0 to 255) of std_logic_vector(15 downto 0); --use the LS byte of the address
    signal curr_content: ram_content := (
        x"FFFF",
        x"0002", --start of the tested array
        x"0003",
        x"1111",
        x"ABC8",
        x"0004",
        x"0006",
        x"0008", 
        others => x"0000");
begin
    writing: process(clk100MHz, MemWrite) is
    begin
        if rising_edge(clk100MHz) then
            if(MemWrite = '1') then
                curr_content(to_integer(unsigned(ALURes))) <= RD2;
            end if;
        end if;
    end process;
    
    MemData <= curr_content(to_integer(unsigned(ALURes)));
    ALURes_out <= ALURes;
    
    --TODO ADD branch signal generation

end Behavioral;
