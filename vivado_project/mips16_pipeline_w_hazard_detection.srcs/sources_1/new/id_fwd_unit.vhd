----------------------------------------------------------------------------------
-- Company: TUCN
-- Engineer: Radu-Augustin Vele
-- 
-- Create Date: 12/15/2022 10:25:10 AM
-- Design Name: 
-- Module Name: id_fwd_unit - Behavioral
-- Project Name: MIPS 16 Pipeline with Hazard detection and Avoidance
-- Target Devices: 
-- Tool Versions: 
-- Description: Forwarding unit in the ID stage (branch-related)
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity id_fwd_unit is
    Port(
        EX_MEM_RegWrite: in std_logic;
        EX_MEM_RegDst: in std_logic_vector(2 downto 0);
        ID_Branch: in std_logic;
        ID_Rs: in std_logic_vector(2 downto 0);
        ID_Rt: in std_logic_vector(2 downto 0);
        ForwardA: out std_logic;
        ForwardB: out std_logic
    );
end id_fwd_unit;

architecture Behavioral of id_fwd_unit is

begin
    
    detect_and_forward: process(ID_Branch, EX_MEM_RegWrite, EX_MEM_RegDst, ID_Rs, ID_Rt) is
    begin
        ForwardA <= '0';
        ForwardB <= '0';
        if (ID_Branch = '1') and (EX_MEM_RegWrite = '1') and EX_MEM_RegDst = ID_Rs then
            ForwardA <= '1';
        end if;
        
        if (ID_Branch = '1') and (EX_MEM_RegWrite = '1') and EX_MEM_RegDst = ID_Rt then
            ForwardB <= '1';
        end if;
        
    end process;

end Behavioral;
