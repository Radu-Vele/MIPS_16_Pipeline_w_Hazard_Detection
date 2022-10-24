----------------------------------------------------------------------------------
-- Company: TUCN
-- Engineer: Radu-Augustin Vele
-- 
-- Create Date: 03/04/2022 02:02:50 PM
-- Design Name: 
-- Module Name: reg_file - Behavioral
-- Project Name: 
-- Target Devices: Basys3
-- Tool Versions: 2020.1
-- Description: Register file component with asynchronous read and synchronous write
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.02 - File Created + modified for 3-bit inputs
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

--
--

entity reg_file is
	
	port (
		read_address2: in STD_LOGIC_VECTOR(2 downto 0);
		read_address1: in STD_LOGIC_VECTOR(2 downto 0);
		write_address: in STD_LOGIC_VECTOR(2 downto 0); --Addresses coming from the counter
		write_data: in STD_LOGIC_VECTOR(15 downto 0);
		reg_write: in STD_LOGIC;
		clk100MHz: in STD_LOGIC;
		read_data1: out STD_LOGIC_VECTOR(15 downto 0);
		read_data2: out STD_LOGIC_VECTOR(15 downto 0));

end entity reg_file;

architecture Behavioral of reg_file is

	type reg_content is array(0 to 7) of STD_LOGIC_VECTOR(15 downto 0); --8x16 size

	signal current_content: reg_content := (
		x"0001",
		x"000A",
		x"000F",
		x"0000",
		x"0000",
		x"0002",
		x"0002",
		x"ABCD",
		others => x"1111");

begin
	
    synchronized: process(clk100MHz)
	begin
	   if rising_edge(clk100MHz) then
	       if reg_write = '1' then
	           current_content(to_integer(unsigned(write_address))) <= write_data; --synchronous write
	       end if;
	   end if;    
	end process;
	
	--asynchronous read
	read_data1 <= current_content(to_integer(unsigned(read_address1)));
	read_data2 <= current_content(to_integer(unsigned(read_address2)));
	
end architecture Behavioral;