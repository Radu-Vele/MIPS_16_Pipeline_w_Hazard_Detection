----------------------------------------------------------------------------------
-- Company: TUCN
-- Engineer: Radu-Augustin Vele
-- 
-- Create Date: 03/25/2022 02:16:35 PM
-- Design Name: 
-- Module Name: ID_unit - Behavioral
-- Project Name: MIPS 16
-- Target Devices: Basys 3
-- Tool Versions: 
-- Description: Instruction Decode unit
-- 
-- Dependencies: Register file module
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ID_unit is
    Port ( 
        clk100MHz: in std_logic;
        instruction: in std_logic_vector(15 downto 0);
        wd: in std_logic_vector(15 downto 0);
        RegWrite: in std_logic;
        RegDstAddress: in std_logic_vector(2 downto 0);
        ExtOp: in std_logic;
        rd1: out std_logic_vector(15 downto 0);
        rd2: out std_logic_vector(15 downto 0);
        ext_imm: out std_logic_vector(15 downto 0);
        func: out std_logic_vector(2 downto 0);
        sa: out std_logic;
        write_address_1: out std_logic_vector(2 downto 0);
        write_address_2: out std_logic_vector(2 downto 0)
    );
end ID_unit;

architecture Behavioral of ID_unit is

    signal mux_outp: std_logic_vector(2 downto 0);

    component reg_file is
        port (
            read_address2: in STD_LOGIC_VECTOR(2 downto 0);
            read_address1: in STD_LOGIC_VECTOR(2 downto 0);
            write_address: in STD_LOGIC_VECTOR(2 downto 0); --Addresses coming from the counter
            write_data: in STD_LOGIC_VECTOR(15 downto 0);
            reg_write: in STD_LOGIC;
            clk100MHz: in STD_LOGIC;
            read_data1: out STD_LOGIC_VECTOR(15 downto 0);
            read_data2: out STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
begin
    
    write_address_1 <= instruction(9 downto 7);
    write_address_2 <= instruction (6 downto 4);
    
    reg_file_connection: reg_file port map(
        read_address2 => instruction(9 downto 7),
		read_address1 => instruction(12 downto 10),
		write_address => RegDstAddress,
		write_data => wd,
		reg_write => RegWrite,
		clk100MHz => clk100MHz,
		read_data1 => rd1,
		read_data2 => rd2);
   
    extender_unit: ext_imm <= x"00" & '0' & instruction(6 downto 0) when ExtOp = '0' else
               x"FF" & '1' & instruction(6 downto 0) when instruction(6) = '1' else
               x"00" & '0'& instruction(6 downto 0);
     
    func <= instruction(2 downto 0);
    sa <= instruction(3);
    
end Behavioral;
