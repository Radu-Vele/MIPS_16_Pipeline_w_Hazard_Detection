----------------------------------------------------------------------------------
-- Company: TUCN
-- Engineer: Radu-Augustin Vele
-- 
-- Create Date: 12/04/2022 10:56:38 PM
-- Design Name: 
-- Module Name: EX_fwd_unit - Behavioral
-- Project Name: MIPS 16 Pipeline with Hazard detection and Avoidance
-- Target Devices: 
-- Tool Versions: 
-- Description: Forwarding unit to be placed in the EX stage
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

entity EX_fwd_unit is
    Port (
        EX_MEM_RegWrite: in std_logic;
        MEM_WB_RegWrite: in std_logic;
        EX_MEM_RegDst: in std_logic_vector(2 downto 0);
        MEM_WB_RegDst: in std_logic_vector(2 downto 0);
        ID_EX_Rs: in std_logic_vector(2 downto 0);
        ID_EX_Rt: in std_logic_vector(2 downto 0);
        ForwardA: out std_logic_vector (1 downto 0);
        ForwardB: out std_logic_vector (1 downto 0)
    );
end EX_fwd_unit;

architecture Behavioral of EX_fwd_unit is

begin

    detection_logic: process (EX_MEM_RegWrite, MEM_WB_RegWrite, EX_MEM_RegDst, MEM_WB_RegDst, ID_EX_Rs, ID_EX_Rt) is
    begin
        
        ForwardA <= "00";
        ForwardB <= "00";
                
        if MEM_WB_RegWrite = '1' then 
            if MEM_WB_RegDst = ID_EX_Rs then 
                ForwardA <= "10";
            elsif MEM_WB_RegDst = ID_EX_Rt then
                ForwardB <= "10";
            end if;
        end if;
        
        -- more priority
        if EX_MEM_RegWrite = '1' then 
            if EX_MEM_RegDst = ID_EX_Rs then
                ForwardA <= "01";
            elsif EX_MEM_RegDst = ID_EX_Rt then
                ForwardB <= "01";	
            end if;
        end if;        
    end process;
    
end Behavioral;
